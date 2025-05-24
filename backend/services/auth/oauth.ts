import * as client from "openid-client";
import { Hono } from "hono";
import { deleteCookie, getCookie, setCookie } from "hono/cookie";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import { generateSessionToken } from "@/utils/generate.ts";

const app = new Hono();
const authUrl = "https://accounts.google.com";
const server: URL = new URL(authUrl);
const clientID: string = Deno.env.get("OAUTH_GOOGLE_CLIENT_ID")!;
const clientSecret: string = Deno.env.get("OAUTH_GOOGLE_CLIENT_SECRET")!;
const frontendUrl: string = Deno.env.get("FRONTEND_URL")!;
const config: client.Configuration = await client.discovery(
  server,
  clientID,
  clientSecret,
);

app.get("/google", async (c) => {
  const scope: string = "openid email profile";
  const pkceCodeVerifier = client.randomPKCECodeVerifier();
  const code_challenge = await client.calculatePKCECodeChallenge(
    pkceCodeVerifier,
  );

  const parameters: Record<string, string> = {
    redirect_uri: new URL(c.req.url).origin + "/api/auth/oauth/google/callback",
    scope,
    code_challenge,
    code_challenge_method: "S256",
  };

  let state: string | undefined;
  if (!config.serverMetadata().supportsPKCE()) {
    state = client.randomState();
    parameters.state = state;
  }

  setCookie(c, "pkce_verifier", pkceCodeVerifier, {
    httpOnly: true,
    secure: true,
    sameSite: "Lax",
    maxAge: 600,
  });

  if (state) {
    setCookie(c, "oauth_state", state, {
      httpOnly: true,
      secure: true,
      sameSite: "Lax",
      maxAge: 600,
    });
  }

  const redirectTo: URL = client.buildAuthorizationUrl(config, parameters);
  return c.json({ url: redirectTo }, 200);
});

app.get("/google/callback", async (c) => {
  try {
    const pkceCodeVerifier = getCookie(c, "pkce_verifier");
    const state = getCookie(c, "oauth_state");

    if (!pkceCodeVerifier) {
      return c.redirect(
        frontendUrl + "/auth/oauth/error?message=Missing PKCE verifier",
      );
    }
    const tokens = await client.authorizationCodeGrant(
      config,
      new URL(c.req.url),
      {
        pkceCodeVerifier,
        expectedState: state,
      },
    );

    if (
      !tokens || !tokens.access_token || tokens.expires_in === undefined ||
      !tokens.claims()
    ) {
      return c.redirect(
        frontendUrl + "/auth/oauth/error?message=Invalid authorization code",
      );
    }

    const tokensClaim = tokens.claims();
    if (!tokensClaim) {
      return c.redirect(
        frontendUrl + "/auth/oauth/error?message=Invalid authorization code",
      );
    }
    const userInfo = await client.fetchUserInfo(
      config,
      tokens.access_token,
      tokensClaim.sub,
    );

    deleteCookie(c, "pkce_verifier");
    deleteCookie(c, "oauth_state");

    if (!userInfo.email_verified || !userInfo.email) {
      return c.redirect(
        frontendUrl +
          "/auth/oauth/error?message=Your Google account email is not verified",
      );
    }

    const existingUser = await db.query.usersTable.findFirst({
      where: eq(usersTable.email, userInfo.email),
    });

    if (existingUser) {
      const sessionToken = await generateSessionToken();

      await db.insert(userSessionsTable).values({
        userId: existingUser.id,
        sessionToken,
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
      });

      setCookie(c, "session", sessionToken, {
        httpOnly: true,
        secure: true,
        sameSite: "Lax",
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });

      return c.redirect(frontendUrl + "/", 302);
    }

    const user = await db.insert(usersTable).values({
      name: userInfo.given_name!,
      email: userInfo.email!,
      password: "",
      emailVerificationToken: null,
      isEmailVerified: true,
    }).returning();

    const sessionToken = await generateSessionToken();

    await db.insert(userSessionsTable).values({
      userId: user[0].id,
      sessionToken,
      expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
    });

    setCookie(c, "session", sessionToken, {
      httpOnly: true,
      secure: true,
      sameSite: "Lax",
      maxAge: 60 * 60 * 24 * 30, // 30 days
    });

    return c.redirect(frontendUrl + "/", 302);
  } catch (error) {
    console.error("Error in Google OAuth callback:", error);
    return c.redirect(
      frontendUrl + "/auth/oauth/error?message=Google OAuth failed",
    );
  }
});

export default app;
