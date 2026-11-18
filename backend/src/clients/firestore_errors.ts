import { GrpcStatus } from "firebase-admin/firestore";

/** Firestore の書き込みが「すでにある」で失敗したか。create() で同じ ID の doc があったときに起きる */
export const isAlreadyExists = (err: unknown): boolean =>
  typeof err === "object" &&
  err !== null &&
  "code" in err &&
  err.code === GrpcStatus.ALREADY_EXISTS;
