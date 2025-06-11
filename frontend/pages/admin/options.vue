<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin / Options</h1>
      <UiCard class="flex flex-col gap-2">
        <UiButton
          class="w-full"
          :loading="integrityCheckLoading"
          @click="integrityCheck"
        >
          S3/DB Integrity check
        </UiButton>
        <UiTextArea
          v-model="log"
          placeholder="Logs will appear here..."
          class="resize-none h-64 w-full"
          readonly
        />
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Channel } from 'pusher-js';

definePageMeta({
  middleware: ['auth', 'admin']
});

const pusher = usePusher();
const integrityCheckLoading = ref(false);
const api = useApi();
const log = ref('');
let channel: Channel;

async function integrityCheck() {
  integrityCheckLoading.value = true;
  log.value = '';
  try {
    await api.post('/admin/integrity/s3-db');
  } finally {
    integrityCheckLoading.value = false;
  }
}

onMounted(() => {
  channel = pusher.subscribe('private-admin-options');

  channel.bind('integrity-check-log', (data: { message: string }) => {
    log.value += `${data.message}\n`;
  });
});

onUnmounted(() => {
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
