export async function getRates() {
  const response = await fetch(
    "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml",
  );

  const xml = await response.text();

  const rates: { currency: string; rate: number }[] = [];

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
