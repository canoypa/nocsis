import fs from "node:fs";
import type { Hono } from "hono";
import { generateSpecs } from "hono-openapi";

export const generateOpenapiSpec = async (app: Hono) => {
  const spec = await generateSpecs(app);
  fs.writeFileSync("openapi.json", JSON.stringify(spec, null, 2));
};
