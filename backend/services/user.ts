import { Hono } from "hono";
import { authRequired } from "@/middleware/auth.ts";
import { db } from "@/db/index.ts";
import { and, eq, ilike, inArray, sql } from "drizzle-orm";
import { zValidator } from "@hono/zod-validator";
import {
  alertsTable,
  offersTable,
  requestsTable,
  userReviewsTable,
  userSessionsTable,
  usersTable,
} from "@/db/schema.ts";
import {
  generateEmailVerificationToken,
  generateUniqueAccountDeletionToken,
} from "@/utils/generate.ts";
import { sendMail } from "@/utils/mail.ts";
import {
  addEditReviewSchema,
  alertByIdSchema,
  createEditAlertSchema,
  getUserByIdSchema,
  reviewByIdSchema,
  updateProfileSchema,
} from "@/schema/services/user.ts";
import { FRONTEND_URL } from "@/utils/global.ts";
import { rateLimit } from "@/middleware/ratelimit.ts";
import { z } from "zod";
import { isRequestMatchingAlertBudget } from "@/utils/filter.ts";
import { pusher } from "../utils/pusher.ts";
import { deleteRecursive } from "../utils/s3.ts";

const app = new Hono();

app.get(
  "/alerts",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
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
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
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
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "json",
    createEditAlertSchema,
  ),
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
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "param",
    alertByIdSchema,
  ),
  async (c) => {
    const session = c.get("session");
    const { alertId } = c.req.valid("param");

    const [deletedAlert] = await db.delete(alertsTable).where(
      and(
        eq(alertsTable.id, alertId),
        eq(alertsTable.userId, session.user.id),
      ),
    ).returning({ id: alertsTable.id });

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
  authRequired,
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
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator(
    "json",
    updateProfileSchema,
  ),
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

app.post(
  "/:userId/review",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 5,
  }),
  zValidator("param", getUserByIdSchema),
  zValidator("json", addEditReviewSchema),
  async (c) => {
    const session = c.get("session");
    const { userId } = c.req.valid("param");
    const { content, rating } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.id, userId),
    });

    if (!user) {
      return c.json({ message: "User not found" }, 404);
    }

    if (session.user.id === userId) {
      return c.json({ message: "You cannot review yourself" }, 400);
    }

    const existingReview = await db.query.userReviewsTable.findFirst({
      where: and(
        eq(userReviewsTable.reviewerUserId, session.user.id),
        eq(userReviewsTable.reviewedUserId, userId),
      ),
    });

    if (existingReview) {
      return c.json({ message: "You have already reviewed this user" }, 400);
    }

    const [review] = await db.insert(userReviewsTable).values({
      reviewerUserId: session.user.id,
      reviewedUserId: userId,
      content,
      rating,
    }).returning({
      id: userReviewsTable.id,
      content: userReviewsTable.content,
      rating: userReviewsTable.rating,
      createdAt: userReviewsTable.createdAt,
      edited: userReviewsTable.edited,
    });

    pusher.trigger(
      `public-user-${userId}-reviews`,
      "add-review",
      {
        ...review,
        reviewer: {
          id: session.user.id,
          username: session.user.username,
          name: session.user.name,
        },
      },
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({
      message: "Review added successfully",
    });
  },
);

app.put(
  "/review/:reviewId",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 5,
  }),
  zValidator("param", reviewByIdSchema),
  zValidator("json", addEditReviewSchema),
  async (c) => {
    const session = c.get("session");
    const { reviewId } = c.req.valid("param");
    const { content, rating } = c.req.valid("json");

    const [review] = await db.update(userReviewsTable).set({
      content,
      rating,
    }).where(
      and(
        eq(userReviewsTable.id, reviewId),
        eq(userReviewsTable.reviewerUserId, session.user.id),
      ),
    ).returning({
      id: userReviewsTable.id,
      content: userReviewsTable.content,
      rating: userReviewsTable.rating,
      reviewedUserId: userReviewsTable.reviewedUserId,
      createdAt: userReviewsTable.createdAt,
    });

    if (!review) {
      return c.json({ message: "Review not found" }, 404);
    }

    pusher.trigger(
      `public-user-${review.reviewedUserId}-reviews`,
      "update-review",
      review,
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({
      message: "Review edited successfully",
    });
  },
);

