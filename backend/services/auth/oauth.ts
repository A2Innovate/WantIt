import * as client from "openid-client";
import { Hono } from "hono";
import { deleteCookie, getCookie, setCookie } from "hono/cookie";
import { db } from "@/db/index.ts";
import { eq } from "drizzle-orm";
import { userSessionsTable, usersTable } from "@/db/schema.ts";
import {
  generateSessionToken,
  generateUniqueUsername,
} from "@/utils/generate.ts";
import {
  COOKIE_DOMAIN,
  COOKIE_SECURE,
  FRONTEND_URL,
  OAUTH_GOOGLE_CLIENT_ID,
  OAUTH_GOOGLE_CLIENT_SECRET,
} from "@/utils/global.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { getIp } from "@/utils/ip.ts";

const app = new Hono();

const server = new URL("https://accounts.google.com");
const config: client.Configuration = await client.discovery(
  server,
  OAUTH_GOOGLE_CLIENT_ID,
  OAUTH_GOOGLE_CLIENT_SECRET,
);

app.get(
  "/google",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 100,
  }),
  async (c) => {
    const mobile = c.req.query("mobile");
    const scope = "openid email profile";

    const pkceCodeVerifier = client.randomPKCECodeVerifier();
    const code_challenge = await client.calculatePKCECodeChallenge(
      pkceCodeVerifier,
    );

    const parameters: Record<string, string> = {
      redirect_uri: new URL(c.req.url).origin + "/api/auth/oauth/google/" +
        (mobile ? "return-to-mobile" : "callback"),
      scope,
      code_challenge,
      code_challenge_method: "S256",
    };

    let state: string | undefined;
    if (!config.serverMetadata().supportsPKCE()) {
      state = client.randomState();
      parameters.state = state;
    }

    if (mobile) {
      return c.json({
        url: client.buildAuthorizationUrl(config, parameters),
        pkceCodeVerifier,
        state,
      }, 200);
    } else {
      setCookie(c, "pkce_verifier", pkceCodeVerifier, {
        httpOnly: true,
        secure: COOKIE_SECURE,
        sameSite: "Lax",
        maxAge: 600,
      });

      if (state) {
        setCookie(c, "oauth_state", state, {
          httpOnly: true,
          secure: COOKIE_SECURE,
          sameSite: "Lax",
          maxAge: 600,
        });
      }

      const redirectTo: URL = client.buildAuthorizationUrl(config, parameters);
      return c.json({ url: redirectTo.toString() }, 200);
    }
  },
);

app.get(
  "/google/callback",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 100,
  }),
  async (c) => {
    try {
      const pkceCodeVerifier = getCookie(c, "pkce_verifier");
      const state = getCookie(c, "oauth_state");

      if (!pkceCodeVerifier) {
        return c.redirect(
          FRONTEND_URL + "/auth/oauth/error?message=Missing PKCE verifier",
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
          FRONTEND_URL + "/auth/oauth/error?message=Invalid authorization code",
        );
      }

      const tokensClaim = tokens.claims();
      if (!tokensClaim) {
        return c.redirect(
          FRONTEND_URL + "/auth/oauth/error?message=Invalid authorization code",
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
          FRONTEND_URL +
            "/auth/oauth/error?message=Your Google account email is not verified",
        );
      }

      const existingUser = await db.query.usersTable.findFirst({
        where: eq(usersTable.email, userInfo.email),
      });

      if (existingUser) {
        if (existingUser.isBlocked) {
          return c.redirect(
            FRONTEND_URL +
              "/auth/oauth/error?message=Your account is blocked",
          );
        }

        const sessionToken = await generateSessionToken();

        await db.insert(userSessionsTable).values({
          userId: existingUser.id,
          sessionToken,
          ip: getIp(c),
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
        });

        setCookie(c, "wantit_session", sessionToken, {
          httpOnly: true,
          secure: COOKIE_SECURE,
          sameSite: "Lax",
          maxAge: 60 * 60 * 24 * 30, // 30 days,
          domain: COOKIE_DOMAIN,
        });

        return c.redirect(FRONTEND_URL + "/", 302);
      }
      const user = await db.insert(usersTable).values({
        name: userInfo.given_name || userInfo.name || "Google User",
        username: await generateUniqueUsername(),
        email: userInfo.email!,
        password: null,
        emailVerificationToken: null,
        isEmailVerified: true,
      }).returning();

      const sessionToken = await generateSessionToken();

      await db.insert(userSessionsTable).values({
        userId: user[0].id,
        sessionToken,
        ip: getIp(c),
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
      });

      setCookie(c, "wantit_session", sessionToken, {
        httpOnly: true,
        secure: COOKIE_SECURE,
        sameSite: "Lax",
        maxAge: 60 * 60 * 24 * 30, // 30 days
        domain: COOKIE_DOMAIN,
      });

      return c.redirect(FRONTEND_URL + "/", 302);
    } catch (error) {
      console.error("Error in Google OAuth callback:", error);
      return c.redirect(
        FRONTEND_URL + "/auth/oauth/error?message=Google OAuth failed",
      );
    }
  },
);

