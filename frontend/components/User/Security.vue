<template>
  <UiCard card-class="sm:min-w-md">
    <h2 class="text-2xl font-semibold mb-2">Sessions</h2>
    <div class="flex flex-col gap-2">
      <UiCard
        v-for="session in userStore.sessions"
        :key="session.id"
        class="flex items-center justify-between"
      >
        <p>Session {{ session.id }}</p>
        <ClientOnly>
          <p class="text-sm text-neutral-400">
            Expires {{ formatTime(new Date(session.expiresAt)) }}
          </p>
        </ClientOnly>
      </UiCard>
    </div>
  </UiCard>
</template>

<script setup lang="ts">
const userStore = useUserStore();

userStore.fetchSessions();
</script>
