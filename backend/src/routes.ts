import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver } from "hono-openapi/zod";
import { z } from "zod";

export const app = new Hono();

const responseSchema = z.string();

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
