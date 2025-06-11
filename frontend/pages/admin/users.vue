<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin / Users</h1>
      <UiCard class="flex flex-col gap-2">
        <UiInput
          v-model="query"
          placeholder="Search..."
          @update:model-value="fetchUsers"
        />
      </UiCard>
      <UiCard>
        <div v-if="!isFetching && users?.length">
          <CardAdminUsersRecord
            v-for="user in users"
            :key="user.id"
            :user="user"
            :is-last="user === users?.[users.length - 1]"
          />
        </div>
        <UiSkeletonLoader v-else-if="isFetching" class="h-64" />
        <p
          v-else-if="users?.length === 0 && !isFetching"
          class="text-center text-neutral-400"
        >
          No users found
        </p>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';
import type { Channel } from 'pusher-js';

const query = ref('');
const requestFetch = useRequestFetch();
const lastQuery = ref('');
const loadedAll = ref(false);
const users = ref<User[]>([]);
const isFetching = ref(false);
const PAGE_SIZE = 50;
const pusher = usePusher();
let channel: Channel;

definePageMeta({
  middleware: ['auth', 'admin']
});

async function fetchUsers() {
  isFetching.value = true;
  try {
    const isSameQuery = query.value === lastQuery.value;
    lastQuery.value = query.value;

    if (!isSameQuery) {
      users.value = [];
      loadedAll.value = false;
    }

    const response = await requestFetch<User[]>(
      useRuntimeConfig().public.apiBase + '/api/admin/users',
      {
        params: {
          query: query.value,
          limit: PAGE_SIZE,
          offset: users.value?.length ?? 0
        },
        credentials: 'include'
      }
    );

    if (response.length < PAGE_SIZE) {
      loadedAll.value = true;
    }

    users.value = [...users.value, ...response];
  } finally {
    isFetching.value = false;
  }
}

function handleScroll() {
  if (users.value?.length && !loadedAll.value && !isFetching.value) {
    const distanceToBottom =
      document.documentElement.scrollHeight -
      (window.scrollY + window.innerHeight);
    if (distanceToBottom < window.innerHeight) {
      fetchUsers();
    }
  }
}

callOnce(fetchUsers);

onMounted(() => {
  window.addEventListener('scroll', handleScroll);

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
  window.removeEventListener('scroll', handleScroll);

  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
