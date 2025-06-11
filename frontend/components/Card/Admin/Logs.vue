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
            <CardAdminLogsRecord
              v-for="log in logs"
              :key="log.id"
              :log="log"
              :is-last="log === logs?.[logs.length - 1]"
            />
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

if (!logs.value?.length) {
  fetchLogs();
}

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
