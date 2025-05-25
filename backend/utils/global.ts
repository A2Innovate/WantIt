const REQUIRED_ENVS = [
  "FRONTEND_URL",
  "DB_URL",
  "REDIS_URL",
  "SMTP_HOST",
  "SMTP_PORT",
  "SMTP_SECURE",
  "SMTP_USER",
  "SMTP_PASSWORD",
  "SMTP_FROM",
  "S3_ENDPOINT",
  "S3_BUCKET",
  "S3_REGION",
  "S3_ACCESS_KEY",
  "S3_SECRET_KEY",
  "OAUTH_GOOGLE_CLIENT_ID",
  "OAUTH_GOOGLE_CLIENT_SECRET",
  "PUSHER_KEY",
  "PUSHER_SECRET",
  "PUSHER_APP_ID",
  "PUSHER_HOST",
];

for (const env of REQUIRED_ENVS) {
  if (!Deno.env.get(env)) {
    throw new Error(`${env} is not set`);
  }
}

export const FRONTEND_URL = Deno.env.get("FRONTEND_URL")!;
export const COOKIE_DOMAIN = (() => {
  try {
    const hostname = new URL(FRONTEND_URL).hostname;
    const parts = hostname.split(".");

    // Single-segment hostnames (e.g. localhost)
    if (parts.length < 2) {
      return hostname;
    }

    // Multi-segment hostnames (e.g. example.com or subdomain.example.com)
    return "." + parts.slice(-2).join(".");
  } catch {
    throw new Error(`Invalid FRONTEND_URL: ${FRONTEND_URL}`);
  }
})();

export const DB_URL = Deno.env.get("DB_URL")!;
export const REDIS_URL = Deno.env.get("REDIS_URL")!;
export const SMTP_HOST = Deno.env.get("SMTP_HOST")!;
export const SMTP_PORT = (() => {
  const port = Number(Deno.env.get("SMTP_PORT"));
  if (isNaN(port)) {
    throw new Error(
      `SMTP_PORT must be a valid number, got: ${Deno.env.get("SMTP_PORT")}`,
    );
  }
  return port;
})();
export const SMTP_SECURE = (() => {
  const secure = Deno.env.get("SMTP_SECURE");
  if (secure !== "true" && secure !== "false") {
    throw new Error(`SMTP_SECURE must be "true" or "false", got: ${secure}`);
  }
  return secure === "true";
})();
export const SMTP_USER = Deno.env.get("SMTP_USER")!;
export const SMTP_PASSWORD = Deno.env.get("SMTP_PASSWORD")!;
export const SMTP_FROM = Deno.env.get("SMTP_FROM")!;
export const S3_ENDPOINT = Deno.env.get("S3_ENDPOINT")!;
export const S3_BUCKET = Deno.env.get("S3_BUCKET")!;
export const S3_REGION = Deno.env.get("S3_REGION")!;
export const S3_ACCESS_KEY = Deno.env.get("S3_ACCESS_KEY")!;
export const S3_SECRET_KEY = Deno.env.get("S3_SECRET_KEY")!;
export const OAUTH_GOOGLE_CLIENT_ID = Deno.env.get("OAUTH_GOOGLE_CLIENT_ID")!;
export const OAUTH_GOOGLE_CLIENT_SECRET = Deno.env.get(
  "OAUTH_GOOGLE_CLIENT_SECRET",
)!;
export const PUSHER_KEY = Deno.env.get("PUSHER_KEY")!;
export const PUSHER_SECRET = Deno.env.get("PUSHER_SECRET")!;
export const PUSHER_APP_ID = Deno.env.get("PUSHER_APP_ID")!;
export const PUSHER_HOST = Deno.env.get("PUSHER_HOST")!;
