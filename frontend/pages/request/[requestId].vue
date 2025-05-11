<template>
  <div class="max-w-3xl mx-auto">
    <h1 class="text-xl font-semibold my-4 px-4">Request</h1>
    <UiCard v-if="!error" class="m-4">
      <p v-if="request">{{ request.content }}</p>
      <p v-else>Loading...</p>
      <p v-if="request">${{ request.budget }}</p>
      <div class="flex justify-end">
        <div
          class="flex w-fit gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full"
        >
          <Icon name="material-symbols:account-circle" />
          <p v-if="request" class="text-sm">{{ request.user.name }}</p>
          <p v-else>Loading...</p>
        </div>
      </div>
    </UiCard>
    <UiCard v-else-if="error" class="m-4">
      <p class="text-red-500 text-center">
        <span v-if="error.statusCode === 404"
          >Request {{ route.params.requestId }} not found
        </span>
        <span v-else> {{ error.message }}</span>
      </p>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
import type { Request } from '~/types/request';

const route = useRoute();
const api = useApi();

const { data: request, error } = useAsyncData<Request>('request', async () => {
  const response = await api.get(`/request/${route.params.requestId}`);
  return response.data;
});
</script>
