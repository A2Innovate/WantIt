<template>
  <span
    v-if="userStore.current && userStore.current.prefferedCurrency !== currency"
    >(≈
    {{
      priceFmt(
        currencyStore.convert(
          currency,
          userStore.current.prefferedCurrency,
          amount
        ),
        userStore.current.prefferedCurrency
      )
    }})</span
  >
</template>

<script setup lang="ts">
defineProps<{ currency: string; amount: number }>();

const userStore = useUserStore();
const currencyStore = useCurrencyStore();
</script>
