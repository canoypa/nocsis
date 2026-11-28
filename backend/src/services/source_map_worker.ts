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

// 数で区切らない。ソースマップが育つと、同じ数でも使うメモリが増える。
const LOADED_BYTES_LIMIT = 12 * 1024 * 1024;
const maps = new Map<string, { map: TraceMap; bytes: number }>();

const loadedBytes = () =>
  [...maps.values()].reduce((sum, { bytes }) => sum + bytes, 0);

/** 古いものから捨てて、bytes を読み込める空きを作る */
const makeRoom = (bytes: number) => {
  for (const key of maps.keys()) {
    if (loadedBytes() + bytes <= LOADED_BYTES_LIMIT) return;
    maps.delete(key);
  }
};

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
      const bytes = command.bytes.byteLength;
      maps.delete(command.key);
      makeRoom(bytes);

      const json = JSON.parse(new TextDecoder().decode(command.bytes));
      const map = new TraceMap(json as SourceMapInput);
      maps.set(command.key, { map, bytes });
      return command.positions.map((position) => lookup(map, position));
    }
    case "lookup": {
      const loaded = maps.get(command.key);
      if (!loaded) return null;

      // 最近使ったものを後ろに回し、古いものから捨てる
      maps.delete(command.key);
      maps.set(command.key, loaded);
      const { map } = loaded;
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
