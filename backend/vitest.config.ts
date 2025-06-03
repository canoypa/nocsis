import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "default",
    include: ["src/**/*.spec.ts"],
    setupFiles: ["tests/setup.ts"],
    // TODO: 必要そうだったらコメントアウトを外す
    // fileParallelism: false,
    // poolOptions: {
    //   forks: {
    //     singleFork: true,
    //     isolate: false,
    //   },
    // },
  },
});
