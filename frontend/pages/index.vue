<template>
  <div>
    <div class="min-h-[calc(100vh-3.5rem)] flex justify-center">
      <div class="flex flex-col gap-4 w-full max-w-xl mt-4 sm:mt-32 mx-4">
        <h2 class="text-2xl sm:text-3xl font-semibold text-center">
          <WhatDoYouWant />
        </h2>
        <UiInput
          v-model="query"
          placeholder="An iPhone..."
          class="w-full"
          @update:model-value="refresh"
        />
        <div v-if="!isFetching" class="flex flex-col gap-2">
          <RequestCard
            v-for="request in data"
            :key="request.id"
            :request="request"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Request } from '~/types/request';

const api = useApi();
const isFetching = ref(false);
const query = ref('');

const { data, refresh } = useAsyncData<Request[]>('requests', async () => {
  isFetching.value = true;
  const response = await api.get('/request', {
    params: {
      content: query.value
    }
  });
  isFetching.value = false;
  return response.data;
});
</script>
