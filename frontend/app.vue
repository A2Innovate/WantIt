<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
    <NuxtRouteAnnouncer />
  </div>
</template>

<script setup lang="ts">
const userStore = useUserStore();
const messageStore = useMessageStore();
const currencyStore = useCurrencyStore();

if (!userStore.current) {
  await userStore.fetchUser();
}

currencyStore.fetchRates();
messageStore.fetchLastMessages();
</script>
