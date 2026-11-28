export interface PromiseCacheOptions {
  ttlMs: number;
  failureTtlMs: number;
  maxEntries: number;
}

export interface PromiseCache<T> {
  get: (key: string, load: () => Promise<T>) => Promise<T>;
  clear: () => void;
}

/**
 * 外部 API の結果を、キーごとに決まった時間だけ使い回す
 *
 * 取得中の Promise も持つので、同時に来た同じ要求は1回の取得にまとまる。
 * 返す値はほかの要求と同じものなので、書き換えない。
 */
export const createPromiseCache = <T>({
  ttlMs,
  failureTtlMs,
  maxEntries,
}: PromiseCacheOptions): PromiseCache<T> => {
  const entries = new Map<string, { expiresAt: number; value: Promise<T> }>();

  return {
    get: (key, load) => {
      const now = Date.now();

      // 使ったキーは入れ直して、追い出す順を最後にする
      const hit = entries.get(key);
      entries.delete(key);
      if (hit && hit.expiresAt > now) {
        entries.set(key, hit);
        return hit.value;
      }

      const value = new Promise<T>((resolve) => resolve(load()));
      const entry = { expiresAt: now + ttlMs, value };
      entries.set(key, entry);

      if (entries.size > maxEntries) {
        const oldest = entries.keys().next();
        if (!oldest.done) entries.delete(oldest.value);
      }

      // 失敗を TTL いっぱい残すと復旧後も長くエラーを返し、すぐ消すと API が制限中でも呼び続ける
      value.catch(() => {
        entry.expiresAt = Math.min(entry.expiresAt, Date.now() + failureTtlMs);
      });

      return value;
    },
    clear: () => {
      entries.clear();
    },
  };
};
