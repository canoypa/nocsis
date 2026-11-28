import assert from "node:assert";
import { Worker } from "node:worker_threads";

import { GoogleAuth } from "google-auth-library";

import { AppConfig } from "../config/app_config.js";
import type {
  GeneratedPosition,
  OriginalPosition,
  SourceMapCommand,
  SourceMapReply,
  SourceMapRequest,
} from "./source_map_worker.js";

export type { GeneratedPosition, OriginalPosition };

export type SourceMapFile = "main.dart.js.map" | "main.dart.wasm.map";

const auth = new GoogleAuth({
  scopes: ["https://www.googleapis.com/auth/devstorage.read_only"],
});

// 取り込み中のものを持ち、同じエラーが一斉に届いても 1 回だけ取りに行く。
// 値は、最初に頼んだ要求の位置を引いた結果 (見つからなければ null)。
const loading = new Map<string, Promise<OriginalPosition[] | null>>();

// 取れなかったものは短く覚え、そのあいだは取りに行かない。アップロードが
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

type SourceMapWorker = {
  request: (
    command: SourceMapCommand,
    transfer?: ArrayBuffer[],
  ) => Promise<OriginalPosition[] | null>;
  terminate: () => Promise<number>;
};

// 解析と引き当てはメインスレッドでしない。メインスレッドで解析すると、そのあいだほかの要求が待たされる。
// src から動かすとき (テスト、tsx) は .ts を、ビルドしたものは dist の .js を読む。
const WORKER_URL = new URL(
  import.meta.url.endsWith(".ts")
    ? "./source_map_worker.ts"
    : "./source_map_worker.js",
  import.meta.url,
);

let currentWorker: SourceMapWorker | undefined;

const startWorker = (): SourceMapWorker => {
  const worker = new Worker(WORKER_URL);
  worker.unref();

  let nextId = 0;
  const pending = new Map<
    number,
    {
      resolve: (positions: OriginalPosition[] | null) => void;
      reject: (error: Error) => void;
    }
  >();

  worker.on("message", (reply: SourceMapReply) => {
    const request = pending.get(reply.id);
    if (!request) return;
    pending.delete(reply.id);
    if (pending.size === 0) worker.unref();

    if (reply.ok) request.resolve(reply.positions);
    else request.reject(new Error(reply.error));
  });
  worker.on("error", (error) => {
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        message: `ソースマップのワーカーが止まった: ${error}`,
      }),
    );
  });
  worker.on("exit", () => {
    if (currentWorker === self) currentWorker = undefined;

    for (const request of pending.values()) {
      request.reject(new Error("ソースマップのワーカーが止まった"));
    }
    pending.clear();
  });

  const self: SourceMapWorker = {
    request: (command, transfer) => {
      const id = nextId++;
      worker.postMessage({ id, command } satisfies SourceMapRequest, transfer);
      worker.ref();

      return new Promise<OriginalPosition[] | null>((resolve, reject) => {
        pending.set(id, { resolve, reject });
      });
    },
    terminate: () => worker.terminate(),
  };

  return self;
};

const sourceMapWorker = (): SourceMapWorker => {
  currentWorker ??= startWorker();
  return currentWorker;
};

class SourceMapNotFound extends Error {}

const download = async (
  commit: string,
  file: SourceMapFile,
): Promise<ArrayBuffer> => {
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

  return response.arrayBuffer();
};

const rememberMiss = (key: string) => {
  misses.set(key, Date.now());
  if (misses.size > MISS_LIMIT) {
    const oldest = misses.keys().next().value;
    if (oldest !== undefined) misses.delete(oldest);
  }
};

const load = async (
  commit: string,
  file: SourceMapFile,
  key: string,
  positions: GeneratedPosition[],
): Promise<OriginalPosition[] | null> => {
  try {
    const bytes = await download(commit, file);
    // 読み込みと引き当てを分けて頼まない。そのあいだに、ほかの読み込みで捨てられることがある
    return await sourceMapWorker().request(
      { type: "load", key, bytes, positions },
      [bytes],
    );
  } catch (error) {
    // 壊れたソースマップや、読み込むとワーカーが落ちるものも、しばらく読み込ませない
    rememberMiss(key);
    if (error instanceof SourceMapNotFound) return null;
    throw error;
  }
};

/**
 * ビルドのソースマップで、生成されたコードの位置を元のソースの位置に戻す
 *
 * ソースマップはバケットから取ってワーカーに読み込み、しばらく使い回す。
 *
 * @param commit フロントエンドをビルドした commit (40 桁の SHA)
 * @param file ソースマップのファイル名
 * @param positions 戻したい位置
 * @returns positions と同じ順の結果。ソースマップが見つからなければ null。取得に失敗したときは例外 (その後しばらくは null)
 */
export const originalPositionsFor = async (
  commit: string,
  file: SourceMapFile,
  positions: GeneratedPosition[],
): Promise<OriginalPosition[] | null> => {
  assert(/^[0-9a-f]{40}$/.test(commit), "commit は 40 桁の SHA");

  const key = `${commit}/${file}`;

  const loaded = await sourceMapWorker().request({
    type: "lookup",
    key,
    positions,
  });
  if (loaded) return loaded;

  const missedAt = misses.get(key);
  if (missedAt !== undefined) {
    if (Date.now() - missedAt < MISS_TTL_MS) return null;
    misses.delete(key);
  }

  const current = loading.get(key);
  if (!current) {
    const started = load(commit, file, key, positions);
    loading.set(key, started);
    const settle = () => {
      if (loading.get(key) === started) loading.delete(key);
    };
    started.then(settle, settle);
    return started;
  }

  if (!(await current)) return null;
  const found = await sourceMapWorker().request({
    type: "lookup",
    key,
    positions,
  });
  if (!found) throw new Error("読み込んだソースマップが、引く前に捨てられた");
  return found;
};

/**
 * 読み込んだソースマップと、取れなかった記録を捨てる
 * テストでしか使ってない
 */
export const clearSourceMapCache = async (): Promise<void> => {
  loading.clear();
  misses.clear();

  const worker = currentWorker;
  currentWorker = undefined;
  await worker?.terminate();
};
