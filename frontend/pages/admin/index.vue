<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
        <UiCard>
          <Transition name="slide-up-blur" mode="out-in">
            <p v-if="stats" :key="stats.users" class="text-6xl font-semibold">
              {{ stats?.users }}
            </p>
            <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          </Transition>
          <p>Users</p>
        </UiCard>
        <UiCard>
          <Transition name="slide-up-blur" mode="out-in">
            <p
              v-if="stats"
              :key="stats.requests"
              class="text-6xl font-semibold"
            >
              {{ stats?.requests }}
            </p>
            <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          </Transition>
          <p>Requests</p>
        </UiCard>
        <UiCard>
          <Transition name="slide-up-blur" mode="out-in">
            <p v-if="stats" :key="stats.offers" class="text-6xl font-semibold">
              {{ stats?.offers }}
            </p>
            <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          </Transition>
          <p>Offers</p>
        </UiCard>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <CardAdminStats type="requests" />
        <CardAdminStats type="offers" />
        <CardAdminStats type="users" />
        <CardAdminStatsRatelimitsHit />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Channel } from 'pusher-js';

definePageMeta({
  middleware: ['auth', 'admin']
});

const pusher = usePusher();
const requestFetch = useRequestFetch();
let channel: Channel;

const { data: stats } = useAsyncData('admin-stats', async () => {
  const response = await requestFetch<{
    users: string;
    offers: string;
    requests: string;
  }>(useRuntimeConfig().public.apiBase + '/api/admin/stats', {
    credentials: 'include'
  });
  return {
    users: Number(response.users),
    offers: Number(response.offers),
    requests: Number(response.requests)
  };
});

onMounted(() => {
  channel = pusher.subscribe('private-admin-stats');

  channel.bind('update-users', (data: number) => {
    if (stats.value) {
      stats.value.users += data;
    }
  });

  channel.bind('update-requests', (data: number) => {
    if (stats.value) {
      stats.value.requests += data;
    }
  });

  channel.bind('update-offers', (data: number) => {
    if (stats.value) {
      stats.value.offers += data;
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
