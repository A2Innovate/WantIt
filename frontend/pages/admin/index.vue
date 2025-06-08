<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <UiCard>
          <div class="flex items-center justify-between mb-2">
            <h2 class="sm:text-xl">
              Accounts created in the last
              <span class="font-semibold">30</span> days
            </h2>
            <UiButton
              icon="material-symbols:refresh"
              size="small"
              :loading="isLoadingUsers"
              @click="refreshUsers()"
            />
          </div>
          <UiChartLine v-if="users" :x="users.day" :y="users.count" />
        </UiCard>

        <UiCard>
          <div class="flex items-center justify-between mb-2">
            <h2 class="sm:text-xl">
              Requests created in the last
              <span class="font-semibold">30</span> days
            </h2>
            <UiButton
              icon="material-symbols:refresh"
              size="small"
              :loading="isLoadingRequests"
              @click="refreshRequests()"
            />
          </div>
          <UiChartLine v-if="requests" :x="requests.day" :y="requests.count" />
        </UiCard>

        <UiCard>
          <div class="flex items-center justify-between mb-2">
            <h2 class="sm:text-xl">
              Offers created in the last
              <span class="font-semibold">30</span> days
            </h2>
            <UiButton
              icon="material-symbols:refresh"
              size="small"
              :loading="isLoadingOffers"
              @click="refreshOffers()"
            />
          </div>
          <UiChartLine v-if="offers" :x="offers.day" :y="offers.count" />
        </UiCard>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Stats } from '~/types/stats';

const isLoadingUsers = ref(false);
const isLoadingRequests = ref(false);
const isLoadingOffers = ref(false);

definePageMeta({
  middleware: ['auth', 'admin']
});

const requestFetch = useRequestFetch();
const { data: users, refresh: refreshUsers } = await useAsyncData(
  'users',
  async () => {
    isLoadingUsers.value = true;
    const response = await requestFetch<Stats>(
      useRuntimeConfig().public.apiBase + '/api/admin/stats/users',
      {
        credentials: 'include'
      }
    );
    isLoadingUsers.value = false;
    return response;
  }
);

const { data: requests, refresh: refreshRequests } = await useAsyncData(
  'requests',
  async () => {
    isLoadingRequests.value = true;
    const response = await requestFetch<Stats>(
      useRuntimeConfig().public.apiBase + '/api/admin/stats/requests',
      {
        credentials: 'include'
      }
    );
    isLoadingRequests.value = false;
    return response;
  }
);

const { data: offers, refresh: refreshOffers } = await useAsyncData(
  'offers',
  async () => {
    isLoadingOffers.value = true;
    const response = await requestFetch<Stats>(
      useRuntimeConfig().public.apiBase + '/api/admin/stats/offers',
      {
        credentials: 'include'
      }
    );
    isLoadingOffers.value = false;
    return response;
  }
);
</script>
