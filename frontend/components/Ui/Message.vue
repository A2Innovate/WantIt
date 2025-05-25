<template>
  <div
    :class="[
      'p-4 rounded-lg border border-neutral-700 bg-neutral-900 flex flex-col break-all w-sm',
      side === 'left' ? 'self-start' : 'self-end'
    ]"
  >
    <p>{{ content }}</p>
    <span class="text-sm text-neutral-400 self-end">{{
      formatTime(new Date(time))
    }}</span>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  content: string;
  time: string;
  side: 'left' | 'right';
}>();
</script>
