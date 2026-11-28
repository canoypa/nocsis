import {
  GREATEST_LOWER_BOUND,
  originalPositionFor,
  type TraceMap,
} from "@jridgewell/trace-mapping";

import { AppConfig } from "../config/app_config.js";
import { fetchSourceMap, type SourceMapFile } from "./source_map_service.js";

export type DecodedFrame = {
  raw: string;
  /** リポジトリのルートからのパス。アプリのコードでなければ undefined */
  path?: string;
  /** ソースマップに書かれたままのパス */
  source?: string;
  line?: number;
  /** 1 から数える */
  column?: number;
  functionName?: string;
  githubUrl?: string;
};

type Position =
  | { file: "main.dart.js.map"; line: number; column: number }
  | { file: "main.dart.wasm.map"; offset: number };

// wasm は V8 の `main.dart.wasm:wasm-function[12]:0xabc`、dart2js は `main.dart.js:12:34`。
// dart2js の行は V8 でも Safari / Firefox でも `ファイル:行:列` で終わる。
const WASM_FRAME = /\/main\.dart\.wasm:wasm-function\[\d+\]:0x([0-9a-f]+)/i;
const JS_FRAME = /\/main\.dart\.js:(\d+):(\d+)/;

const parsePosition = (frame: string): Position | null => {
  const wasm = WASM_FRAME.exec(frame);
  if (wasm) {
    return {
      file: "main.dart.wasm.map",
      offset: Number.parseInt(wasm[1], 16),
    };
  }

  const js = JS_FRAME.exec(frame);
  if (js) {
    return {
      file: "main.dart.js.map",
      line: Number(js[1]),
      column: Number(js[2]),
    };
  }

  return null;
};

/**
 * ソースマップのパスを、リポジトリのルートからのパスにする
 *
 * wasm は CI の絶対パス (`file:///…/frontend/lib/…`)、dart2js は相対パス (`../../../lib/…`) で書かれる。
 * Flutter や pub のパッケージはリポジトリに無いので undefined を返す。
 */
export const toRepositoryPath = (source: string): string | undefined => {
  const absolute = /\/frontend\/(lib\/.+)$/.exec(source);
  if (absolute) return `frontend/${absolute[1]}`;

  const relative = source.replace(/^(\.\.\/)+/, "");
  if (relative.startsWith("lib/")) return `frontend/${relative}`;

  return undefined;
};

const decodeFrame = (
  raw: string,
  position: Position,
  map: TraceMap,
  commit: string,
): DecodedFrame => {
  // wasm のソースマップは 1 行で、列がモジュール先頭からのバイトオフセット
  const original =
    position.file === "main.dart.wasm.map"
      ? originalPositionFor(map, {
          line: 1,
          column: position.offset,
          bias: GREATEST_LOWER_BOUND,
        })
      : originalPositionFor(map, {
          line: position.line,
          column: position.column - 1,
          bias: GREATEST_LOWER_BOUND,
        });

  if (original.source === null || original.line === null) return { raw };

  const path = toRepositoryPath(original.source);

  return {
    raw,
    path,
    source: original.source,
    line: original.line,
    column: original.column === null ? undefined : original.column + 1,
    functionName: original.name ?? undefined,
    githubUrl: path
      ? `${AppConfig.REPOSITORY_URL}/blob/${commit}/${path}#L${original.line}`
      : undefined,
  };
};

const fetchSourceMapOrNull = async (
  commit: string,
  file: SourceMapFile,
): Promise<TraceMap | null> => {
  try {
    return await fetchSourceMap(commit, file);
  } catch (error) {
    // 解読できなくても、エラーが起きたこと自体は残す
    console.warn(
      JSON.stringify({
        severity: "WARNING",
        message: `ソースマップを取得できなかった: ${error}`,
      }),
    );
    return null;
  }
};

/**
 * ブラウザのスタックトレースを、ビルドのソースマップで Dart の位置に戻す
 *
 * @param stack ブラウザから届いたスタックトレース
 * @param commit フロントエンドをビルドした commit
 * @returns 1 行ずつの結果。戻せなかった行は raw だけを持つ
 */
export const decodeStack = async (
  stack: string,
  commit: string,
): Promise<DecodedFrame[]> => {
  const lines = stack
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line !== "");

  const maps = new Map<SourceMapFile, TraceMap | null>();
  const frames: DecodedFrame[] = [];

  for (const raw of lines) {
    const position = parsePosition(raw);
    if (!position) {
      frames.push({ raw });
      continue;
    }

    if (!maps.has(position.file)) {
      maps.set(
        position.file,
        await fetchSourceMapOrNull(commit, position.file),
      );
    }
    const map = maps.get(position.file);

    frames.push(map ? decodeFrame(raw, position, map, commit) : { raw });
  }

  return frames;
};
