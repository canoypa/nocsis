import { randomInt } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import {
  COLLECTION as BINDINGS,
  bindingDoc,
  revoke,
} from "../authz/binding.js";
import { subject, user } from "../authz/principal.js";
import { group } from "../authz/resource.js";
import { auth, firestore } from "../clients/firebase.js";
import { isAlreadyExists } from "../clients/firestore_errors.js";

/** 期限切れの行は Firestore の TTL（expires_at）が消す */
export const PAIRINGS = "display_pairings";
/** コードを外した回数。呼び出した人ごと。期限切れの行は TTL（expires_at）が消す */
export const FAILURES = "display_pairing_failures";

const CODE_TTL_MS = 10 * 60 * 1000;
/** 10分に10回まで。100万通りを当てるには、1日で0.15%ほどしか試せない */
const FAILURE_LIMIT = 10;
const FAILURE_WINDOW_MS = 10 * 60 * 1000;

const displays = (groupId: string) =>
  firestore.collection("groups").doc(groupId).collection("displays");

export type Display = {
  id: string;
  name: string;
  created_at: string;
  removed_at: string | null;
};

const toDisplay = (doc: FirebaseFirestore.DocumentSnapshot): Display => ({
  id: doc.id,
  name: doc.get("name"),
  created_at: (doc.get("created_at") as Timestamp).toDate().toISOString(),
  removed_at:
    (doc.get("removed_at") as Timestamp | undefined)?.toDate().toISOString() ??
    null,
});

/**
 * 端末用のコードを発行する。1台につき使えるコードは1つだけにし、前のコードは消す。
 *
 * コードの総当たりで得られるのは「待っている端末を自分のグループに入れること」だけ
 * （登録には role_binding.create が要る）。それも外した回数で止める。
 */
export const issuePairing = async (
  uid: string,
): Promise<{ code: string; expires_at: string }> => {
  const expiresAt = Timestamp.fromMillis(Date.now() + CODE_TTL_MS);

  // 6桁は100万通りなので、使用中のコードとはまず重ならない。重なったら引き直す
  for (let attempt = 0; attempt < 5; attempt++) {
    const code = randomInt(0, 1_000_000).toString().padStart(6, "0");
    const ref = firestore.collection(PAIRINGS).doc(code);

    try {
      await firestore.runTransaction(async (tx) => {
        // 前のコードを消すのも同じトランザクションで。外でやると、同時に呼ばれたときに2つ残る
        const previous = await tx.get(
          firestore.collection(PAIRINGS).where("uid", "==", uid),
        );
        const existing = await tx.get(ref);

        if (existing.exists && isLive(existing)) {
          throw new CodeInUse();
        }

        for (const doc of previous.docs) tx.delete(doc.ref);
        tx.set(ref, { uid, expires_at: expiresAt });
      });

      return { code, expires_at: expiresAt.toDate().toISOString() };
    } catch (err) {
      if (err instanceof CodeInUse || isAlreadyExists(err)) continue;
      throw err;
    }
  }

  throw new Error("コードを発行できませんでした");
};

const isLive = (doc: FirebaseFirestore.DocumentSnapshot) =>
  (doc.get("expires_at") as Timestamp).toMillis() > Date.now();

class CodeInUse extends Error {}

export type RegisterResult =
  | { ok: true; display: Display }
  | { ok: false; reason: "code_not_found" | "too_many_attempts" };

/**
 * コードを使い切り、端末をグループの教室ディスプレイにする。
 * コードの消費・記録・付与を1つのトランザクションにし、どれかだけが残る状態を作らない。
 */
export const registerDisplay = async (params: {
  callerUid: string;
  groupId: string;
  code: string;
  name?: string;
}): Promise<RegisterResult> => {
  const { callerUid, groupId, code, name } = params;
  const failureRef = firestore.collection(FAILURES).doc(callerUid);

  if (await tooManyFailures(failureRef)) {
    return { ok: false, reason: "too_many_attempts" };
  }

  const pairingRef = firestore.collection(PAIRINGS).doc(code);

  const uid = await firestore.runTransaction(async (tx) => {
    const pairing = await tx.get(pairingRef);
    if (!pairing.exists || !isLive(pairing)) return undefined;

    const uid: string = pairing.get("uid");
    const binding = bindingDoc({
      principal: user(uid),
      role: "roles/group.display",
      resource: group(groupId),
    });
    const existingBinding = await tx.get(binding.ref);
    // 同時に登録された端末と同じ番号にならないよう、名前もトランザクションの中で読む
    const others = name
      ? undefined
      : (await tx.get(displays(groupId))).docs.filter((doc) => doc.id !== uid);

    // 発行してから、メールや Google を結びつけた・消された、ということがある
    if (!(await isAnonymous(uid))) return undefined;

    tx.delete(pairingRef);
    tx.set(displays(groupId).doc(uid), {
      name:
        name ||
        defaultDisplayName(
          others?.map((doc) => doc.get("name") as string) ?? [],
        ),
      created_at: Timestamp.now(),
    });
    if (!existingBinding.exists) tx.create(binding.ref, binding.data);

    return uid;
  });

  if (!uid) {
    await recordFailure(failureRef);
    return { ok: false, reason: "code_not_found" };
  }

  return {
    ok: true,
    display: toDisplay(await displays(groupId).doc(uid).get()),
  };
};

