import "dotenv/config";
import { Hono } from "hono";
import auth from "./services/auth/index.ts";
import { cors } from "hono/cors";
import request from "./services/request.ts";
import user from "./services/user.ts";
import { FRONTEND_URL } from "./utils/global.ts";

const app = new Hono();

app.use(cors({
  origin: FRONTEND_URL,
  credentials: true,
}));

app.get("/", (c) => {
  return c.text("Hello Hono!");
});

app.route("/api/auth", auth);
app.route("/api/request", request);
app.route("/api/user", user);

Deno.serve(app.fetch);
