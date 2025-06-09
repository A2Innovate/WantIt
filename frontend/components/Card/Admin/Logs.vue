<template>
  <UiCard class="relative px-0 py-0 overflow-hidden">
    <Transition name="slide-up-blur" mode="out-in">
      <div v-if="logs">
        <div
          class="pointer-events-none rounded-lg absolute bottom-0 left-0 right-0 h-full bg-gradient-to-t from-black/80 to-transparent"
        />

        <div
          ref="containerRef"
          class="h-96 overflow-y-auto [&::-webkit-scrollbar]:w-0 relative"
        >
          <TransitionGroup name="slide-down-blur" tag="div">
            <div v-for="log in logs" :key="log.id">
              <div
                class="hover:bg-neutral-800 flex md:flex-row gap-1 md:gap-0 flex-col justify-between items-center transition-colors duration-75 px-4 py-2"
              >
                <NuxtLink
                  class="md:w-1/6 flex w-full justify-start items-center gap-2"
                  :class="
                    log.user ? 'hover:text-neutral-300 transition-colors' : ''
                  "
                  :to="log.user ? `/user/${log.user?.id}` : ''"
                >
                  <div class="w-5 h-5 rounded-full bg-neutral-700">
                    <div
                      class="w-full h-full flex items-center justify-center font-medium text-xs"
                    >
                      {{ getAvatar(log) }}
                    </div>
                  </div>
                  <p
                    :class="
                      log.ip ? 'blur-xs hover:blur-none transition-all' : ''
                    "
                  >
                    {{ log.user?.name || log.ip || 'System' }}
                  </p>
                </NuxtLink>
                <div class="w-full md:w-4/6">
                  <p v-if="log.type === 'USER_LOGIN'">Logged in</p>
                  <p v-else-if="log.type === 'USER_LOGIN_FAILURE'">
                    Failed to log in
                  </p>
                  <p v-else-if="log.type === 'USER_LOGOUT'">Logged out</p>
                  <p v-else-if="log.type === 'USER_REGISTRATION'">Registered</p>
                  <p v-else-if="log.type === 'REQUEST_CREATE'">
                    Created request
                  </p>
                  <p v-else-if="log.type === 'REQUEST_UPDATE'">
                    Updated request
                  </p>
                  <p v-else-if="log.type === 'REQUEST_DELETE'">
                    Deleted request
                  </p>
                  <p v-else-if="log.type === 'OFFER_CREATE'">Created offer</p>
                  <p v-else-if="log.type === 'OFFER_UPDATE'">Updated offer</p>
                  <p v-else-if="log.type === 'OFFER_DELETE'">Deleted offer</p>
                  <p v-else-if="log.type === 'RATELIMIT_HIT'">Hit rate limit</p>
                </div>
                <ClientOnly>
                  <p
                    class="text-xs text-neutral-400 w-full md:w-1/6 text-right"
                  >
                    {{ formatTime(new Date(log.createdAt)) }}
                  </p>
                </ClientOnly>
              </div>
              <hr
                v-if="log !== logs?.[logs.length - 1]"
                class="border-neutral-800"
              />
            </div>
          </TransitionGroup>
        </div>
      </div>
      <UiSkeletonLoader v-else :loader-size="2" class="h-96" />
    </Transition>
  </UiCard>
</template>

<script setup lang="ts">
import type { Channel } from 'pusher-js';
import type { Log } from '~/types/log';

const requestFetch = useRequestFetch();
const pusher = usePusher();
const PAGE_SIZE = 50;
const loadedAll = ref(false);
const logs = ref<Log[]>([]);
const isFetching = ref(false);
const containerRef = ref<HTMLDivElement | null>(null);
let channel: Channel;

function getAvatar(log: Log) {
  if (log.user) {
    return log.user.name.charAt(0).toUpperCase();
  }

  if (log.ip) {
    return 'IP';
  }

  return 'S';
}

async function fetchLogs() {
  isFetching.value = true;
  try {
    const response = await requestFetch<Log[]>(
      useRuntimeConfig().public.apiBase + '/api/admin/logs',
      {
        params: {
          limit: PAGE_SIZE,
          offset: logs.value?.length ?? 0
        },
        credentials: 'include'
      }
    );

    if (response.length < PAGE_SIZE) {
      loadedAll.value = true;
    }

    logs.value = [...logs.value, ...response];
  } finally {
    isFetching.value = false;
  }
}

function handleScroll() {
  if (
    logs.value?.length &&
    !loadedAll.value &&
    containerRef.value &&
    !isFetching.value
  ) {
    const isNearBottom =
      containerRef.value.scrollHeight -
        (containerRef.value.scrollTop + containerRef.value.clientHeight) <
      containerRef.value.clientHeight;

    if (isNearBottom) {
      fetchLogs();
    }
  }
}

fetchLogs();

onMounted(() => {
  containerRef.value?.addEventListener('scroll', handleScroll);
  channel = pusher.subscribe('private-admin-logs');

  channel.bind('new-log', (data: Log) => {
    if (logs.value) {
      data.createdAt = new Date().toISOString();
      logs.value.unshift(data);
    }
  });
});

onUnmounted(() => {
  containerRef.value?.removeEventListener('scroll', handleScroll);
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
