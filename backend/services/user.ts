import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { and, eq, ilike, sql } from "drizzle-orm";
import { zValidator } from "@hono/zod-validator";
import {
  alertsTable,
  requestsTable,
  userSessionsTable,
  usersTable,
} from "@/db/schema.ts";
import { generateEmailVerificationToken } from "@/utils/generate.ts";
import { sendMail } from "@/utils/mail.ts";
import {
  alertByIdSchema,
  createEditAlertSchema,
  getUserByIdSchema,
  updateProfileSchema,
} from "@/schema/services/user.ts";
import { FRONTEND_URL } from "@/utils/global.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { z } from "zod";
import { isRequestMatchingAlertBudget } from "@/utils/filter.ts";
import { pusher } from "../utils/pusher.ts";

const app = new Hono();

app.get(
  "/alerts",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  authRequired,
  async (c) => {
    const session = c.get("session");

    const alerts = await db.query.alertsTable.findMany({
      where: eq(alertsTable.userId, session.user.id),
      columns: {
        id: true,
        content: true,
        budget: true,
        currency: true,
        location: true,
        radius: true,
        budgetComparisonMode: true,
        createdAt: true,
      },
    });

    return c.json(alerts);
  },
);

app.get(
  "/alert/:alertId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  authRequired,
  zValidator(
    "param",
    z.object({
      alertId: z.string().refine(
        (value) => !isNaN(Number(value)),
        "alertId must be a valid number",
      ).transform((value) => Number(value)),
    }),
  ),
  async (c) => {
    const session = c.get("session");
    const { alertId } = c.req.valid("param");

    const alert = await db.query.alertsTable.findFirst({
      where: and(
        eq(alertsTable.id, alertId),
        eq(alertsTable.userId, session.user.id),
      ),
    });

    if (!alert) {
      return c.json({ message: "Alert not found" }, 404);
    }

    let requests;
    if (alert.location) {
      requests = await db.select(
        {
          id: requestsTable.id,
          content: requestsTable.content,
          budget: requestsTable.budget,
          currency: requestsTable.currency,
          location: requestsTable.location,
          radius: requestsTable.radius,
          user: {
            id: usersTable.id,
            username: usersTable.username,
          },
          createdAt: requestsTable.createdAt,
        },
      ).from(requestsTable)
        .where(
          and(
            sql`ST_Intersects(
          ST_Buffer(${requestsTable.location}::geography, ${requestsTable.radius})::geometry,
          ST_Buffer(ST_SetSRID(ST_MakePoint(${alert.location?.x}, ${alert.location?.y})::geography, 4326), ${alert.radius})::geometry
        )`,
            ilike(requestsTable.content, `%${alert.content}%`),
          ),
        )
        .innerJoin(usersTable, eq(requestsTable.userId, usersTable.id));
    } else {
      requests = await db.query.requestsTable.findMany({
        where: ilike(requestsTable.content, `%${alert.content}%`),
        columns: {
          id: true,
          content: true,
          budget: true,
          currency: true,
          location: true,
          radius: true,
          createdAt: true,
        },
        with: {
          user: {
            columns: {
              id: true,
              username: true,
            },
          },
        },
      });
    }

    const filteredRequests = [];
    for (const request of requests) {
      if (await isRequestMatchingAlertBudget(request, alert)) {
        filteredRequests.push(request);
      }
    }

    return c.json({
      alert,
      requests: filteredRequests,
    });
  },
);

app.post(
  "/alert",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "json",
    createEditAlertSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const {
      content,
      budget,
      location,
      radius,
      currency,
      budgetComparisonMode,
    } = c.req.valid("json");

    const [alert] = await db.insert(alertsTable).values({
      content,
      budget,
      location,
      radius,
      currency,
      budgetComparisonMode,
      userId: session.user.id,
    }).returning({
      id: alertsTable.id,
      content: alertsTable.content,
      budget: alertsTable.budget,
      location: alertsTable.location,
      radius: alertsTable.radius,
      currency: alertsTable.currency,
      budgetComparisonMode: alertsTable.budgetComparisonMode,
      createdAt: alertsTable.createdAt,
    });

    pusher.trigger(
      `private-user-${session.user.id}-alerts`,
      "new-alert",
      alert,
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({ message: "Alert created successfully" }, 201);
  },
);

