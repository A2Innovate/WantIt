<template>
  <UiCard class="hover:bg-neutral-700 transition-colors cursor-pointer">
    <p>{{ request.content }}</p>
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
import type { Request } from '~/types/request';

defineProps<{ request: Request }>();
</script>
