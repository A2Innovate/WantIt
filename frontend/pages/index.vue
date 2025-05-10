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
          @input="refresh"
        />
        <div class="flex flex-col gap-2">
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
const query = ref('');

const { data, refresh } = await useAsyncData<Request[]>(
  'requests',
  async () => {
    const response = await api.get('/request', {
      params: {
        content: query.value
      }
    });
    return response.data;
  }
);
</script>
