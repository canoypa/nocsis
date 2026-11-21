import { getAuth } from "firebase-admin/auth";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { cleanupAnonymousUsers } from "./index.js";

process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "localhost:9099";

const auth = () => getAuth(firebaseApp);
const firestore = () => getFirestore(firebaseApp);

const NOW = DateTime.fromISO("2026-11-21T03:00:00+09:00");

const EMULATOR = `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1`;
const PROJECT_ID = process.env.GCLOUD_PROJECT ?? "demo-nocsis";

/** 匿名でサインインし（トークンの更新時刻が今になる）、サインインの時刻だけを古くする */
const signInLongAgoButRefreshedNow = async (): Promise<string> => {
  const { localId } = (await (
    await fetch(`${EMULATOR}/accounts:signUp?key=fake`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: "{}",
    })
  ).json()) as { localId: string };

  await fetch(`${EMULATOR}/projects/${PROJECT_ID}/accounts:update`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: "Bearer owner",
    },
    body: JSON.stringify({
      localId,
      createdAt: "1000000000000",
      lastLoginAt: "1000000000000",
    }),
  });

  return localId;
};

const exists = async (uid: string) =>
  auth()
    .getUser(uid)
    .then(() => true)
    .catch(() => false);

describe("cleanupAnonymousUsers", () => {
  beforeEach(async () => {
    const usedAt = (days: number) =>
      NOW.minus({ days }).toJSDate().toUTCString();

    await auth().importUsers([
      {
        uid: "stale_display",
        metadata: { creationTime: usedAt(60), lastSignInTime: usedAt(31) },
      },
      {
        uid: "active_display",
        metadata: { creationTime: usedAt(60), lastSignInTime: usedAt(29) },
      },
      {
        uid: "stale_person",
        email: "person@example.com",
        metadata: { creationTime: usedAt(60), lastSignInTime: usedAt(31) },
      },
    ]);

    await firestore().doc("groups/g1/displays/stale_display").set({
      name: "1年1組 黒板横",
      created_at: Timestamp.now(),
    });
    await firestore().doc("role_bindings/b1").set({
      subject: "user:stale_display",
      role: "roles/group.display",
      resource: "group:g1",
    });
    await firestore().doc("role_bindings/b2").set({
      subject: "user:active_display",
      role: "roles/group.display",
      resource: "group:g1",
    });
  });

  afterEach(async () => {
    await auth()
      .deleteUsers(["stale_display", "active_display", "stale_person"])
      .catch(() => {});
  });

  it("30日以上使われていない匿名アカウントだけを消すこと", async () => {
    await cleanupAnonymousUsers(NOW);

    expect(await exists("stale_display")).toBe(false);
    expect(await exists("active_display")).toBe(true);
    expect(await exists("stale_person")).toBe(true);
  });

  it("サインインが古くても、トークンを更新し続けている端末は消さないこと", async () => {
    const uid = await signInLongAgoButRefreshedNow();

    await cleanupAnonymousUsers(DateTime.now());

    expect(await exists(uid)).toBe(true);
    await auth().deleteUser(uid);
  });

  it("消したアカウントの付与を外し、教室ディスプレイを解除済みにすること", async () => {
    await cleanupAnonymousUsers(NOW);

    expect((await firestore().doc("role_bindings/b1").get()).exists).toBe(
      false,
    );
    expect((await firestore().doc("role_bindings/b2").get()).exists).toBe(true);

    const display = await firestore()
      .doc("groups/g1/displays/stale_display")
      .get();
    expect((display.get("removed_at") as Timestamp).toMillis()).toBe(
      NOW.toMillis(),
    );
  });
});
