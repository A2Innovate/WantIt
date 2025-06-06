import { getCachedRates } from "./rates.ts";

export async function convert(
  from: string,
  to: string,
  amount: number,
): Promise<number> {
  const rates = await getCachedRates();

  let amountInEUR: number;

  if (from === "EUR") {
    amountInEUR = amount;
  } else {
    const fromRate = rates.find((r) => r.currency === from);
    if (!fromRate) {
      throw new Error(`Currency not found: ${from}`);
    }
    amountInEUR = amount / fromRate.rate;
  }

  if (to === "EUR") {
    return amountInEUR;
  } else {
    const toRate = rates.find((r) => r.currency === to);
    if (!toRate) {
      throw new Error(`Currency not found: ${to}`);
    }
    return amountInEUR * toRate.rate;
  }
}
