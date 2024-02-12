import { DateTime } from "luxon";
import { describe, expect, test, vi } from "vitest";
import { crontab } from "./crontab.js";

describe("crontab", async () => {
  test("should execute the task when the time matches the crontab", async () => {
    const fn = vi.fn();

    const scheduled = crontab("0 * * * *", () =>
      Promise.resolve({ default: fn }),
    );

    await scheduled(DateTime.local(2024, 1, 1, 0, 0, { zone: "asia/tokyo" }));

    expect(fn).toHaveBeenCalledTimes(1);
  });

  test("should not execute the task when the time does not match the crontab", async () => {
    const fn = vi.fn();

    const scheduled = crontab("0 * * * *", () =>
      Promise.resolve({ default: fn }),
    );

    await scheduled(DateTime.local(2024, 1, 1, 0, 1, { zone: "asia/tokyo" }));

    expect(fn).toHaveBeenCalledTimes(0);
  });
});
