// エミュレータと Staging に、同じ架空のデータを入れる。何度流しても同じ状態になる。
//
// エミュレータ: エミュレータを起動したまま、backend で
//   GCLOUD_PROJECT=demo-nocsis FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
//     FIRESTORE_EMULATOR_HOST=127.0.0.1:8888 pnpm exec tsx scripts/seed.ts
// Staging: Actions の「Seed Staging」から流す。
//
// 公開リポジトリの Actions のログは誰でも読めるので、メールアドレスや uid はログに出さない。
import assert from "node:assert";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

const STAGING_PROJECT_ID = "nocsis-development";

const env = process.env;
const projectId = env.GOOGLE_CLOUD_PROJECT || env.GCLOUD_PROJECT;
const emulated = Boolean(
  env.FIRESTORE_EMULATOR_HOST || env.FIREBASE_AUTH_EMULATOR_HOST,
);

if (emulated) {
  // 片方だけだと、もう片方は本物のプロジェクトに書き込む。
  assert(
    env.FIRESTORE_EMULATOR_HOST && env.FIREBASE_AUTH_EMULATOR_HOST,
    "FIRESTORE_EMULATOR_HOST と FIREBASE_AUTH_EMULATOR_HOST は両方設定する",
  );
  assert(
    projectId?.startsWith("demo-"),
    "エミュレータには demo- で始まるプロジェクト ID を使う",
  );
} else {
  // 本番の ID を名指しで弾くのではなく、Staging だけを通す。打ち間違えた別のプロジェクトにも書かない。
  assert(
    projectId === STAGING_PROJECT_ID,
    `エミュレータ以外では ${STAGING_PROJECT_ID} にだけ流せる`,
  );
}

const required = (name: string): string => {
  const value = env[name]?.trim();
  assert(value, `${name} が設定されていません`);
  return value;
};

const parseEmails = (value: string) =>
  value
    .split(/[\s,]+/)
    .map((email) => email.trim())
    .filter((email) => email.length > 0);

const config = emulated
  ? {
      // e2e/fake_external_apis.ts がこの ID ごとに偽の予定を返す。
      classesCalendarId: "classes",
      eventsCalendarId: "events",
      slackEventChannelId: "slack",
      // frontend/integration_test/app_test.dart がこのパスワードでログインする。
      memberPassword: "e2e-password",
      allowedEmails: parseEmails(env.SEED_ALLOWED_EMAILS ?? ""),
    }
  : {
      classesCalendarId: required("SEED_CLASSES_CALENDAR_ID"),
      eventsCalendarId: required("SEED_EVENTS_CALENDAR_ID"),
      slackEventChannelId: "",
      // パスワードがあると、誰でもテスト用のアカウントでログインして、グループの中を見られる。
      memberPassword: undefined,
      allowedEmails: parseEmails(required("SEED_ALLOWED_EMAILS")),
    };
// 外すと、グループに参加していない画面を確かめられる。
const joinAllowedUsers = env.SEED_JOIN_ALLOWED_USERS !== "false";

const app = initializeApp({ projectId });
const auth = getAuth(app);
const firestore = getFirestore(app);

// src の Firestore クライアントは既定のアプリを使い回す。上で作ったアプリを使わせるため、作った後に読む。
const { COLLECTION: BINDINGS, grant } = await import("../src/authz/binding.js");
const { subject, user } = await import("../src/authz/principal.js");
const { group, serialize } = await import("../src/authz/resource.js");

// 所属ありのユーザーで、編集を含むすべての画面を確かめられるようにする。
const MEMBER_ROLE = "roles/group.admin";

const GROUP_ID = "test_group";

const testUsers = [
  {
    uid: "test-member",
    email: "member@example.com",
    displayName: "テスト 所属あり",
    password: config.memberPassword,
    joined: true,
  },
  {
    uid: "test-nonmember",
    email: "nonmember@example.com",
    displayName: "テスト 所属なし",
    password: undefined,
    joined: false,
  },
];

