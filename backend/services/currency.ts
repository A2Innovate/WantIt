import { Hono } from "hono";
import { getCachedRates } from "@/utils/rates.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";

const app = new Hono();

app.get(
  "/",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 150,
  }),
  async (c) => {
    const rates = await getCachedRates();

    return c.json(rates);
  },
);

export default app;
