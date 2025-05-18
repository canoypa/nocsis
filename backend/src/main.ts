import { serve } from "@hono/node-server";
import { generateOpenapiSpec } from "./generate_openapi_spec.js";
import { app } from "./routes.js";

if (process.env.NODE_ENV !== "production") {
  generateOpenapiSpec(app);
}

const port = 8080;
console.log(`Server is running on http://localhost:${port}`);

serve({
  fetch: app.fetch,
  port,
});