app.get(
  "/google/return-to-mobile",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 100,
  }),
  (c) => {
    const redirectUrl = `wantit://auth/google?${c.req.url}`;

    return c.redirect(redirectUrl, 302);
  },
);

app.get(
  "/google/callback-mobile",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 100,
  }),
  async (c) => {
    try {
      const url = c.req.query("url")!;
      const pkceCodeVerifier = c.req.query("pkce_code_verifier");
      let state = c.req.query("state");
      if (state == "") {
        state = undefined;
      }
      if (!pkceCodeVerifier) {
        return c.json(
          {
            message: "Missing PKCE verifier",
          },
          400,
        );
      }

      const tokens = await client.authorizationCodeGrant(
        config,
        new URL(url),
        {
          pkceCodeVerifier,
          expectedState: state,
        },
      );

      if (
        !tokens || !tokens.access_token || tokens.expires_in === undefined ||
        !tokens.claims()
      ) {
        return c.json(
          {
            message: "Invalid authorization code",
          },
          400,
        );
      }

      const tokensClaim = tokens.claims();
      if (!tokensClaim) {
        return c.json(
          {
            message: "Invalid authorization code",
          },
          400,
        );
      }

      const userInfo = await client.fetchUserInfo(
        config,
        tokens.access_token,
        tokensClaim.sub,
      );

      if (!userInfo.email_verified || !userInfo.email) {
        return c.json(
          {
            message: "Your Google account email is not verified",
          },
          400,
        );
      }

      const existingUser = await db.query.usersTable.findFirst({
        where: eq(usersTable.email, userInfo.email),
      });

      if (existingUser) {
        if (existingUser.isBlocked) {
          return c.json(
            {
              message: "Your account is blocked",
            },
            400,
          );
        }

        const sessionToken = await generateSessionToken();

        const [session] = await db.insert(userSessionsTable).values({
          userId: existingUser.id,
          sessionToken,
          ip: getIp(c),
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
        }).returning({
          id: userSessionsTable.id,
        });

        setCookie(c, "wantit_session", sessionToken, {
          httpOnly: true,
          secure: COOKIE_SECURE,
          sameSite: "Lax",
          maxAge: 60 * 60 * 24 * 30, // 30 days,
          domain: COOKIE_DOMAIN,
        });

        return c.json({
          id: existingUser.id,
          email: existingUser.email,
          name: existingUser.name,
          username: existingUser.username,
          preferredCurrency: existingUser.preferredCurrency,
          isAdmin: existingUser.isAdmin,
          sessionId: session.id,
        }, 200);
      }

      // Create new user if not exists
      const user = await db.insert(usersTable).values({
        name: userInfo.given_name || userInfo.name || "Google User",
        username: await generateUniqueUsername(),
        email: userInfo.email!,
        password: null,
        emailVerificationToken: null,
        isEmailVerified: true,
      }).returning();

      const sessionToken = await generateSessionToken();

      const [session] = await db.insert(userSessionsTable).values({
        userId: user[0].id,
        sessionToken,
        ip: getIp(c),
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 30), // 30 days
      }).returning({
        id: userSessionsTable.id,
      });

      setCookie(c, "wantit_session", sessionToken, {
        httpOnly: true,
        secure: COOKIE_SECURE,
        sameSite: "Lax",
        maxAge: 60 * 60 * 24 * 30, // 30 days
        domain: COOKIE_DOMAIN,
      });

      return c.json({
        id: user[0].id,
        email: user[0].email,
        name: user[0].name,
        username: user[0].username,
        preferredCurrency: user[0].preferredCurrency,
        isAdmin: user[0].isAdmin,
        sessionId: session.id,
      }, 200);
    } catch (error) {
      console.error("Error in Google OAuth callback:", error);
      return c.json(
        {
          message: "Google OAuth failed",
        },
        500,
      );
    }
  },
);

export default app;