const errorCode = (error: unknown) =>
  typeof error === "object" && error !== null && "code" in error
    ? String(error.code)
    : undefined;

const upsertUser = async ({
  uid,
  email,
  displayName,
  password,
}: (typeof testUsers)[number]) => {
  const props = { email, displayName, ...(password ? { password } : {}) };
  try {
    await auth.updateUser(uid, props);
  } catch (error) {
    if (errorCode(error) !== "auth/user-not-found") throw error;
    await auth.createUser({ uid, ...props });
  }
};

const setMembership = async (uid: string, joined: boolean) => {
  if (!joined) {
    // 未参加の画面を確かめるので、ロールを問わずこのグループへの付与を全部外す
    const bindings = await firestore
      .collection(BINDINGS)
      .where("subject", "==", subject(user(uid)))
      .where("resource", "==", serialize(group(GROUP_ID)))
      .get();
    await Promise.all(bindings.docs.map((doc) => doc.ref.delete()));
    return;
  }
  await grant({
    principal: user(uid),
    role: MEMBER_ROLE,
    resource: group(GROUP_ID),
  });
};

// エラーの文言にメールアドレスが入りうるので、コードだけを返す。
const findUidByEmail = async (email: string) => {
  try {
    const user = await auth.getUserByEmail(email);
    // 誰でもサインアップできるので、確かめていないアドレスは他人が先に登録したものかもしれない
    return user.emailVerified ? user.uid : undefined;
  } catch (error) {
    const code = errorCode(error);
    if (code === "auth/user-not-found") return undefined;
    throw new Error(`ユーザーを引けませんでした (${code ?? "unknown"})`, {
      cause: error,
    });
  }
};

await firestore
  .collection("groups")
  .doc(GROUP_ID)
  .set({
    name: "テストグループ",
    classes_calendar_id: config.classesCalendarId,
    events_calendar_id: config.eventsCalendarId,
    dayduty_start_date: "2000-01-01",
    slack_event_channel_id: config.slackEventChannelId,
    // Slack のトークンが無いので、毎朝の日直通知が落ちる。
    dayduty_notification_enabled: false,
    weather_point: { lat: 35.6812, lon: 139.7671 },
  });

// 1人にしている。日直は日付で回るので、増やすと e2e が表示を確かめる生徒が日によって変わる。
const classmates = [{ stuNo: 1, name: "テスト 太郎" }];
const classmateIds = classmates.map(({ stuNo }) => `${GROUP_ID}_${stuNo}`);
const staleClassmates = await firestore
  .collection("classmates")
  .where("group_id", "==", GROUP_ID)
  .get();
await Promise.all(
  staleClassmates.docs
    .filter((doc) => !classmateIds.includes(doc.id))
    .map((doc) => doc.ref.delete()),
);
await Promise.all(
  classmates.map(({ stuNo, name }) =>
    firestore
      .collection("classmates")
      .doc(`${GROUP_ID}_${stuNo}`)
      .set({
        group_id: GROUP_ID,
        role: "student",
        stuNo,
        name,
        email: `student${stuNo}@example.com`,
        slackUserId: "",
      }),
  ),
);

for (const user of testUsers) {
  await upsertUser(user);
  await setMembership(user.uid, user.joined);
}

let allowedUsersFound = 0;
for (const email of config.allowedEmails) {
  const uid = await findUidByEmail(email);
  if (!uid) continue;
  allowedUsersFound++;
  await setMembership(uid, joinAllowedUsers);
}

console.log(
  [
    `groups: 1`,
    `classmates: ${classmates.length}`,
    `test users: ${testUsers.length}`,
    `allowed emails: ${config.allowedEmails.length}`,
    `allowed users ${joinAllowedUsers ? "joined" : "left"}: ${allowedUsersFound}/${config.allowedEmails.length}`,
  ].join("\n"),
);

// 閉じないと gRPC の接続が残り、プロセスが終わらない。
await firestore.terminate();
