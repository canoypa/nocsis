import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { jsSourceMap } from "../../../tests/fixtures/source_maps.js";
import {
  CLOUD_STORAGE_OBJECT_URL,
  externalApiServer,
  useExternalApiServer,
} from "../../../tests/helpers/external_apis.js";
import { app } from "../../routes.js";
import { clearSourceMapCache } from "../../services/source_map_service.js";
import { resetClientErrorRateLimit } from "./client_errors_controller.js";

const COMMIT = "0123456789abcdef0123456789abcdef01234567";

useExternalApiServer();

const validBody = {
  message: "SampleException: わざと起こしたエラー",
  stack: "    at Object.a0v (https://nocsis.app/main.dart.js:10:5)",
  commit: COMMIT,
  compiler: "dart2js",
  path: "/groups/abc",
};

const post = (body: unknown) =>
  app.request("/api/v1/client-errors", {
    method: "POST",
    headers: { "Content-Type": "application/json", "User-Agent": "test-ua" },
    body: JSON.stringify(body),
  });

// リクエストごとのログも同じ console.log に出るので、エラーの報告だけを見る
const reportedErrors = (spy: { mock: { calls: unknown[][] } }) =>
  spy.mock.calls
    .map((call) => JSON.parse(String(call[0])))
    .filter((entry) => entry.severity === "ERROR");

beforeEach(() => {
  clearSourceMapCache();
  resetClientErrorRateLimit();
  externalApiServer.use(
    http.get(CLOUD_STORAGE_OBJECT_URL, () => HttpResponse.json(jsSourceMap)),
  );
});

describe("POST /api/v1/client-errors", () => {
  it("解読したエラーを Error Reporting の形でログに書き、204 を返すこと", async () => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    const res = await post(validBody);

    expect(res.status).toBe(204);
    expect(reportedErrors(log)).toEqual([
      {
        severity: "ERROR",
        "@type":
          "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent",
        message:
          "SampleException: わざと起こしたエラー\n    at deepFunctionThatFails (frontend/lib/main.dart:26:15)",
        serviceContext: { service: "frontend", version: COMMIT },
        context: {
          httpRequest: { url: "/groups/abc", userAgent: "test-ua" },
          reportLocation: {
            filePath: "frontend/lib/main.dart",
            lineNumber: 26,
            functionName: "deepFunctionThatFails",
          },
        },
        compiler: "dart2js",
        githubUrl: `https://github.com/canoypa/nocsis/blob/${COMMIT}/frontend/lib/main.dart#L26`,
        rawStack: validBody.stack,
      },
    ]);
  });

  it("ソースマップが取れなくても、生のスタックでエラーを記録すること", async () => {
    externalApiServer.use(
      http.get(CLOUD_STORAGE_OBJECT_URL, () =>
        HttpResponse.json({}, { status: 500 }),
      ),
    );
    const log = vi.spyOn(console, "log").mockImplementation(() => {});
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});

    const res = await post(validBody);

    expect(res.status).toBe(204);
    expect(warn).toHaveBeenCalledOnce();
    const [entry] = reportedErrors(log);
    expect(entry.message).toBe(
      "SampleException: わざと起こしたエラー\n    at Object.a0v (https://nocsis.app/main.dart.js:10:5)",
    );
    expect(entry.context.reportLocation).toEqual({
      filePath: "unknown",
      lineNumber: 0,
      functionName: "unknown",
    });
  });

  it.each([
    ["commit が SHA でない", { ...validBody, commit: "../../secret" }],
    ["compiler が不明", { ...validBody, compiler: "native" }],
    ["message が長すぎる", { ...validBody, message: "a".repeat(2001) }],
  ])("%s ときは 400 を返し、記録しないこと", async (_, body) => {
    const log = vi.spyOn(console, "log").mockImplementation(() => {});

    const res = await post(body);

    expect(res.status).toBe(400);
    expect(reportedErrors(log)).toEqual([]);
  });

  it("32KB を超える本文は 413 を返すこと", async () => {
    const res = await post({ ...validBody, padding: "a".repeat(33 * 1024) });

    expect(res.status).toBe(413);
  });

  it("1 分に 60 件を超えたら 429 を返すこと", async () => {
    vi.spyOn(console, "log").mockImplementation(() => {});

    for (let i = 0; i < 60; i++) {
      expect((await post(validBody)).status).toBe(204);
    }

    expect((await post(validBody)).status).toBe(429);
  });
});
