import { drizzle } from "drizzle-orm/node-postgres";
import * as schema from "./schema.ts";
import { DB_URL } from "@/utils/global.ts";

export const db = drizzle(DB_URL, { schema });
