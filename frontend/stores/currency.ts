interface Rate {
  currency: string;
  rate: number;
}

export const useCurrencyStore = defineStore('currency', () => {
  const rates = ref<Rate[]>([]);

  async function fetchRates() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData(() =>
      requestFetch<Rate[]>(useRuntimeConfig().public.apiBase + '/api/currency')
    );

    rates.value = response.value ?? [];
  }

  function convert(from: string, to: string, amount: number): number {
    let amountInEUR: number;

    if (from === 'EUR') {
      amountInEUR = amount;
    } else {
      const fromRate = rates.value.find((r) => r.currency === from);
      if (!fromRate) {
        throw new Error(`Currency not found: ${from}`);
      }
      amountInEUR = amount / fromRate.rate;
    }

    if (to === 'EUR') {
      return amountInEUR;
    } else {
      const toRate = rates.value.find((r) => r.currency === to);
      if (!toRate) {
        throw new Error(`Currency not found: ${to}`);
      }
      return amountInEUR * toRate.rate;
    }
  }

  return {
    rates,
    fetchRates,
    convert
  };
});
