import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describe, expect, it, vi } from "vitest";

import { CLIENT_COMMIT_HEADER, logRequest } from "./log_request.js";

const COMMIT = "0123456789abcdef0123456789abcdef01234567";

const app = new Hono()
  .use("*", logRequest)
  .get("/groups/:id", (c) => c.json({ id: c.req.param("id") }))
  .get("/forbidden", () => {
    throw new HTTPException(403);
  });

const loggedEntries = (spy: { mock: { calls: unknown[][] } }) =>
  spy.mock.calls.map(([line]) => JSON.parse(String(line)));

describe("logRequest", () => {
  it("画面の commit と、ID を含まないルートを残すこと", async () => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    await app.request("/groups/abc", {
      headers: { [CLIENT_COMMIT_HEADER]: COMMIT },
    });

    expect(loggedEntries(log)).toEqual([
      {
        severity: "INFO",
        message: "リクエストを受けた",
        method: "GET",
        route: "/groups/:id",
        status: 200,
        clientCommit: COMMIT,
      },
    ]);
  });

  it("ヘッダーが無いときは null にすること", async () => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    await app.request("/groups/abc");

    expect(loggedEntries(log)[0].clientCommit).toBeNull();
  });

  it("SHA でない値はそのまま残さないこと", async () => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    await app.request("/groups/abc", {
      headers: { [CLIENT_COMMIT_HEADER]: "a".repeat(10_000) },
    });

    expect(loggedEntries(log)[0].clientCommit).toBe("invalid");
  });

  it("エラーで返したリクエストも、その status で残すこと", async () => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    await app.request("/forbidden", {
      headers: { [CLIENT_COMMIT_HEADER]: COMMIT },
    });

    expect(loggedEntries(log)[0]).toMatchObject({
      route: "/forbidden",
      status: 403,
    });
  });
});
