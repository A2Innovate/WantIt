<template>
  <span
    v-if="userStore.current && userStore.current.preferredCurrency !== currency"
    >(≈
    {{
      priceFmt(
        currencyStore.convert(
          currency,
          userStore.current.preferredCurrency,
          amount
        ),
        userStore.current.preferredCurrency
      )
    }})</span
  >
</template>

<script setup lang="ts">
defineProps<{ currency: string; amount: number }>();

const userStore = useUserStore();
const currencyStore = useCurrencyStore();
</script>
