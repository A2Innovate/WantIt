<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin / Users</h1>
      <UiCard class="flex flex-col gap-2">
        <UiInput
          v-model="query"
          placeholder="Search..."
          @update:model-value="refresh"
        />
      </UiCard>
      <UiCard>
        <div v-for="user in users" :key="user.id">
          <div class="flex py-2">
            <NuxtLink
              class="flex w-full justify-start items-center gap-2 hover:text-neutral-300 transition-colors"
              :to="`/user/${user.id}`"
            >
              <div class="w-5 h-5 rounded-full bg-neutral-700">
                <div
                  class="w-full h-full flex items-center justify-center font-medium text-xs"
                >
                  {{ user.name.charAt(0).toUpperCase() }}
                </div>
              </div>
              <p>{{ user.name }}</p>
            </NuxtLink>
            <p>{{ user.email }}</p>
          </div>
          <hr
            v-if="user !== users?.[users.length - 1]"
            class="border-neutral-700"
          />
        </div>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';

const query = ref('');

const requestFetch = useRequestFetch();
definePageMeta({
  middleware: ['auth', 'admin']
});

const { data: users, refresh } = useAsyncData('admin-users', async () => {
  const response = await requestFetch<User[]>(
    useRuntimeConfig().public.apiBase + '/api/admin/users',
    {
      params: {
        query: query.value
      },
      credentials: 'include'
    }
  );
  return response;
});
</script>
