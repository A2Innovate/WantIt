<template>
  <UiCard card-class="sm:min-w-md">
    <h2 class="text-2xl font-semibold mb-2">{{ t('sessions') }}</h2>
    <div class="flex flex-col gap-2">
      <UiCard
        v-for="session in userStore.sessions"
        :key="session.id"
        class="flex items-center justify-between"
        :class="{
          'border-sky-500 bg-sky-500/10':
            session.id === userStore.current?.sessionId
        }"
      >
        <div class="flex flex-col">
          <div class="flex items-center gap-2">
            <p class="font-medium">{{ t('session_label', { id: session.id }) }}</p>
            <span class="text-sm text-neutral-400">•</span>
            <ClientOnly>
              <p class="text-sm text-neutral-400">
                {{ t('expires_at') }} {{ formatTime(new Date(session.expiresAt)) }}
              </p>
            </ClientOnly>
          </div>
          <p
            class="text-sm text-neutral-400 blur-xs w-fit hover:blur-none transition-all"
          >
            {{ session.ip || t('unknown_ip') }}
          </p>
        </div>
        <UiButton
          v-if="session.id !== userStore.current?.sessionId"
          class="ml-2"
          @click="revokeSession(session.id)"
        >
          {{ t('revoke') }}
        </UiButton>
        <p v-else class="ml-2 text-sm text-neutral-400">{{ t('current_session') }}</p>
      </UiCard>
    </div>
  </UiCard>
</template>

<script setup lang="ts">
const api = useApi();
const userStore = useUserStore();
const { t } = useI18n();

userStore.fetchSessions();

async function revokeSession(sessionId: number) {
  await api.delete(`/auth/session/${sessionId}`);
  userStore.fetchSessions();
}
</script>
