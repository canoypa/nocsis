import { beforeEach, describe, expect, it, vi } from "vitest";
import { secretManagerClient } from "../clients/secret_manager.js";
import { clearSecretCache, fetchSecret } from "./secret_manager_service.js";

describe("fetchSecret", () => {
  beforeEach(() => {
    vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
      async () => [{ payload: { data: "secret-value" } }],
    );

    return () => {
      clearSecretCache();
    };
  });

  it("シークレット値を取得できること", async () => {
    const result = await fetchSecret("test-secret");

    expect(result).toBe("secret-value");
    expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1);
  });

  describe("data が空文字列の場合", () => {
    it("エラーになること", async () => {
      vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
        async () => [{ payload: { data: "" } }],
      );

      await expect(fetchSecret("test-secret")).rejects.toThrow(
        "シークレット値を取得できませんでした",
      );
    });
  });

  describe("data が null の場合", () => {
    it("エラーになること", async () => {
      vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
        async () => [{ payload: { data: null } }],
      );

      await expect(fetchSecret("test-secret")).rejects.toThrow(
        "シークレット値を取得できませんでした",
      );
    });
  });

  describe("payload が存在しない場合", () => {
    it("エラーになること", async () => {
      vi.spyOn(secretManagerClient, "accessSecretVersion").mockImplementation(
        async () => [{}],
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

  describe("同じシークレットを2回呼び出す場合", () => {
    it("2回目の呼び出しではキャッシュが参照されること", async () => {
      // 1回目
      await expect(fetchSecret("test-secret")).resolves.toBe("secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1);

      // 2回目
      await expect(fetchSecret("test-secret")).resolves.toBe("secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1); // キャッシュを参照するので、呼び出し回数は1回のまま
    });
  });

  describe("異なるシークレット名を呼び出す場合", () => {
    it("別々にキャッシュされること", async () => {
      // このテストでのみ、引数に応じて異なる値を返すmockに変更
      vi.mocked(secretManagerClient.accessSecretVersion).mockImplementation(
        async ({ name }) => {
          if (name?.includes("test-secret")) {
            return [{ payload: { data: "test-secret-value" } }];
          }
          if (name?.includes("another-secret")) {
            return [{ payload: { data: "another-secret-value" } }];
          }
          return [{ payload: { data: "default-value" } }];
        },
      );

      // test-secret
      await expect(fetchSecret("test-secret")).resolves.toBe("test-secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(1);

      // another-secret
      await expect(fetchSecret("another-secret")).resolves.toBe("another-secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(2);

      // 再度同じシークレットを呼び出すとキャッシュが使われる
      await expect(fetchSecret("test-secret")).resolves.toBe("test-secret-value");
      await expect(fetchSecret("another-secret")).resolves.toBe("another-secret-value");
      expect(secretManagerClient.accessSecretVersion).toHaveBeenCalledTimes(2);
    });
  });
});
