import { drizzle } from "drizzle-orm/node-postgres";
import * as schema from "./schema.ts";

if (!Deno.env.get("DB_URL")) {
  throw new Error("DB_URL is not set");
}

export const db = drizzle(Deno.env.get("DB_URL"), { schema });