app.delete(
  "/alert/:alertId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "param",
    alertByIdSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { alertId } = c.req.valid("param");

    const deletedAlert = await db.delete(alertsTable).where(
      and(
        eq(alertsTable.id, alertId),
        eq(alertsTable.userId, session.user.id),
      ),
    );

    if (!deletedAlert) {
      return c.json({ message: "Alert not found" }, 404);
    }

    pusher.trigger(
      [
        `private-user-${session.user.id}-alerts`,
        `private-user-${session.user.id}-alert-${alertId}`,
      ],
      "delete-alert",
      {
        alertId,
      },
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({ message: "Alert deleted successfully" }, 200);
  },
);

app.put(
  "/alert/:alertId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "param",
    alertByIdSchema,
  ),
  zValidator(
    "json",
    createEditAlertSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { alertId } = c.req.valid("param");
    const data = c.req.valid("json");

    const [alert] = await db.update(alertsTable).set({
      content: data.content,
      budget: data.budget,
      location: data.location,
      radius: data.radius,
      currency: data.currency,
      budgetComparisonMode: data.budgetComparisonMode,
    }).where(
      and(
        eq(alertsTable.id, alertId),
        eq(alertsTable.userId, session.user.id),
      ),
    ).returning({
      id: alertsTable.id,
      content: alertsTable.content,
      budget: alertsTable.budget,
      location: alertsTable.location,
      radius: alertsTable.radius,
      currency: alertsTable.currency,
      budgetComparisonMode: alertsTable.budgetComparisonMode,
      createdAt: alertsTable.createdAt,
    });

    if (!alert) {
      return c.json({ message: "Alert not found" }, 404);
    }

    pusher.trigger(
      [
        `private-user-${session.user.id}-alerts`,
        `private-user-${session.user.id}-alert-${alert.id}`,
      ],
      "update-alert",
      {
        alert,
      },
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({ message: "Alert updated successfully" }, 200);
  },
);

app.put(
  "/update",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "json",
    updateProfileSchema,
  ),
  authRequired,
  async (c) => {
    const session = c.get("session");
    const { name, email, preferredCurrency, username } = c.req.valid("json");

    if (session.user.name !== name) {
      await db.update(usersTable).set({
        name,
      }).where(eq(usersTable.id, session.user.id));
    }

    if (session.user.email !== email) {
      const existingUser = await db.query.usersTable.findFirst({
        where: eq(usersTable.email, email),
      });

      if (existingUser) {
        return c.json({ message: "User with this email already exists" }, 409);
      }

      const emailVerificationToken = await generateEmailVerificationToken();

      try {
        await sendMail({
          to: email,
          subject: "WantIt - Email verification",
          text: `Hi ${session.user.name}!

          To confirm your email update, click the link below:
          ${FRONTEND_URL}/auth/verify-email/${emailVerificationToken}
          
          Best regards,
          WantIt Team`,
        });
      } catch (error) {
        console.error("Failed to send email:", error);
        return c.json({
          message: "Sending verification email failed, please try again later.",
        }, 500);
      }

      await db.transaction(async (tx) => {
        await tx.update(usersTable).set({
          email,
          isEmailVerified: false,
          emailVerificationToken,
        }).where(eq(usersTable.id, session.user.id));

        await tx.delete(userSessionsTable).where(
          eq(userSessionsTable.userId, session.user.id),
        );
      });
    }

    if (session.user.preferredCurrency !== preferredCurrency) {
      await db.update(usersTable).set({
        preferredCurrency,
      }).where(eq(usersTable.id, session.user.id));
    }

    if (session.user.username !== username) {
      try {
        await db.update(usersTable).set({
          username,
        }).where(eq(usersTable.id, session.user.id));
      } catch (error) {
        if (
          error instanceof Error &&
          error.message ===
            'duplicate key value violates unique constraint "users_username_unique"'
        ) {
          return c.json({ message: "Username already exists" }, 409);
        }
      }
    }

    return c.json({ message: "Updated successfully" }, 200);
  },
);

app.get(
  "/:userId",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator("param", getUserByIdSchema),
  async (c) => {
    const { userId } = c.req.valid("param");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, userId),
      with: {
        requests: {
          columns: {
            id: true,
            content: true,
            budget: true,
            currency: true,
            createdAt: true,
          },
        },
      },
      columns: {
        name: true,
        username: true,
      },
    });

    if (!user) {
      return c.json({ message: "User not found" }, 404);
    }

    return c.json(user);
  },
);

export default app;
