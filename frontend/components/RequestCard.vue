<template>
  <UiCard
    class="hover:bg-neutral-700 transition-colors"
    :as="NuxtLink"
    :to="`/request/${request.id}`"
  >
    <p class="text-lg font-medium mb-2 break-words">{{ request.content }}</p>
    <div class="flex gap-2 mt-1">
      <span
        class="flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-700 text-green-100"
      >
        <Icon name="material-symbols:attach-money" class="mr-1" />
        {{ request.budget }}
      </span>
    </div>
    <div class="flex justify-end">
      <div
        class="flex w-fit gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full"
      >
        <Icon name="material-symbols:account-circle" />
        <p class="text-sm">{{ request.user.name }}</p>
      </div>
    </div>
  </UiCard>
</template>

<script setup lang="ts">
import { NuxtLink } from '#components';
import type { Request } from '~/types/request';

defineProps<{ request: Request }>();
</script>
