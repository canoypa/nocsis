import assert from "node:assert";
import { type SourceMapInput, TraceMap } from "@jridgewell/trace-mapping";
import { GoogleAuth } from "google-auth-library";

export type SourceMapFile = "main.dart.js.map" | "main.dart.wasm.map";

const auth = new GoogleAuth({
  scopes: ["https://www.googleapis.com/auth/devstorage.read_only"],
});

// 1 つ 1.5MB ほどある。リリースは同時に 1〜2 個しか動いていないので、少しだけ持つ。
const CACHE_LIMIT = 4;
const cache = new Map<string, TraceMap | null>();

/**
 * フロントエンドのソースマップを置くバケットの名前
 *
 * Terraform がプロジェクトごとにこの名前で作る
 */
export const sourceMapBucketName = (): string => {
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");

  return `${projectId}-frontend-source-maps`;
};

const download = async (
  commit: string,
  file: SourceMapFile,
): Promise<TraceMap | null> => {
  const object = encodeURIComponent(`${commit}/${file}`);
  const url = `https://storage.googleapis.com/storage/v1/b/${sourceMapBucketName()}/o/${object}?alt=media`;

  const client = await auth.getClient();
  const { token } = await client.getAccessToken();
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });

  // 古いビルドや、ソースマップを置く前のビルドから届くことがある
  if (response.status === 404) return null;
  if (!response.ok) {
    throw new Error(`ソースマップを取得できませんでした: ${response.status}`);
  }

  return new TraceMap((await response.json()) as SourceMapInput);
};

/**
 * ビルドの commit に対応するソースマップを取得する
 *
 * @param commit フロントエンドをビルドした commit (40 桁の SHA)
 * @param file ソースマップのファイル名
 * @returns 見つからなければ null
 */
export const fetchSourceMap = async (
  commit: string,
  file: SourceMapFile,
): Promise<TraceMap | null> => {
  assert(/^[0-9a-f]{40}$/.test(commit), "commit は 40 桁の SHA");

  const key = `${commit}/${file}`;
  if (cache.has(key)) {
    const cached = cache.get(key) ?? null;
    // 最近使ったものを後ろに回し、古いものから捨てる
    cache.delete(key);
    cache.set(key, cached);
    return cached;
  }

  const map = await download(commit, file);

  cache.set(key, map);
  if (cache.size > CACHE_LIMIT) {
    const oldest = cache.keys().next().value;
    if (oldest !== undefined) cache.delete(oldest);
  }

  return map;
};

/**
 * キャッシュをクリアする
 * テストでしか使ってない
 */
export const clearSourceMapCache = (): void => {
  cache.clear();
};
