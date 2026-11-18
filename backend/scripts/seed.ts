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

const escapeRegExp = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

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
      // パスワードがあると、Staging のログインが Cano さんのアカウントだけに閉じなくなる。
      memberPassword: undefined,
      allowedEmails: parseEmails(required("SEED_ALLOWED_EMAILS")),
    };
// 外すと、グループに参加していない画面を確かめられる。
const joinAllowedUsers = env.SEED_JOIN_ALLOWED_USERS !== "false";

const app = initializeApp({ projectId });
const auth = getAuth(app);
const firestore = getFirestore(app);

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
  const memberships = firestore.collection("user_joined_groups");
  const snapshot = await memberships
    .where("user_id", "==", uid)
    .where("group_id", "==", GROUP_ID)
    .get();

  if (!joined) {
    await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
    return;
  }
  if (snapshot.empty) {
    await memberships
      .doc(`${GROUP_ID}_${uid}`)
      .set({ user_id: uid, group_id: GROUP_ID });
  }
};

// エラーの文言にメールアドレスが入りうるので、コードだけを返す。
const findUidByEmail = async (email: string) => {
  try {
    return (await auth.getUserByEmail(email)).uid;
  } catch (error) {
    const code = errorCode(error);
    if (code === "auth/user-not-found") return undefined;
    throw new Error(`ユーザーを引けませんでした (${code ?? "unknown"})`);
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
if (config.allowedEmails.length > 0) {
  // blocking function は ^...$ でアンカーされたパターンしか受け付けない。
  await firestore.doc("environment/allowed_emails").set({
    values: config.allowedEmails.map((email) => `^${escapeRegExp(email)}$`),
  });

  for (const email of config.allowedEmails) {
    const uid = await findUidByEmail(email);
    if (!uid) continue;
    allowedUsersFound++;
    await setMembership(uid, joinAllowedUsers);
  }
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
