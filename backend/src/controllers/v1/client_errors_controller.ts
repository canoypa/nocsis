import { Hono } from "hono";
import { bodyLimit } from "hono/body-limit";
import { describeRoute, validator } from "hono-openapi";
import type { z } from "zod";
import { skipAuthorization } from "../../middlewares/authorize.js";
import { clientErrorSchema } from "../../resources/v1/client_errors.js";
import {
  type DecodedFrame,
  decodeStack,
} from "../../services/client_error_service.js";

export const clientErrorsRoutes = new Hono();

type ClientError = z.infer<typeof clientErrorSchema>;

// 誰でも送れるので、ログの量 (= 料金) に上限を付ける。インスタンスごとの数なので目安。
const RATE_LIMIT_PER_MINUTE = 60;
let windowStartedAt = 0;
let countInWindow = 0;

const allowRequest = (now: number): boolean => {
  if (now - windowStartedAt >= 60_000) {
    windowStartedAt = now;
    countInWindow = 0;
  }
  countInWindow += 1;

  return countInWindow <= RATE_LIMIT_PER_MINUTE;
};

/**
 * レート制限の状態を戻す
 * テストでしか使ってない
 */
export const resetClientErrorRateLimit = (): void => {
  windowStartedAt = 0;
  countInWindow = 0;
};

const formatFrame = (frame: DecodedFrame): string =>
  frame.source
    ? `    at ${frame.functionName ?? "<unknown>"} (${frame.path ?? frame.source}:${frame.line}:${frame.column})`
    : `    ${frame.raw}`;

/**
 * Error Reporting が拾う形のログを書く
 *
 * Error Reporting は Dart のスタックトレースを解析しないので、@type と reportLocation を自分で付ける
 */
const writeLog = (
  body: ClientError,
  frames: DecodedFrame[],
  userAgent: string | undefined,
) => {
  const top =
    frames.find((frame) => frame.path !== undefined) ??
    frames.find((frame) => frame.source !== undefined);

  console.log(
    JSON.stringify({
      severity: "ERROR",
      "@type":
        "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent",
      message: [body.message, ...frames.map(formatFrame)].join("\n"),
      serviceContext: { service: "frontend", version: body.commit },
      context: {
        httpRequest: { url: body.path, userAgent },
        reportLocation: {
          filePath: top?.path ?? top?.source ?? "unknown",
          lineNumber: top?.line ?? 0,
          functionName: top?.functionName ?? "unknown",
        },
      },
      compiler: body.compiler,
      githubUrl: top?.githubUrl,
      rawStack: body.stack,
    }),
  );
};

clientErrorsRoutes.post(
  "/",
  describeRoute({
    description: "フロントエンドで起きたエラーを記録する",
    responses: {
      204: { description: "記録した" },
      400: { description: "Bad Request" },
      413: { description: "Payload Too Large" },
      429: { description: "Too Many Requests" },
    },
  }),
  skipAuthorization(
    "ログイン前の画面のエラーも受けるので、認証せず、主体もいない。ログに書くだけ",
  ),
  bodyLimit({ maxSize: 32 * 1024 }),
  validator("json", clientErrorSchema),
  async (c) => {
    if (!allowRequest(Date.now())) return c.body(null, 429);

    const body = c.req.valid("json");

    const frames = await decodeStack(body.stack, body.commit);

    writeLog(body, frames, c.req.header("User-Agent"));

    return c.body(null, 204);
  },
);
