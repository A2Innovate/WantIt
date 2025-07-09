import { MiddlewareHandler } from "hono/types";
import { createMiddleware } from "hono/factory";

export const or = (...handlers: MiddlewareHandler[]) =>
  createMiddleware(async (c, next) => {
    let isValid = false;
    for (const handler of handlers) {
      const res = await handler(c, next);
      if (res && res.status === 200) {
        isValid = true;
        break;
      }
    }
    if (!isValid) {
      return c.json({ valid: false }, 400);
    }
  });
