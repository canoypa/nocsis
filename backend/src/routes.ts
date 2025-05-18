import { Scalar } from "@scalar/hono-api-reference";
import { Hono } from "hono";
import { describeRoute, openAPISpecs } from "hono-openapi";
import { resolver } from "hono-openapi/zod";
import { z } from "zod";
import "zod-openapi/extend";

export const app = new Hono();

const responseSchema = z.string().openapi({
  description: "Example response",
  example: "Hello Hono!",
});

app.get(
  "/",
  describeRoute({
    description: "Example endpoint",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "text/plain": {
            schema: resolver(responseSchema),
          },
        },
      },
    },
  }),
  (c) => {
    return c.text("Hello Hono!");
  },
);

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
  app.get("/api-doc", Scalar({ url: "/api-spec" }));
}
