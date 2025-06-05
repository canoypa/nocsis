import { Scalar } from "@scalar/hono-api-reference";
import { Hono } from "hono";
import { openAPISpecs } from "hono-openapi";
import { v1Routes } from "./controllers/v1_controller.js";

import "zod-openapi/extend";

export const app = new Hono({
  strict: false, // パス末尾のスラッシュ有無を区別しない
}).basePath("/api");

app.route("/v1", v1Routes);

if (process.env.NODE_ENV !== "production") {
  app.get(
    "/api-spec",
    openAPISpecs(app, {
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
