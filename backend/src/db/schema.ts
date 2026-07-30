import { sql } from "drizzle-orm";
import {
  bigint,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
} from "drizzle-orm/pg-core";

/**
 * ユーザー。Firebase Auth の uid と email を Postgres 側に固定するアンカー。
 *
 * 主キーは bigint（integer は 21 億で枯渇し、後から広げると全ての参照側に波及する）。
 * 日時は timestamptz（timestamp without time zone は JST 運用で事故る）。
 * updated_at は Postgres が自動更新しないため、共通トリガーで更新する（マイグレーション参照）。
 */
export const usersTable = pgTable(
  "users",
  {
    id: bigint({ mode: "number" }).primaryKey().generatedAlwaysAsIdentity(),
    firebaseUid: text().notNull().unique("users_firebase_uid_key"),
    email: text().notNull(),
    createdAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp({ withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [
    // メールアドレスは大文字小文字を区別せず一意
    uniqueIndex("users_email_key").on(sql`lower(${t.email})`),
  ],
);
