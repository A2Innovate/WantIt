<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <div class="flex items-center justify-between">
        <h1 class="text-xl font-semibold">Alerts</h1>
        <UiButton class="h-7" @click="isOpen = true">
          <Icon name="material-symbols:add" />
        </UiButton>
      </div>
      <UiCard class="flex flex-col gap-2">
        <UiCard
          v-for="alert in data"
          :key="alert.id"
          :as="NuxtLink"
          :to="`/user/alert/${alert.id}`"
          class="hover:bg-neutral-700 transition-colors"
        >
          <h3 class="font-semibold">{{ alert.content }}</h3>
          <p>
            <span class="text-sm text-neutral-400">{{
              COMPARISON_MODES.find(
                (mode) => mode.value === alert.budgetComparisonMode
              )?.label
            }}</span>

            {{ priceFmt(alert.budget, alert.currency) }}
          </p>
        </UiCard>
        <UiSkeletonLoader v-if="!data && !error" class="h-96 w-full" />
        <p v-else-if="error" class="text-red-500 text-center">
          {{ error.message }}
        </p>
        <p v-else-if="data?.length === 0" class="text-center text-neutral-400">
          No alerts found
        </p>
      </UiCard>
    </div>
    <Teleport to="body">
      <ModalNewAlert :is-open="isOpen" @close="isOpen = false" />
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { NuxtLink } from '#components';
import type { Alert } from '~/types/alert';
import type { Channel } from 'pusher-js';

definePageMeta({
  middleware: 'auth'
});

const pusher = usePusher();
const isOpen = ref(false);
const requestFetch = useRequestFetch();
let channel: Channel;

const { data, error } = useAsyncData('alerts', async () => {
  const response = await requestFetch<Alert[]>(
    useRuntimeConfig().public.apiBase + '/api/user/alerts',
    {
      credentials: 'include'
    }
  );
  return response;
});

onMounted(() => {
  channel = pusher.subscribe(
    `private-user-${useUserStore().current?.id}-alerts`
  );

  channel.bind('new-alert', (alert: Alert) => {
    if (data.value) {
      data.value.push(alert);
    }
  });

  channel.bind('delete-alert', ({ alertId }: { alertId: number }) => {
    if (data.value) {
      data.value = data.value.filter((alert) => alert.id !== alertId);
    }
  });

  channel.bind('update-alert', ({ alert }: { alert: Alert }) => {
    if (data.value) {
      const index = data.value.findIndex((a) => a.id === alert.id);
      if (index !== -1) {
        data.value[index] = alert;
      }
    }
  });
});

onUnmounted(() => {
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
