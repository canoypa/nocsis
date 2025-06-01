import { generateOpenapiSpec } from "../src/generate_openapi_spec.js";
import { app } from "../src/routes.js";

generateOpenapiSpec(app);
