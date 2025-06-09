import { createMiddleware } from "hono/factory";
import { client } from "@/utils/redis.ts";
import { getIp } from "@/utils/ip.ts";
import { createLog } from "@/utils/log.ts";

export const rateLimit = ({
  windowMs,
  limit,
}: {
  windowMs: number;
  limit: number;
}) =>
  createMiddleware(async (c, next) => {
    try {
      const ip = getIp(c);

      if (!ip) {
        console.warn("Rate limit: IP not found, skipping");
        return next();
      }

      const key = `ratelimit:${ip}:${c.req.method}:${c.req.routePath}`;
      const now = Date.now();
      const windowStart = now - windowMs;

      await client.zremrangebyscore(key, 0, windowStart);

      const countResult = await client.zcard(key);

      const currentCount = typeof countResult === "number" ? countResult : 0;

      const requestId = `${now}-${Math.random()}`;

      if (currentCount >= limit) {
        await client.expire(key, Math.ceil(windowMs / 1000));

        const statsKey =
          `stats:ratelimit:exceeded:${c.req.method}:${c.req.routePath}`;
        await client.zremrangebyscore(statsKey, 0, now - 60 * 60 * 24 * 1000);
        await client.zadd(statsKey, now, requestId);
        await client.expire(statsKey, 60 * 60 * 24);

        createLog({
          type: "RATELIMIT_HIT",
          ip,
        });

        return c.json(
          {
            message: `Rate limit exceeded. Try again in ${
              Math.ceil(
                windowMs / 1000,
              )
            } seconds.`,
          },
          429,
        );
      }

      await client.zadd(key, now, requestId);

      await client.expire(key, Math.ceil(windowMs / 1000) + 1);

      c.header("X-RateLimit-Limit", limit.toString());
      c.header(
        "X-RateLimit-Remaining",
        Math.max(0, limit - currentCount - 1).toString(),
      );
      c.header("X-RateLimit-Reset", (now + windowMs).toString());

      await next();
    } catch (error) {
      console.error("Rate limit: ", error);
      await next();
    }
  });
