import { parentPort } from "node:worker_threads";

import {
  GREATEST_LOWER_BOUND,
  originalPositionFor,
  type SourceMapInput,
  TraceMap,
} from "@jridgewell/trace-mapping";

/** line は 1 から、column は 0 から数える */
export type GeneratedPosition = { line: number; column: number };

export type OriginalPosition = {
  source: string | null;
  line: number | null;
  column: number | null;
  name: string | null;
};

/** load は読み込んだうえで positions を引く */
export type SourceMapCommand =
  | {
      type: "load";
      key: string;
      bytes: ArrayBuffer;
      positions: GeneratedPosition[];
    }
  | { type: "lookup"; key: string; positions: GeneratedPosition[] };

export type SourceMapRequest = { id: number; command: SourceMapCommand };

/** lookup で、読み込んでいないソースマップなら positions は null */
export type SourceMapReply =
  | { id: number; ok: true; positions: OriginalPosition[] | null }
  | { id: number; ok: false; error: string };

// 1 つ 3.5MB ほどある。リリースは同時に 1〜2 個しか動いていないので、少しだけ持つ。
const CACHE_LIMIT = 4;
const maps = new Map<string, TraceMap>();

const UNKNOWN: OriginalPosition = {
  source: null,
  line: null,
  column: null,
  name: null,
};

const lookup = (map: TraceMap, position: GeneratedPosition) => {
  try {
    const { source, line, column, name } = originalPositionFor(map, {
      ...position,
      bias: GREATEST_LOWER_BOUND,
    });
    return { source, line, column, name };
  } catch {
    // 行が 0 などの、ありえない位置
    return UNKNOWN;
  }
};

const run = (command: SourceMapCommand): OriginalPosition[] | null => {
  switch (command.type) {
    case "load": {
      const json = JSON.parse(new TextDecoder().decode(command.bytes));
      const map = new TraceMap(json as SourceMapInput);
      maps.delete(command.key);
      maps.set(command.key, map);
      if (maps.size > CACHE_LIMIT) {
        const oldest = maps.keys().next().value;
        if (oldest !== undefined) maps.delete(oldest);
      }
      return command.positions.map((position) => lookup(map, position));
    }
    case "lookup": {
      const map = maps.get(command.key);
      if (!map) return null;

      // 最近使ったものを後ろに回し、古いものから捨てる
      maps.delete(command.key);
      maps.set(command.key, map);
      return command.positions.map((position) => lookup(map, position));
    }
  }
};

parentPort?.on("message", ({ id, command }: SourceMapRequest) => {
  try {
    parentPort?.postMessage({
      id,
      ok: true,
      positions: run(command),
    } satisfies SourceMapReply);
  } catch (error) {
    parentPort?.postMessage({
      id,
      ok: false,
      error: String(error),
    } satisfies SourceMapReply);
  }
});
