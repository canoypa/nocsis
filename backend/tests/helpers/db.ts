import { drizzle } from "drizzle-orm/node-postgres";
import { Client } from "pg";
import { afterAll, afterEach, beforeEach } from "vitest";

const client = new Client({
  connectionString: process.env.DATABASE_URL,
});
await client.connect();

export const db = drizzle(client, { casing: "snake_case" });

beforeEach(async () => {
  await client.query("BEGIN");
});

afterEach(async () => {
  await client.query("ROLLBACK");
});

afterAll(async () => {
  await client.end();
});
