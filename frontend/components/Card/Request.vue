<template>
  <UiCard
    class="hover:bg-neutral-700 transition-colors"
    :as="NuxtLink"
    :to="`/request/${request.id}`"
  >
    <p class="text-lg font-medium mb-2 break-words">{{ request.content }}</p>
    <div class="flex gap-2 mt-1">
      <span
        class="px-2 py-0.5 rounded-full text-xs font-medium bg-green-700 text-green-100"
      >
        {{ priceFmt(request.budget, request.currency) }}
      </span>
    </div>
    <div class="flex justify-between items-center">
      <p class="text-xs text-neutral-400">
        {{ formatTime(new Date(request.createdAt)) }}
      </p>
      <div
        v-if="request.user.id"
        class="flex w-fit gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full"
      >
        <Icon name="material-symbols:account-circle" />
        <p class="text-sm">{{ request.user.username }}</p>
      </div>
    </div>
  </UiCard>
</template>

<script setup lang="ts">
import { NuxtLink } from '#components';
import type { Request } from '~/types/request';

defineProps<{ request: Request }>();
</script>
