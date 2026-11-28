import { AppConfig } from "../config/app_config.js";
import {
  type GeneratedPosition,
  type OriginalPosition,
  originalPositionsFor,
  type SourceMapFile,
} from "./source_map_service.js";

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

// wasm のソースマップは 1 行で、列がモジュール先頭からのバイトオフセット
const toGeneratedPosition = (position: Position): GeneratedPosition =>
  position.file === "main.dart.wasm.map"
    ? { line: 1, column: position.offset }
    : { line: position.line, column: position.column - 1 };

const toDecodedFrame = (
  raw: string,
  original: OriginalPosition,
  commit: string,
): DecodedFrame => {
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

const warn = (message: string) =>
  console.warn(JSON.stringify({ severity: "WARNING", message }));

const originalPositionsOrNull = async (
  commit: string,
  file: SourceMapFile,
  positions: GeneratedPosition[],
): Promise<OriginalPosition[] | null> => {
  try {
    return await originalPositionsFor(commit, file, positions);
  } catch (error) {
    // 解読できなくても、エラーが起きたこと自体は残す
    warn(`ソースマップで位置を戻せなかった: ${error}`);
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

  const frames: DecodedFrame[] = lines.map((raw) => ({ raw }));

  // ファイルごとにまとめ、先に出てきたファイルから取りに行く
  const byFile = new Map<
    SourceMapFile,
    { index: number; position: Position }[]
  >();
  for (const [index, raw] of lines.entries()) {
    const position = parsePosition(raw);
    if (!position) continue;
    byFile.set(position.file, [
      ...(byFile.get(position.file) ?? []),
      { index, position },
    ]);
  }

  for (const [file, entries] of byFile) {
    const originals = await originalPositionsOrNull(
      commit,
      file,
      entries.map(({ position }) => toGeneratedPosition(position)),
    );
    if (!originals) continue;

    for (const [i, { index }] of entries.entries()) {
      frames[index] = toDecodedFrame(lines[index], originals[i], commit);
    }
  }

  return frames;
};
