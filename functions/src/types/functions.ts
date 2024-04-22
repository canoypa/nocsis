import type { EventContext } from "firebase-functions/v1";
import type { UserRecord } from "firebase-functions/v1/auth";
import type { CallableContext } from "firebase-functions/v1/https";

export type OnCallHandler<R = any, D = any> = (
  data: D,
  context: CallableContext,
) => Promise<R>;

export type AuthOnCreateHandler = (
  user: UserRecord,
  context: EventContext,
) => Promise<void>;

export type PubSubOnRunHandler = (context: EventContext) => Promise<void>;
