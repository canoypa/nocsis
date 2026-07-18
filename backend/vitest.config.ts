import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.spec.ts"],
    setupFiles: ["tests/setup.ts"],
    fileParallelism: false,
    mockReset: true,
    coverage: {
      thresholds: {
        statements: 85,
        branches: 68,
        functions: 80,
        lines: 85,
      },
    },
  },
});
