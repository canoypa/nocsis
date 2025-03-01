import * as path from "node:path";
import { defineConfig, defineWorkspace, mergeConfig } from "vitest/config";

const sharedConfig = defineConfig({
  test: {
    alias: {
      "~": path.resolve(__dirname, "./src"),
    },
  },
});

const defaultConfig = defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.test.ts"],
    exclude: ["src/{controllers,services}/**/*.test.ts"],
  },
});

const functionsConfig = defineConfig({
  test: {
    name: "functions",
    include: ["src/{controllers,services}/**/*.test.ts"],
    setupFiles: ["tests/functions_setup.ts"],
    fileParallelism: false,
    poolOptions: {
      threads: {
        singleThread: true,
      },
    },
  },
});

export default defineWorkspace([
  mergeConfig(sharedConfig, defaultConfig),
  mergeConfig(sharedConfig, functionsConfig),
]);
