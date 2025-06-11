<template>
  <UiCard card-class="sm:min-w-md">
    <h2 class="text-2xl font-semibold mb-2">Sessions</h2>
    <div class="flex flex-col gap-2">
      <UserSecuritySessionRecord
        v-for="session in userStore.sessions"
        :key="session.id"
        :session="session"
      />
    </div>
  </UiCard>
</template>

<script setup lang="ts">
const userStore = useUserStore();

userStore.fetchSessions();
</script>
