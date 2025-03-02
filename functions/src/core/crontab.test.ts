import { DateTime } from "luxon";
import { describe, expect, it, vi } from "vitest";
import { crontab } from "./crontab.js";

describe("crontab", async () => {
  describe("時刻が JST の場合", () => {
    describe("分指定の場合", () => {
      describe("時刻が crontab に一致する場合", () => {
        it("実行されること", async () => {
          const fn = vi.fn();

          const scheduled = crontab("5 * * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T07:05:00.000+09:00"));
          await scheduled(DateTime.fromISO("2025-03-02T07:05:01.000+09:00")); // 秒の違いは無視される

          expect(fn).toHaveBeenCalledTimes(2);
        });
      });

      describe("時刻が crontab に一致しない場合", () => {
        it("実行されないこと", async () => {
          const fn = vi.fn();

          const scheduled = crontab("5 * * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T07:04:00.000+09:00"));
          await scheduled(DateTime.fromISO("2025-03-02T07:06:00.000+09:00"));

          expect(fn).toHaveBeenCalledTimes(0);
        });
      });
    });

    describe("時指定の場合", () => {
      describe("時刻が crontab に一致する場合", () => {
        it("実行されること", async () => {
          const fn = vi.fn();

          const scheduled = crontab("0 5 * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T05:00:00.000+09:00"));
          await scheduled(DateTime.fromISO("2025-03-02T05:00:01.000+09:00")); // 秒の違いは無視される

          expect(fn).toHaveBeenCalledTimes(2);
        });
      });

      describe("時刻が crontab に一致しない場合", () => {
        it("実行されないこと", async () => {
          const fn = vi.fn();

          const scheduled = crontab("0 5 * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T04:00:00.000+09:00"));
          await scheduled(DateTime.fromISO("2025-03-02T06:00:00.000+09:00"));

          expect(fn).toHaveBeenCalledTimes(0);
        });
      });
    });
  });

  describe("時刻が UTC の場合", () => {
    describe("分指定の場合", () => {
      describe("時刻が crontab に一致する場合", () => {
        it("実行されること", async () => {
          const fn = vi.fn();

          const scheduled = crontab("5 * * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T07:05:00.000Z"));
          await scheduled(DateTime.fromISO("2025-03-02T07:05:01.000Z")); // 秒の違いは無視される

          expect(fn).toHaveBeenCalledTimes(2);
        });
      });

      describe("時刻が crontab に一致しない場合", () => {
        it("実行されないこと", async () => {
          const fn = vi.fn();

          const scheduled = crontab("5 * * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T07:04:00.000Z"));
          await scheduled(DateTime.fromISO("2025-03-02T07:06:00.000Z"));

          expect(fn).toHaveBeenCalledTimes(0);
        });
      });
    });

    describe("時指定の場合", () => {
      describe("時刻が crontab に一致する場合", () => {
        it("実行されること", async () => {
          const fn = vi.fn();

          const scheduled = crontab("0 5 * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-01T20:00:00.000Z"));
          await scheduled(DateTime.fromISO("2025-03-01T20:00:01.000Z")); // 秒の違いは無視される

          expect(fn).toHaveBeenCalledTimes(2);
        });
      });

      describe("時刻が crontab に一致しない場合", () => {
        it("実行されないこと", async () => {
          const fn = vi.fn();

          const scheduled = crontab("0 5 * * *", () =>
            Promise.resolve({ default: fn }),
          );

          await scheduled(DateTime.fromISO("2025-03-02T04:00:00.000Z"));
          await scheduled(DateTime.fromISO("2025-03-02T06:00:00.000Z"));

          expect(fn).toHaveBeenCalledTimes(0);
        });
      });
    });
  });
});