app.get(
  "/:userId/reviews",
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 50,
  }),
  zValidator("param", getUserByIdSchema),
  async (c) => {
    const { userId } = c.req.valid("param");

    const reviews = await db.query.userReviewsTable.findMany({
      where: eq(userReviewsTable.reviewedUserId, userId),
      columns: {
        id: true,
        content: true,
        rating: true,
        createdAt: true,
        edited: true,
      },
      with: {
        reviewer: {
          columns: {
            id: true,
            username: true,
            name: true,
          },
        },
      },
    });

    return c.json(reviews);
  },
);

app.delete(
  "/review/:reviewId",
  authRequired,
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    limit: 15,
  }),
  zValidator("param", reviewByIdSchema),
  async (c) => {
    const session = c.get("session");
    const { reviewId } = c.req.valid("param");

    const [deletedReview] = await db.delete(userReviewsTable).where(
      and(
        eq(userReviewsTable.id, reviewId),
        eq(userReviewsTable.reviewerUserId, session.user.id),
      ),
    ).returning({
      reviewedUserId: userReviewsTable.reviewedUserId,
    });

    if (!deletedReview) {
      return c.json({ message: "Review not found" }, 404);
    }

    pusher.trigger(
      `public-user-${deletedReview.reviewedUserId}-reviews`,
      "delete-review",
      {
        reviewId,
      },
    ).catch((error) => {
      console.error("Async Pusher trigger error: ", error);
    });

    return c.json({ message: "Review deleted successfully" }, 200);
  },
);

app.delete(
  "/",
  authRequired,
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 1,
  }),
  async (c) => {
    const session = c.get("session");

    const accountDeletionToken = await generateUniqueAccountDeletionToken();
    const accountDeletionTokenExpiresAt = new Date(Date.now() + 60 * 60 * 1000);

    await sendMail({
      to: session.user.email,
      subject: "WantIt - Confirm account deletion",
      text: `Hi ${session.user.name}!

      To confirm your account deletion, click the link below:
      ${FRONTEND_URL}/user/delete-account/${accountDeletionToken}

      This link expires at ${accountDeletionTokenExpiresAt.toString()}. 
      You can request a new link at any time in the settings.

      Best regards,
      WantIt Team`,
    });

    await db.update(usersTable).set({
      accountDeletionToken,
      accountDeletionTokenExpiresAt,
    }).where(eq(usersTable.id, session.user.id));

    return c.json({
      message:
        "Please check your email to confirm the deletion of your account",
    }, 200);
  },
);

app.post(
  "/delete-account",
  rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    limit: 1,
  }),
  zValidator(
    "json",
    z.object({
      token: z.string(),
    }),
  ),
  async (c) => {
    const { token } = c.req.valid("json");

    const user = await db.query.usersTable.findFirst({
      where: eq(usersTable.accountDeletionToken, token),
    });

    if (
      !user ||
      !user.accountDeletionToken ||
      !user.accountDeletionTokenExpiresAt ||
      user.accountDeletionTokenExpiresAt < new Date()
    ) {
      return c.json({ message: "Invalid token" }, 400);
    }

    await db.update(usersTable).set({
      accountDeletionToken: null,
      accountDeletionTokenExpiresAt: null,
    }).where(eq(usersTable.id, user.id));

    const offers = await db.query.offersTable.findMany({
      where: eq(offersTable.userId, user.id),
    });

    try {
      await Promise.all(
        offers.map(async (offer) => {
          await deleteRecursive(
            `request/${offer.requestId}/offer/${offer.id}`,
          );
        }),
      );

      await db.delete(offersTable).where(
        inArray(offersTable.id, offers.map((offer) => offer.id)),
      );
    } catch (error) {
      console.error("Error deleting offer files:", error);
      return c.json({ message: "Account deletion failed" }, 500);
    }

    await db.delete(usersTable).where(
      eq(usersTable.id, user.id),
    );

    pusher.trigger("private-admin-stats", "update-users", -1).catch((e) => {
      console.error(`Async Pusher trigger error: ${e}`);
    });

    return c.json({ message: "Account deleted successfully" }, 200);
  },
);

export default app;
