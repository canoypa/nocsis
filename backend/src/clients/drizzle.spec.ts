import { eq, sql } from "drizzle-orm";
import { afterEach, describe, expect, it, vi } from "vitest";
import { db } from "../../tests/helpers/db.js";
import { usersTable } from "../db/schema.js";

describe("Drizzle DB 接続", () => {
  it("INSERT して SELECT できること", async () => {
    await db
      .insert(usersTable)
      .values({ firebaseUid: "test-uid", email: "test@example.com" });

    const result = await db.select().from(usersTable);
    expect(result).toHaveLength(1);
    expect(result[0].firebaseUid).toBe("test-uid");
  });

  it("トランザクションがロールバックされ前のテストのデータが残っていないこと", async () => {
    const result = await db.select().from(usersTable);
    expect(result).toHaveLength(0);
  });
});

describe("users テーブルの制約", () => {
  it("updated_at がトリガーで更新されること", async () => {
    await db
      .insert(usersTable)
      .values({ firebaseUid: "test-uid", email: "test@example.com" });

    // クライアントが明示的に過去の値を送っても、トリガーが now() で上書きする。
    // テストは BEGIN/ROLLBACK に包まれており now() はトランザクション開始時刻で
    // 固定されるため、上書き後の値は created_at と一致する。
    await db
      .update(usersTable)
      .set({ updatedAt: new Date("2000-01-01T00:00:00Z") })
      .where(eq(usersTable.firebaseUid, "test-uid"));

    const [user] = await db.select().from(usersTable);
    expect(user.updatedAt).toEqual(user.createdAt);
  });

  it("メールアドレスが大文字小文字を区別せず一意であること", async () => {
    await db
      .insert(usersTable)
      .values({ firebaseUid: "test-uid-1", email: "Foo@Example.com" });

    // Drizzle は pg のエラーを包むため、違反した制約名は cause 側にある
    await expect(
      db
        .insert(usersTable)
        .values({ firebaseUid: "test-uid-2", email: "foo@example.com" }),
    ).rejects.toMatchObject({ cause: { constraint: "users_email_key" } });
  });

  it("id が bigint であること", async () => {
    const result = await db.execute(sql`
      SELECT data_type FROM information_schema.columns
      WHERE table_name = 'users' AND column_name = 'id'
    `);

    expect(result.rows[0]).toMatchObject({ data_type: "bigint" });
  });

  it("created_at / updated_at が timestamptz であること", async () => {
    const result = await db.execute(sql`
      SELECT column_name, data_type FROM information_schema.columns
      WHERE table_name = 'users' AND column_name IN ('created_at', 'updated_at')
      ORDER BY column_name
    `);

    expect(result.rows).toEqual([
      { column_name: "created_at", data_type: "timestamp with time zone" },
      { column_name: "updated_at", data_type: "timestamp with time zone" },
    ]);
  });
});

// 遅延生成は OpenAPI 生成が routes.ts の import だけで落ちないために必要で、
// import 時に throw する形へ戻ると気付けないため振る舞いを固定する。
// モジュール変数を持つので、各テストでモジュールごと作り直す。
describe("getDb", () => {
  afterEach(() => {
    vi.unstubAllEnvs();
    vi.resetModules();
  });

  it("import 時ではなく初回呼び出しで DATABASE_URL を要求すること", async () => {
    vi.stubEnv("DATABASE_URL", undefined);

    const { getDb } = await import("./drizzle.js");

    expect(() => getDb()).toThrow("DATABASE_URL is not set");
  });

  it("同じインスタンスを返すこと", async () => {
    const { getDb } = await import("./drizzle.js");

    expect(getDb()).toBe(getDb());
  });
});
