<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
        <UiCard>
          <p v-if="stats" class="text-6xl font-semibold">{{ stats?.users }}</p>
          <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          <p>Users</p>
        </UiCard>
        <UiCard>
          <p v-if="stats" class="text-6xl font-semibold">
            {{ stats?.requests }}
          </p>
          <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          <p>Requests</p>
        </UiCard>
        <UiCard>
          <p v-if="stats" class="text-6xl font-semibold">{{ stats?.offers }}</p>
          <UiSkeletonLoader v-else :loader-size="2" class="h-15 w-full" />
          <p>Offers</p>
        </UiCard>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <CardAdminStats type="requests" />
        <CardAdminStats type="offers" />
        <CardAdminStats type="users" />
        <CardAdminStatsRateLimitExceeded />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});

const requestFetch = useRequestFetch();
const { data: stats } = useAsyncData('admin-stats', async () => {
  const response = await requestFetch<{
    users: number;
    offers: number;
    requests: number;
  }>(useRuntimeConfig().public.apiBase + '/api/admin/stats', {
    credentials: 'include'
  });
  return response;
});
</script>
