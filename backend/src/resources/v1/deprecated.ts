import type { z } from "zod";

export const deprecated = <T extends z.ZodType>(schema: T) =>
  schema.optional().meta({ deprecated: true });
