import { parseArgs } from "node:util";

import { isRoleName, ROLES, type RoleName } from "../../src/authz/roles.js";

export type BindingArgs = {
  uid: string;
  role: RoleName;
  groupId: string;
  project?: string;
  yes: boolean;
};

/** grant と revoke に共通の引数を読む。足りない・形が違うときは使い方を出して終わる */
export const parseBindingArgs = (command: "grant" | "revoke"): BindingArgs => {
  const usage = `使い方:
  pnpm run ${command} -- --subject user:<uid> --role <role> --resource group:<id> [--project <id>] [--yes]

  --role      ${Object.keys(ROLES).join(" / ")}
  --project   省略するとエミュレータに書く`;

  // 制御フロー解析に never を伝えるため、変数側にも型を書く
  const fail: (message: string) => never = (message) => {
    console.error(`${message}\n\n${usage}`);
    process.exit(1);
  };

  const { values } = parseArgs({
    args: process.argv.slice(2).filter((arg, i) => !(i === 0 && arg === "--")),
    options: {
      subject: { type: "string" },
      role: { type: "string" },
      resource: { type: "string" },
      project: { type: "string" },
      yes: { type: "boolean", default: false },
    },
  });

  const { subject, role, resource } = values;

  if (!subject || !role || !resource) {
    fail("--subject / --role / --resource は必須です。");
  }

  const uid = subject.startsWith("user:") ? subject.slice("user:".length) : "";
  if (!uid) {
    fail(`--subject は user:<uid> の形で指定してください: ${subject}`);
  }

  if (!isRoleName(role)) {
    fail(`--role が定義にありません: ${role}`);
  }

  const groupId = resource.startsWith("group:")
    ? resource.slice("group:".length)
    : "";
  if (!groupId) {
    fail(`--resource は group:<id> の形で指定してください: ${resource}`);
  }

  return { uid, role, groupId, project: values.project, yes: values.yes };
};