const DEFAULT_NAME = /^ディスプレイ ([1-9]\d*)$/;

/** 名前に使われていない一番小さい番号で「ディスプレイ N」を作る */
export const defaultDisplayName = (names: string[]): string => {
  const used = new Set(
    names.flatMap((name) => {
      const match = DEFAULT_NAME.exec(name);
      return match ? [Number(match[1])] : [];
    }),
  );

  let n = 1;
  while (used.has(n)) n++;

  return `ディスプレイ ${n}`;
};

const tooManyFailures = async (ref: FirebaseFirestore.DocumentReference) => {
  const snapshot = await ref.get();

  return (
    snapshot.exists &&
    isLive(snapshot) &&
    (snapshot.get("count") as number) >= FAILURE_LIMIT
  );
};

const recordFailure = (ref: FirebaseFirestore.DocumentReference) =>
  firestore.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);

    if (snapshot.exists && isLive(snapshot)) {
      tx.update(ref, { count: FieldValue.increment(1) });
    } else {
      tx.set(ref, {
        count: 1,
        expires_at: Timestamp.fromMillis(Date.now() + FAILURE_WINDOW_MS),
      });
    }
  });

export const listDisplays = async (groupId: string): Promise<Display[]> => {
  const snapshot = await displays(groupId).orderBy("created_at", "desc").get();

  return snapshot.docs.map(toDisplay);
};

export const renameDisplay = async (params: {
  groupId: string;
  displayId: string;
  name: string;
}): Promise<Display | undefined> => {
  const ref = displays(params.groupId).doc(params.displayId);

  const updated = await firestore.runTransaction(async (tx) => {
    if (!(await tx.get(ref)).exists) return false;

    tx.update(ref, { name: params.name });
    return true;
  });

  return updated ? toDisplay(await ref.get()) : undefined;
};

/**
 * 外す。付与を先に消し、記録を後に消す（逆だと、付与だけ残って一覧に出ない端末ができる）。
 * ほかに付与が残っていない匿名アカウントは、アカウントごと消してサインインもできなくする。
 *
 * 別のグループへの登録と同時に走ると、登録直後のアカウントを消すことがある。その端末は
 * 登録し直せばよく、ロックを入れるほどの頻度ではない。
 */
export const removeDisplay = async (params: {
  groupId: string;
  displayId: string;
}): Promise<"removed" | "not_found"> => {
  const { groupId, displayId } = params;
  const ref = displays(groupId).doc(displayId);

  if (!(await ref.get()).exists) {
    return "not_found";
  }

  await revoke({
    principal: user(displayId),
    role: "roles/group.display",
    resource: group(groupId),
  });
  await ref.delete();

  // 外した端末のコードが残っていると、消したアカウントがまた登録されてしまう
  const pairings = await firestore
    .collection(PAIRINGS)
    .where("uid", "==", displayId)
    .get();
  await Promise.all(pairings.docs.map((doc) => doc.ref.delete()));

  const remaining = await firestore
    .collection(BINDINGS)
    .where("subject", "==", subject(user(displayId)))
    .limit(1)
    .get();

  if (remaining.empty && (await isAnonymous(displayId))) {
    await auth.deleteUser(displayId).catch((err) => {
      // 同じ端末を2つのグループから同時に外すと、先に消えていることがある
      if (!isUserNotFound(err)) throw err;
    });
  }

  return "removed";
};

/** メールや Google と結びついていないアカウント。人のアカウントを消さないための確かめ */
const isAnonymous = async (uid: string): Promise<boolean> => {
  try {
    const record = await auth.getUser(uid);

    return (
      record.providerData.length === 0 && !record.email && !record.phoneNumber
    );
  } catch (err) {
    if (isUserNotFound(err)) return false;

    throw err;
  }
};

const isUserNotFound = (err: unknown): boolean =>
  typeof err === "object" &&
  err !== null &&
  "code" in err &&
  err.code === "auth/user-not-found";
