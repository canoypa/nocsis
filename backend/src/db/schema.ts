import {
  boolean,
  date,
  doublePrecision,
  integer,
  pgEnum,
  pgTable,
  text,
  timestamp,
  unique,
} from "drizzle-orm/pg-core";

// ユーザー（Firebase Auth の参照）
export const usersTable = pgTable("users", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  firebaseUid: text().notNull().unique(),
  createdAt: timestamp().notNull().defaultNow(),
  updatedAt: timestamp().notNull().defaultNow(),
});

// グループ
export const groupsTable = pgTable("groups", {
  id: integer().primaryKey().generatedAlwaysAsIdentity(),
  publicId: text().notNull().unique(),
  name: text().notNull(),
  classesCalendarId: text().notNull(),
  eventsCalendarId: text().notNull(),
  daydutyStartDate: date().notNull(),
  slackEventChannelId: text().notNull(),
  weatherLat: doublePrecision().notNull(),
  weatherLon: doublePrecision().notNull(),
  daydutyNotificationEnabled: boolean().notNull().default(true),
  createdAt: timestamp().notNull().defaultNow(),
  updatedAt: timestamp().notNull().defaultNow(),
});

// グループとユーザーの中間テーブル
export const groupUsersTable = pgTable(
  "group_users",
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    userId: integer()
      .notNull()
      .references(() => usersTable.id),
    groupId: integer()
      .notNull()
      .references(() => groupsTable.id),
    createdAt: timestamp().notNull().defaultNow(),
    updatedAt: timestamp().notNull().defaultNow(),
  },
  (t) => [unique().on(t.userId, t.groupId)],
);

export const classmateRoleEnum = pgEnum("classmate_role", [
  "student",
  "teacher",
]);

// クラスメイト
export const classmatesTable = pgTable(
  "classmates",
  {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    groupId: integer()
      .notNull()
      .references(() => groupsTable.id),
    // アカウントとのリンク（任意）
    userId: integer().references(() => usersTable.id),
    role: classmateRoleEnum().notNull(),
    stuNo: integer(),
    name: text().notNull(),
    email: text().notNull(),
    slackUserId: text().notNull(),
    createdAt: timestamp().notNull().defaultNow(),
    updatedAt: timestamp().notNull().defaultNow(),
  },
  (t) => [unique().on(t.userId, t.groupId)],
);
