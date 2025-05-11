import "dotenv/config";
import { Hono } from "hono";
import auth from "./services/auth.ts";
import { cors } from "hono/cors";
import request from "./services/request.ts";
import user from "./services/user.ts";

const app = new Hono();

app.use(cors({
  origin: Deno.env.get("FRONTEND_URL") ?? "http://localhost:3000",
  credentials: true,
}));

app.get("/", (c) => {
  return c.text("Hello Hono!");
});

app.route("/api/auth", auth);
app.route("/api/request", request);
app.route("/api/user", user);

Deno.serve(app.fetch);
