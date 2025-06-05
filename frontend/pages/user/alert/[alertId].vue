<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Alert</h1>
      <UiCard>
        <UiMapPoints
          :data="mapPoints"
          @marker:click="
            (event) => $router.replace({ hash: `#request-${event.id}` })
          "
        />
        <h3 class="font-semibold">{{ data?.alert?.content }}</h3>
        <p>{{ data?.alert?.budget }}</p>
      </UiCard>
      <div v-if="data?.requests.length" class="flex flex-col gap-2">
        <CardRequest
          v-for="request in data.requests"
          :key="`request-${request.id}`"
          :request="request"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Alert } from '~/types/alert';
import type { Request } from '~/types/request';

definePageMeta({
  middleware: 'auth'
});

const route = useRoute();
const requestFetch = useRequestFetch();
const mapPoints = computed(() => {
  if (!data.value) {
    return [];
  }

  const requests = data.value.requests
    .filter(
      (
        request
      ): request is Request & {
        location: { x: number; y: number };
        radius: number;
      } => request.location !== null && request.radius !== null
    )
    .map((request) => ({
      id: request.id,
      location: request.location,
      radius: request.radius,
      content: request.content,
      color: 'blue',
      clickable: true
    }));

  const alert = {
    id: data.value.alert.id,
    location: data.value.alert.location,
    radius: data.value.alert.radius,
    content: 'Your alert',
    color: 'red'
  };

  return [...requests, alert];
});

const { data } = useAsyncData('alert', async () => {
  const response = await requestFetch<{ alert: Alert; requests: Request[] }>(
    useRuntimeConfig().public.apiBase +
      '/api/user/alert/' +
      route.params.alertId,
    {
      credentials: 'include'
    }
  );
  return response;
});
</script>
