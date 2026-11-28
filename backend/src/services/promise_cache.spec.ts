import { afterEach, describe, expect, it, vi } from "vitest";

import { createPromiseCache } from "./promise_cache.js";

const options = { ttlMs: 1000, failureTtlMs: 100, maxEntries: 2 };

afterEach(() => {
  vi.useRealTimers();
});

describe("createPromiseCache", () => {
  it("取得中に同じキーで来た要求は、1回の取得にまとめること", async () => {
    const cache = createPromiseCache<string>(options);
    const load = vi.fn(async () => "a");

    const [first, second] = await Promise.all([
      cache.get("k", load),
      cache.get("k", load),
    ]);

    expect([first, second]).toEqual(["a", "a"]);
    expect(load).toHaveBeenCalledTimes(1);
  });

  it("失敗は failureTtlMs が過ぎると取り直すこと", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    const cache = createPromiseCache<string>(options);
    const load = vi.fn(async () => {
      throw new Error("failed");
    });

    await expect(cache.get("k", load)).rejects.toThrow("failed");
    vi.advanceTimersByTime(99);
    await expect(cache.get("k", load)).rejects.toThrow("failed");
    expect(load).toHaveBeenCalledTimes(1);

    vi.advanceTimersByTime(1);
    await expect(cache.get("k", load)).rejects.toThrow("failed");
    expect(load).toHaveBeenCalledTimes(2);
  });

  it("maxEntries を超えると、いちばん長く使っていないキーから捨てること", async () => {
    const cache = createPromiseCache<string>(options);
    const load = vi.fn(async () => "v");

    await cache.get("a", load);
    await cache.get("b", load);
    await cache.get("a", load);
    await cache.get("c", load);
    expect(load).toHaveBeenCalledTimes(3);

    await cache.get("a", load);
    await cache.get("c", load);
    expect(load).toHaveBeenCalledTimes(3);

    await cache.get("b", load);
    expect(load).toHaveBeenCalledTimes(4);
  });

  it("load がその場で投げても、失敗した Promise として返すこと", async () => {
    const cache = createPromiseCache<string>(options);

    await expect(
      cache.get("k", () => {
        throw new Error("failed");
      }),
    ).rejects.toThrow("failed");
  });
});
