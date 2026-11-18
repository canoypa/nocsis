import { Scalar } from "@scalar/hono-api-reference";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { openAPIRouteHandler } from "hono-openapi";
import { v1Routes } from "./controllers/v1_controller.js";
import { CLIENT_COMMIT_HEADER, logRequest } from "./middlewares/log_request.js";

const allowHeaders = ["Content-Type", "Authorization", CLIENT_COMMIT_HEADER];

export const app = new Hono({
  strict: false, // パス末尾のスラッシュ有無を区別しない
}).basePath("/api");

app.use(
  "/*",
  cors(
    process.env.NODE_ENV === "production"
      ? {
          origin: ["https://nocsis.app"],
          allowHeaders,
        }
      : {
          origin: "*",
          allowHeaders,
          credentials: true,
        },
  ),
);

app.use("/*", logRequest);

app.route("/v1", v1Routes);

if (process.env.NODE_ENV !== "production") {
  app.get(
    "/api-spec",
    openAPIRouteHandler(app, {
      documentation: {
        components: {
          securitySchemes: {
            bearer: {
              type: "http",
              scheme: "bearer",
              description: "Firebase JWT token",
            },
          },
        },
      },
    }),
  );
  app.get("/api-doc", Scalar({ url: "/api/api-spec" }));
}
