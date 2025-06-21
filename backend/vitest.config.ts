import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.spec.ts"],
    setupFiles: ["tests/setup.ts"],
    fileParallelism: false,
    poolOptions: {
      forks: {
        singleFork: true,
        isolate: false,
      },
    },
  },
});
