import { InferSelectModel } from "drizzle-orm";
import { alertsTable, requestsTable } from "@/db/schema.ts";
import { convert } from "./convert.ts";

export async function isRequestMatchingAlertBudget(
  request: Omit<InferSelectModel<typeof requestsTable>, "userId">,
  alert: InferSelectModel<typeof alertsTable>,
) {
  switch (alert.budgetComparisonMode) {
    case "EQUALS":
      if (
        await convert(
          request.currency,
          alert.currency,
          request.budget,
        ) !== alert.budget
      ) {
        return false;
      }
      break;
    case "LESS_THAN":
      if (
        await convert(request.currency, alert.currency, request.budget) >=
          alert.budget
      ) {
        return false;
      }
      break;
    case "LESS_THAN_OR_EQUAL_TO":
      if (
        await convert(request.currency, alert.currency, request.budget) >
          alert.budget
      ) {
        return false;
      }
      break;
    case "GREATER_THAN":
      if (
        await convert(request.currency, alert.currency, request.budget) <=
          alert.budget
      ) {
        return false;
      }
      break;
    case "GREATER_THAN_OR_EQUAL_TO":
      if (
        await convert(request.currency, alert.currency, request.budget) <
          alert.budget
      ) {
        return false;
      }
      break;
  }
  return true;
}
