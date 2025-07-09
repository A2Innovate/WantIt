import { z } from "zod";

export const addCommentSchema = z.object({
  content: z.string().min(1, "validation_comment_content_min_length").max(
    512,
    "validation_comment_content_max_length",
  ),
  offerId: z.number(),
});

export const editCommentSchema = z.object({
  content: z.string().min(1, "validation_comment_content_min_length").max(
    512,
    "validation_comment_content_max_length",
  ),
});
