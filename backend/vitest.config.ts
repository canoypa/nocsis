import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.spec.ts"],
    setupFiles: ["tests/setup.ts"],
    fileParallelism: false,
    pool: "forks",
    maxWorkers: 1,
    isolate: true,
    sequence: {
      concurrent: false,
    },
    mockReset: true,
    clearMocks: true,
  },
});
