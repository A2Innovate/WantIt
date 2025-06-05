<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Alert</h1>
      <UiCard>
        <UiMapPoints
          v-if="data?.alert.location"
          class="mb-4"
          :data="mapPoints"
          @marker:click="
            (event) => {
              highlightId = event.id;
              $router.replace({ hash: `#request-${event.id}` });
            }
          "
        />
        <UiSkeletonLoader v-else-if="!data" class="mb-4 h-60 w-full" />
        <h3 v-if="data">{{ data.alert.content }}</h3>
        <UiSkeleton v-else class="h-6 w-1/2" />
        <p v-if="data" class="flex items-center gap-1">
          {{ priceFmt(data.alert.budget, data.alert.currency) }}
          <ConvertedPrice
            class="text-xs"
            :currency="data.alert.currency"
            :amount="data.alert.budget"
          />
        </p>
        <UiSkeleton v-else class="h-6 w-24 mt-1" />
      </UiCard>
      <div v-if="data?.requests.length" class="flex flex-col gap-2">
        <CardRequest
          v-for="request in data.requests"
          :id="`request-${request.id}`"
          :key="request.id"
          :class="{
            'ring-1 ring-neutral-400': highlightId === request.id
          }"
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
const highlightId = ref<number | null>(null);
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
