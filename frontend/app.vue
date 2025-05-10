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

if (!userStore.current) {
  await userStore.fetchUser();
}
</script>
