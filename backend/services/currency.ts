import { Hono } from "hono";
import { getRates } from "@/utils/rates.ts";
import { client } from "@/utils/redis.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";

const app = new Hono();

app.get(
  "/",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 150,
  }),
  async (c) => {
    const rates = await client.get("currency:rates");

    if (rates) {
      return c.json(JSON.parse(rates));
    } else {
      const rates = await getRates();

      await client.set("currency:rates", JSON.stringify(rates));

      await client.expire("currency:rates", 60 * 60);

      return c.json(rates);
    }
  },
);

export default app;
