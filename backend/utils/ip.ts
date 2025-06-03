import type { Context } from "hono";
import { getConnInfo } from "hono/deno";

export function getIp(c: Context) {
  return c.req.header("x-real-ip") || getConnInfo(c).remote.address;
}
