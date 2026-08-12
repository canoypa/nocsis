import { parseArgs } from "node:util";
import { isRoleName, ROLES } from "../src/authz/roles.js";

const DEFAULT_EMULATOR_HOST = "localhost:8888";
const DEFAULT_EMULATOR_PROJECT = "demo-nocsis";

const USAGE = `使い方:
  pnpm run grant -- --subject user:<uid> --role <role> --resource group:<id> [--project <id>]

  --role      ${Object.keys(ROLES).join(" / ")}
  --project   省略するとエミュレータに書く`;

// pnpm run は `--` をそのまま渡してくるので、先頭のそれだけ落とす
const args = process.argv.slice(2);
if (args[0] === "--") {
  args.shift();
}

const { values } = parseArgs({
  args,
  options: {
    subject: { type: "string" },
    role: { type: "string" },
    resource: { type: "string" },
    project: { type: "string" },
  },
});

// 制御フロー解析に never を伝えるため、変数側にも型を書く
const fail: (message: string) => never = (message) => {
  console.error(`${message}\n\n${USAGE}`);
  process.exit(1);
};

const { subject, role, resource, project } = values;

if (!subject || !role || !resource) {
  fail("--subject / --role / --resource は必須です。");
}

const uid = subject.startsWith("user:") ? subject.slice("user:".length) : "";
if (!uid) {
  fail(`--subject は user:<uid> の形で指定してください: ${subject}`);
}

// ROLES の型を通すので、綴りを間違えたロールは書き込めない
if (!isRoleName(role)) {
  fail(`--role が定義にありません: ${role}`);
}

const groupId = resource.startsWith("group:")
  ? resource.slice("group:".length)
  : "";
if (!groupId) {
  fail(`--resource は group:<id> の形で指定してください: ${resource}`);
}

// 書き込み先を Admin SDK が読む環境変数に落とす。既定はエミュレータ
if (project) {
  process.env.GOOGLE_CLOUD_PROJECT = project;
} else {
  process.env.FIRESTORE_EMULATOR_HOST ??= DEFAULT_EMULATOR_HOST;
  process.env.GOOGLE_CLOUD_PROJECT = DEFAULT_EMULATOR_PROJECT;
}

const target = process.env.FIRESTORE_EMULATOR_HOST
  ? `エミュレータ ${process.env.FIRESTORE_EMULATOR_HOST}`
  : `プロジェクト ${process.env.GOOGLE_CLOUD_PROJECT}`;

// 書き込み先が決まってから Firestore クライアントを初期化する
const { grant } = await import("../src/authz/binding.js");
const { user } = await import("../src/authz/principal.js");
const { group } = await import("../src/authz/resource.js");

const result = await grant({
  principal: user(uid),
  role,
  resource: group(groupId),
});

console.info(
  result === "created"
    ? `${target} に ${subject} / ${role} / ${resource} を付与しました。`
    : `${target} には ${subject} / ${role} / ${resource} がすでにあります。`,
);
