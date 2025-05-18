import fs from "node:fs";
import { resolve } from "node:path";
import type { Hono } from "hono";
import { generateSpecs } from "hono-openapi";

export const generateOpenapiSpec = async (app: Hono) => {
  const spec = await generateSpecs(app);
  const path = resolve("../api-spec.openapi.json");
  fs.writeFileSync(path, JSON.stringify(spec, null, 2));
};
