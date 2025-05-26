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

if (!userStore.current) {
  await userStore.fetchUser();
}

messageStore.fetchLastMessages();
</script>
