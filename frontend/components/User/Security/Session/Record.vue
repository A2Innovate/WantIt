<template>
  <UiCard
    class="flex items-center justify-between"
    :class="{
      'border-sky-500 bg-sky-500/10':
        session.id === userStore.current?.sessionId
    }"
  >
    <div class="flex flex-col">
      <div class="flex items-center gap-2">
        <p class="font-medium">Session {{ session.id }}</p>
        <span class="text-sm text-neutral-400">•</span>
        <ClientOnly>
          <p class="text-sm text-neutral-400">
            Expires {{ formatTime(new Date(session.expiresAt)) }}
          </p>
        </ClientOnly>
      </div>
      <p
        class="text-sm text-neutral-400 blur-xs w-fit hover:blur-none transition-all"
      >
        {{ session.ip || 'Unknown IP' }}
      </p>
    </div>
    <UiButton
      v-if="session.id !== userStore.current?.sessionId"
      class="ml-2"
      :loading="isRevoking"
      icon="material-symbols:cancel-rounded"
      @click="revokeSession()"
    >
      Revoke
    </UiButton>
    <p v-else class="ml-2 text-sm text-neutral-400">Current session</p>
  </UiCard>
</template>

<script setup lang="ts">
import type { UserSession } from '~/types/user';

const props = defineProps<{
  session: UserSession;
}>();
const userStore = useUserStore();
const api = useApi();
const isRevoking = ref(false);

async function revokeSession() {
  try {
    isRevoking.value = true;
    await api.delete(`/auth/session/${props.session.id}`);
    userStore.fetchSessions();
  } finally {
    isRevoking.value = false;
  }
}
</script>
