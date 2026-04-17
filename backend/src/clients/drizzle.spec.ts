import { describe, expect, it } from "vitest";
import { db } from "../../tests/helpers/db.js";
import { usersTable } from "../db/schema.js";

describe("Drizzle DB 接続", () => {
  it("INSERT して SELECT できること", async () => {
    await db.insert(usersTable).values({ firebaseUid: "test-uid" });

    const result = await db.select().from(usersTable);
    expect(result).toHaveLength(1);
    expect(result[0].firebaseUid).toBe("test-uid");
  });

  it("トランザクションがロールバックされ前のテストのデータが残っていないこと", async () => {
    const result = await db.select().from(usersTable);
    expect(result).toHaveLength(0);
  });
});
