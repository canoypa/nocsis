import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  jsSourceMap,
  wasmSourceMap,
} from "../../tests/fixtures/source_maps.js";
import {
  CLOUD_STORAGE_OBJECT_URL,
  externalApiServer,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import { decodeStack, toRepositoryPath } from "./client_error_service.js";
import { clearSourceMapCache } from "./source_map_service.js";

const COMMIT = "0123456789abcdef0123456789abcdef01234567";

useExternalApiServer();

const serveSourceMaps = (requested: string[] = []) =>
  externalApiServer.use(
    http.get(CLOUD_STORAGE_OBJECT_URL, ({ params, request }) => {
      const object = decodeURIComponent(String(params.object));
      requested.push(`${params.bucket}/${object}`);
      expect(request.headers.get("Authorization")).toMatch(/^Bearer /);

      if (object === `${COMMIT}/main.dart.js.map`) {
        return HttpResponse.json(jsSourceMap);
      }
      if (object === `${COMMIT}/main.dart.wasm.map`) {
        return HttpResponse.json(wasmSourceMap);
      }
      return HttpResponse.json({}, { status: 404 });
    }),
  );

beforeEach(() => {
  clearSourceMapCache();
});

describe("decodeStack", () => {
  it("wasm のフレームをオフセットで Dart の行に戻し、GitHub のリンクを付けること", async () => {
    const requested: string[] = [];
    serveSourceMaps(requested);

    const frames = await decodeStack(
      [
        "    at M (https://nocsis.app/main.dart.wasm:wasm-function[4308]:0x100)",
        "    at M (https://nocsis.app/main.dart.wasm:wasm-function[12]:0x200)",
      ].join("\n"),
      COMMIT,
    );

    expect(requested).toEqual([
      `demo-nocsis-frontend-source-maps/${COMMIT}/main.dart.wasm.map`,
    ]);
    expect(frames).toEqual([
      {
        raw: "at M (https://nocsis.app/main.dart.wasm:wasm-function[4308]:0x100)",
        path: "frontend/lib/pages/home.dart",
        source:
          "file:///home/runner/work/nocsis/nocsis/frontend/lib/pages/home.dart",
        line: 42,
        column: 7,
        functionName: "build",
        githubUrl: `https://github.com/canoypa/nocsis/blob/${COMMIT}/frontend/lib/pages/home.dart#L42`,
      },
      {
        raw: "at M (https://nocsis.app/main.dart.wasm:wasm-function[12]:0x200)",
        path: undefined,
        source:
          "file:///home/runner/.pub-cache/hosted/pub.dev/go_router-18.1.1/lib/src/router.dart",
        line: 10,
        column: 3,
        functionName: "push",
        githubUrl: undefined,
      },
    ]);
  });

  it("dart2js のフレームを行と列で戻すこと (V8 と Safari / Firefox の書き方)", async () => {
    serveSourceMaps();

    const frames = await decodeStack(
      [
        "Error",
        "    at Object.a0v (https://nocsis.app/main.dart.js:10:5)",
        "yF@https://nocsis.app/main.dart.js:20:9",
      ].join("\n"),
      COMMIT,
    );

    expect(
      frames.map((frame) => [frame.path, frame.line, frame.functionName]),
    ).toEqual([
      [undefined, undefined, undefined],
      ["frontend/lib/main.dart", 26, "deepFunctionThatFails"],
      [undefined, 5907, "StatelessElement.build"],
    ]);
    expect(frames[0]).toEqual({ raw: "Error" });
  });

  it("ソースマップが無い commit では、行をそのまま返すこと", async () => {
    serveSourceMaps();
    const other = "f".repeat(40);

    const frames = await decodeStack(
      "    at Object.a0v (https://nocsis.app/main.dart.js:10:5)",
      other,
    );

    expect(frames).toEqual([
      { raw: "at Object.a0v (https://nocsis.app/main.dart.js:10:5)" },
    ]);
  });

  it("同じ commit のソースマップは一度しか取りに行かないこと", async () => {
    const requested: string[] = [];
    serveSourceMaps(requested);
    const stack = "    at a (https://nocsis.app/main.dart.js:10:5)";

    await decodeStack(stack, COMMIT);
    await decodeStack(stack, COMMIT);

    expect(requested).toHaveLength(1);
  });

  it("同時に届いても、ソースマップは一度しか取りに行かないこと", async () => {
    const requested: string[] = [];
    serveSourceMaps(requested);
    const stack = "    at a (https://nocsis.app/main.dart.js:10:5)";

    const results = await Promise.all([
      decodeStack(stack, COMMIT),
      decodeStack(stack, COMMIT),
      decodeStack(stack, COMMIT),
    ]);

    expect(requested).toHaveLength(1);
    expect(results.map(([frame]) => frame.line)).toEqual([26, 26, 26]);
  });

  it("見つからなかったソースマップは、5 分たつまで取りに行かないこと", async () => {
    const requested: string[] = [];
    serveSourceMaps(requested);
    const other = "f".repeat(40);
    const stack = "    at a (https://nocsis.app/main.dart.js:10:5)";
    const now = vi.spyOn(Date, "now").mockReturnValue(0);

    await decodeStack(stack, other);
    now.mockReturnValue(5 * 60_000 - 1);
    await decodeStack(stack, other);
    expect(requested).toHaveLength(1);

    now.mockReturnValue(5 * 60_000);
    await decodeStack(stack, other);
    expect(requested).toHaveLength(2);
  });

  it("取得に失敗したファイルの行だけをそのまま返し、ほかの行は戻すこと", async () => {
    externalApiServer.use(
      http.get(CLOUD_STORAGE_OBJECT_URL, ({ params }) =>
        decodeURIComponent(String(params.object)).endsWith("wasm.map")
          ? HttpResponse.json(wasmSourceMap)
          : HttpResponse.json({}, { status: 403 }),
      ),
    );
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});

    const frames = await decodeStack(
      [
        "    at a (https://nocsis.app/main.dart.js:10:5)",
        "    at M (https://nocsis.app/main.dart.wasm:wasm-function[1]:0x100)",
      ].join("\n"),
      COMMIT,
    );

    expect(frames.map((frame) => frame.path)).toEqual([
      undefined,
      "frontend/lib/pages/home.dart",
    ]);
    expect(warn).toHaveBeenCalledOnce();
    expect(String(warn.mock.calls[0][0])).toContain("403");
  });
});

describe("toRepositoryPath", () => {
  it.each([
    ["../../../lib/main.dart", "frontend/lib/main.dart"],
    [
      "file:///home/runner/work/nocsis/nocsis/frontend/lib/a/b.dart",
      "frontend/lib/a/b.dart",
    ],
    ["org-dartlang-sdk:///dart-sdk/lib/_internal/js_helper.dart", undefined],
    ["/opt/flutter/packages/flutter/lib/src/widgets/framework.dart", undefined],
  ])("%s → %s", (source, expected) => {
    expect(toRepositoryPath(source)).toBe(expected);
  });
});
