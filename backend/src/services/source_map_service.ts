import assert from "node:assert";
import { type SourceMapInput, TraceMap } from "@jridgewell/trace-mapping";
import { GoogleAuth } from "google-auth-library";
import { AppConfig } from "../config/app_config.js";

export type SourceMapFile = "main.dart.js.map" | "main.dart.wasm.map";

const auth = new GoogleAuth({
  scopes: ["https://www.googleapis.com/auth/devstorage.read_only"],
});

// 1 つ 3.5MB ほどある。リリースは同時に 1〜2 個しか動いていないので、少しだけ持つ。
const CACHE_LIMIT = 4;
// 取り込み中の分も持ち、同じエラーが一斉に届いても 1 回だけ取りに行く。
const cache = new Map<string, Promise<TraceMap | null>>();

// 取れなかったものは別に短く覚える。誰でも送れるので、存在しない commit で
// 本物のソースマップを cache から追い出せないようにする。アップロードが
// 遅れた場合に備えて、時間が経てば取り直す。
const MISS_TTL_MS = 5 * 60_000;
const MISS_LIMIT = 100;
const misses = new Map<string, number>();

const FETCH_TIMEOUT_MS = 5_000;

/**
 * フロントエンドのソースマップを置くバケットの名前
 *
 * Terraform がプロジェクトごとにこの名前で作る
 */
export const sourceMapBucketName = (): string => {
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");

  return `${projectId}-${AppConfig.SOURCE_MAP_BUCKET_SUFFIX}`;
};

class SourceMapNotFound extends Error {}

const download = async (
  commit: string,
  file: SourceMapFile,
): Promise<TraceMap> => {
  const object = encodeURIComponent(`${commit}/${file}`);
  const url = `https://storage.googleapis.com/storage/v1/b/${sourceMapBucketName()}/o/${object}?alt=media`;

  const client = await auth.getClient();
  const { token } = await client.getAccessToken();
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
  });

  // 古いビルドや、ソースマップを置く前のビルドから届くことがある
  if (response.status === 404) throw new SourceMapNotFound();
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
 * @returns 見つからなければ null。取得に失敗したときは例外 (その後しばらくは null)
 */
export const fetchSourceMap = async (
  commit: string,
  file: SourceMapFile,
): Promise<TraceMap | null> => {
  assert(/^[0-9a-f]{40}$/.test(commit), "commit は 40 桁の SHA");

  const key = `${commit}/${file}`;

  const missedAt = misses.get(key);
  if (missedAt !== undefined) {
    if (Date.now() - missedAt < MISS_TTL_MS) return null;
    misses.delete(key);
  }

  const cached = cache.get(key);
  if (cached) {
    // 最近使ったものを後ろに回し、古いものから捨てる
    cache.delete(key);
    cache.set(key, cached);
    return cached;
  }

  const pending = download(commit, file).catch((error: unknown) => {
    if (cache.get(key) === pending) cache.delete(key);
    misses.set(key, Date.now());
    if (misses.size > MISS_LIMIT) {
      const oldest = misses.keys().next().value;
      if (oldest !== undefined) misses.delete(oldest);
    }

    if (error instanceof SourceMapNotFound) return null;
    throw error;
  });
  cache.set(key, pending);
  if (cache.size > CACHE_LIMIT) {
    const oldest = cache.keys().next().value;
    if (oldest !== undefined) cache.delete(oldest);
  }

  return pending;
};

/**
 * キャッシュをクリアする
 * テストでしか使ってない
 */
export const clearSourceMapCache = (): void => {
  cache.clear();
  misses.clear();
};
