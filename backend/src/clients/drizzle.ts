import { drizzle, type NodePgDatabase } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

let instance: NodePgDatabase | null = null;

/**
 * DB クライアントを取得する
 *
 * 生成を初回呼び出しまで遅らせている。import 時に DATABASE_URL を要求すると、
 * DB を使わない経路（OpenAPI 生成など）が routes.ts を import しただけで落ちる。
 */
export const getDb = (): NodePgDatabase => {
  if (instance) {
    return instance;
  }

  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL is not set");
  }

  instance = drizzle(new Pool({ connectionString }), { casing: "snake_case" });

  return instance;
};
