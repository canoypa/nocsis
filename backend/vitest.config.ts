import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.spec.ts"],
    setupFiles: ["tests/setup.ts"],
    fileParallelism: false,
    mockReset: true,
    coverage: {
      include: ["src/**/*.ts"],
      // 単体テストで測らない。起動はスモークテストで、仕様の書き出しは lint の
      // api.json の差分チェックで確かめる。
      // ソースマップのワーカーは別のスレッドで動き、v8 のカバレッジに乗らない。
      // client_error_service のテストがワーカーを通して確かめる。
      exclude: [
        "src/main.ts",
        "src/generate_openapi_spec.ts",
        "src/services/source_map_worker.ts",
      ],
      reporter: ["text", "html", "json-summary"],
      thresholds: {
        statements: 95,
        branches: 86,
        functions: 97,
        lines: 96,
      },
    },
  },
});
