import { client } from "./redis.ts";

interface Rate {
  currency: string;
  rate: number;
}

export async function getRates() {
  const response = await fetch(
    "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml",
  );

  const xml = await response.text();

  const rates: Rate[] = [];

  const regex =
    /<Cube\s+currency=['"]([^'"]+)['"]\s+rate=['"]([^'"]+)['"]\s*\/>/g;
  let match;

  while ((match = regex.exec(xml)) !== null) {
    const currency = match[1];
    const rate = parseFloat(match[2]);

    if (currency && !isNaN(rate)) {
      rates.push({
        currency: currency,
        rate: rate,
      });
    }
  }

  return rates;
}

export async function getCachedRates() {
  const rates = await client.get("currency:rates");

  if (rates) {
    return JSON.parse(rates) as Rate[];
  } else {
    const rates = await getRates();

    await client.set("currency:rates", JSON.stringify(rates));

    await client.expire("currency:rates", 60 * 60);

    return rates;
  }
}
