import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

const alias = {
  "~": fileURLToPath(new URL("./src", import.meta.url)),
};

export default defineConfig({
  test: {
    projects: [
      {
        resolve: { alias },
        test: {
          name: "default",
          include: ["src/**/*.test.ts"],
          exclude: ["src/{controllers,services}/**/*.test.ts"],
        },
      },
      {
        resolve: { alias },
        test: {
          name: "functions",
          include: ["src/{controllers,services}/**/*.test.ts"],
          setupFiles: ["tests/functions_setup.ts"],
          fileParallelism: false,
        },
      },
    ],
    coverage: {
      // cobertura: GitHub Code Coverage (actions/upload-code-coverage) へ渡すため。
      reporter: ["text", "html", "clover", "json", "cobertura"],
      thresholds: {
        statements: 70,
        branches: 62,
        functions: 78,
        lines: 70,
      },
    },
  },
});
