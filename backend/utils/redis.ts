import { Redis } from "ioredis";
import { REDIS_URL } from "@/utils/global.ts";

export const client = new Redis(REDIS_URL);
