import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it } from "vitest";
import {
  externalApiServer,
  SECRET_MANAGER_ACCESS_URL,
  secretManagerHandler,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import { clearSecretCache, fetchSecret } from "./secret_manager_service.js";

useExternalApiServer();

describe("fetchSecret", () => {
  let requests: Request[];

  beforeEach(() => {
    requests = [];
    const onRequest = ({ request }: { request: Request }) => {
      if (request.url.startsWith("https://secretmanager.googleapis.com/")) {
        requests.push(request);
      }
    };
    externalApiServer.events.on("request:start", onRequest);
    externalApiServer.use(
      secretManagerHandler({
        "test-secret": "test-secret-value",
        "another-secret": "another-secret-value",
        "empty-secret": "",
      }),
    );

    return () => {
      externalApiServer.events.removeListener("request:start", onRequest);
      clearSecretCache();
    };
  });

  it("最新バージョンのシークレット値を取得できること", async () => {
    await expect(fetchSecret("test-secret")).resolves.toBe("test-secret-value");

    expect(requests).toHaveLength(1);
    expect(new URL(requests[0].url).pathname).toBe(
      "/v1/projects/class-clock-40088/secrets/test-secret/versions/latest:access",
    );
    expect(requests[0].headers.get("authorization")).toMatch(/^Bearer \S+/);
  });

  describe("値が空文字列の場合", () => {
    it("エラーになること", async () => {
      await expect(fetchSecret("empty-secret")).rejects.toThrow(
        "シークレット値を取得できませんでした",
      );
    });
  });

  describe("payload が存在しない場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(SECRET_MANAGER_ACCESS_URL, () =>
          HttpResponse.json({ name: "no-payload" }),
        ),
      );

      await expect(fetchSecret("test-secret")).rejects.toThrow(
        "シークレット値を取得できませんでした",
      );
    });
  });

  describe("シークレットが存在しない場合", () => {
    it("エラーになること", async () => {
      await expect(fetchSecret("missing-secret")).rejects.toThrow();
    });
  });

  describe("同じシークレットを2回取得する場合", () => {
    it("2回目はキャッシュが使われ、API を呼ばないこと", async () => {
      await expect(fetchSecret("test-secret")).resolves.toBe(
        "test-secret-value",
      );
      await expect(fetchSecret("test-secret")).resolves.toBe(
        "test-secret-value",
      );

      expect(requests).toHaveLength(1);
    });
  });

  describe("異なるシークレットを取得する場合", () => {
    it("別々にキャッシュされること", async () => {
      await expect(fetchSecret("test-secret")).resolves.toBe(
        "test-secret-value",
      );
      await expect(fetchSecret("another-secret")).resolves.toBe(
        "another-secret-value",
      );
      await expect(fetchSecret("test-secret")).resolves.toBe(
        "test-secret-value",
      );
      await expect(fetchSecret("another-secret")).resolves.toBe(
        "another-secret-value",
      );

      expect(requests).toHaveLength(2);
    });
  });
});
