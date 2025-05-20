<template>
  <div class="max-w-2xl mx-auto">
    <UiCard v-if="!error && user" class="m-4">
      <div class="m-4 flex flex-col gap-4">
        <div class="flex flex-col items-center gap-4">
          <div class="w-16 h-16 rounded-full bg-neutral-700">
            <div
              class="w-full h-full flex items-center justify-center font-medium text-2xl"
            >
              {{ user.name.charAt(0) }}
            </div>
          </div>
          <h2 class="text-2xl font-semibold">{{ user.name }}</h2>
        </div>
      </div>
      <h2 class="text-xl font-semibold mt-6 mb-4 mx-4">Requests</h2>
      <div class="flex flex-col gap-2">
        <CardRequest
          v-for="request in user.requests"
          :key="request.id"
          :request="{
            ...request,
            user: {
              id: user.id,
              name: user.name
            }
          }"
        />
      </div>
    </UiCard>
    <UiCard v-else-if="error" class="m-4">
      <p class="text-red-500 text-center">
        <span v-if="error.statusCode === 404"
          >User {{ route.params.userId }} not found
        </span>
        <span v-else> {{ error.message }}</span>
      </p>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';
import type { Request } from '~/types/request';

const route = useRoute();
const api = useApi();

const { data: user, error } = useAsyncData<
  User & { requests: Omit<Request, 'user'>[] }
>('user', async () => {
  const response = await api.get(`/user/${route.params.userId}`);
  return response.data;
});
</script>
