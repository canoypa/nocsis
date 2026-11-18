// 本番や Staging に書くスクリプトの、書き込み先の決め方をそろえる。
//
// 既定はエミュレータ。実プロジェクトには --project を明示したときだけ書き、
// 端末からなら同じ ID をもう一度打たせる。端末でない (Actions など) ときは --yes が要る。
import assert from "node:assert";
import { createInterface } from "node:readline/promises";

const DEFAULT_EMULATOR_HOST = "127.0.0.1:8888";
const DEFAULT_EMULATOR_PROJECT = "demo-nocsis";

export const selectTarget = async (options: {
  project?: string;
  yes?: boolean;
}): Promise<string> => {
  const { project, yes } = options;

  if (!project) {
    process.env.FIRESTORE_EMULATOR_HOST ??= DEFAULT_EMULATOR_HOST;
    process.env.GOOGLE_CLOUD_PROJECT = DEFAULT_EMULATOR_PROJECT;
    return `エミュレータ ${process.env.FIRESTORE_EMULATOR_HOST}`;
  }

  // 残っていると、実プロジェクトのつもりでエミュレータに書いて「成功」してしまう。
  assert(
    !process.env.FIRESTORE_EMULATOR_HOST,
    "--project を付けるときは FIRESTORE_EMULATOR_HOST を外す",
  );
  // initializeApp() は GOOGLE_CLOUD_PROJECT より FIREBASE_CONFIG を先に見るので、確かめた ID と書き先がずれる。
  assert(
    !process.env.FIREBASE_CONFIG,
    "--project を付けるときは FIREBASE_CONFIG を外す",
  );
  process.env.GOOGLE_CLOUD_PROJECT = project;

  if (!yes) {
    assert(
      process.stdin.isTTY,
      "端末でないときは、確認の代わりに --yes を付ける",
    );
    const rl = createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    const answer = await rl.question(
      `プロジェクト ${project} を対象にします。確認のため ID をもう一度入力してください: `,
    );
    rl.close();
    assert(answer.trim() === project, "ID が一致しないので中止しました");
  }

  return `プロジェクト ${project}`;
};
