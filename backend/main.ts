import "dotenv/config";
import { Hono } from "hono";
import auth from "./services/auth.ts";

const app = new Hono();

app.get("/", (c) => {
  return c.text("Hello Hono!");
});

app.route("/api/auth", auth);

Deno.serve(app.fetch);
