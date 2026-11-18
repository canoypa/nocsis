import { createMiddleware } from "hono/factory";
import { routePath } from "hono/route";

export const CLIENT_COMMIT_HEADER = "X-Client-Commit";

const SHA = /^[0-9a-f]{40}$/;

/**
 * どの版の画面から来たリクエストかをログに残す
 *
 * ヘッダーが無いのは、ヘッダーを付ける前の版か、CI 以外でビルドした画面
 */
export const logRequest = createMiddleware(async (c, next) => {
  await next();

  const commit = c.req.header(CLIENT_COMMIT_HEADER);

  console.log(
    JSON.stringify({
      severity: "INFO",
      message: "リクエストを受けた",
      method: c.req.method,
      route: routePath(c),
      status: c.res.status,
      clientCommit:
        commit === undefined ? null : SHA.test(commit) ? commit : "invalid",
    }),
  );
});
