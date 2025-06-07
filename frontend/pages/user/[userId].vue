<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <UiCard v-if="!error" class="m-4">
      <div class="m-4 flex flex-col gap-4">
        <div class="flex flex-col items-center gap-2">
          <div class="w-16 h-16 rounded-full bg-neutral-700">
            <div
              v-if="user"
              class="w-full h-full flex items-center justify-center font-medium text-2xl"
            >
              {{ user.name.charAt(0) }}
            </div>
          </div>
          <h2 v-if="user" class="text-2xl font-semibold mt-2">
            {{ user.name }}
          </h2>
          <UiSkeleton v-else class="w-28 h-4 mt-2" />
          <h3 v-if="user" class="text-sm">@{{ user.username }}</h3>
          <UiSkeleton v-else class="w-20 h-4" />
        </div>
      </div>
      <div class="flex gap-2">
        <UiButton v-if="user" class="w-full" @click="isReviewsModalOpen = true">
          <Icon name="material-symbols:star" />
          Reviews
        </UiButton>
        <UiButton
          v-if="
            user &&
            userStore.current &&
            Number(route.params.userId) != userStore.current.id
          "
          class="w-full"
          :as="NuxtLink"
          :to="`/user/chat/${route.params.userId}`"
        >
          <Icon name="material-symbols:chat" />
          Send message
        </UiButton>
        <UiSkeleton v-else-if="!user" class="h-8 w-full" />
      </div>
      <h2
        v-if="user?.requests.length"
        class="text-xl font-semibold mt-6 mb-4 mx-4"
      >
        Requests
      </h2>
      <UiSkeleton v-else-if="!user" class="h-4 w-24 mt-6 mb-4 mx-4" />
      <div v-if="user" class="flex flex-col gap-2">
        <CardRequest
          v-for="request in user.requests"
          :key="request.id"
          :request="{
            ...request,
            user: {
              id: user.id,
              name: user.name,
              username: user.username
            }
          }"
        />
      </div>
      <div v-else class="flex flex-col gap-2">
        <UiSkeleton v-for="i in 5" :key="i" class="h-28" />
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
    <Teleport to="body">
      <ModalReviews
        :is-open="isReviewsModalOpen"
        :user-id="route.params.userId as string"
        @close="isReviewsModalOpen = false"
      />
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';
import type { Request } from '~/types/request';
import { NuxtLink } from '#components';

const isReviewsModalOpen = ref(false);
const userStore = useUserStore();
const route = useRoute();
const api = useApi();

const { data: user, error } = useAsyncData<
  User & { requests: Omit<Request, 'user'>[] }
>(`user-${route.params.userId}`, async () => {
  const response = await api.get(`/user/${route.params.userId}`);
  return response.data;
});
</script>
