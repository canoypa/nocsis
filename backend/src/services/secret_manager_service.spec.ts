import { beforeEach, describe, expect, it, vi } from "vitest";
import { firebaseApp } from "../clients/firebase.js";
import { secretManagerClient } from "../clients/secret_manager.js";
import { clearSecretCache, fetchSecret } from "./secret_manager_service.js";

describe("fetchSecret", () => {
  beforeEach(() => {
    vi.spyOn(secretManagerClient, "secretVersionPath");

    vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
      async () => [{ payload: { data: "secret-value" } }],
    );

    return () => {
      clearSecretCache();
    };
  });

  it("シークレット値を取得できること", async () => {
    await expect(fetchSecret("test-secret")).resolves.toBe("secret-value");
  });

  describe("シークレットが空の場合", () => {
    it("エラーになること", async () => {
      vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
        async () => [{ payload: { data: "" } }],
      );

      await expect(fetchSecret("test-secret")).rejects.toThrow(
        "シークレット値を取得できませんでした",
      );
    });
  });

  describe("Secret Manager APIでエラーが発生した場合", () => {
    it("エラーがスローされること", async () => {
      vi.spyOn(secretManagerClient, "accessSecretVersion").mockRejectedValue(
        "unexpected error",
      );

      await expect(fetchSecret("test-secret")).rejects.toThrow(
        "unexpected error",
      );
    });
  });

  describe("2回呼び出す場合", () => {
    it("2回目の呼び出しではキャッシュが参照されること", async () => {
      // 1回目
      await expect(fetchSecret("test-secret")).resolves.toBe("secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1);

      // 2回目
      await expect(fetchSecret("test-secret")).resolves.toBe("secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1); // キャッシュを参照するので、呼び出し回数は1回のまま
    });
  });
});
