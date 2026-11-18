/**
 * Firestore のデータを書き換える移行。scripts/migrations に1本1ファイルで置き、default export する。
 *
 * - 何度流しても同じ結果になるように書く
 * - apply が false のときは書き込まず、書き込むはずの件数だけを数える
 * - 返すのは件数だけ。公開リポジトリの Actions のログに出るので、ID やドキュメントの中身は返さない
 */
export type Migration = (options: {
  apply: boolean;
}) => Promise<Record<string, number>>;
