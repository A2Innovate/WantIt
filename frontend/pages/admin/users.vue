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
        <CardAdminUsersRecord
          v-for="user in users"
          :key="user.id"
          :user="user"
          :is-last="user === users?.[users.length - 1]"
        />
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';
import type { Channel } from 'pusher-js';

const query = ref('');
const requestFetch = useRequestFetch();
const pusher = usePusher();
let channel: Channel;

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

onMounted(() => {
  channel = pusher.subscribe('private-admin-users');

  channel.bind(
    'update-user-block',
    (data: { userId: number; isBlocked: boolean }) => {
      const user = users.value?.find((user) => user.id === data.userId);

      if (user) {
        user.isBlocked = data.isBlocked;
      }
    }
  );
});

onUnmounted(() => {
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
