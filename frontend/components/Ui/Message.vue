<template>
  <div
    :class="[
      'p-4 rounded-lg border border-neutral-700 bg-neutral-900 flex flex-col break-all w-full max-w-56 sm:max-w-xs',
      side === 'left' ? 'self-start' : 'self-end'
    ]"
  >
    <p>{{ content }}</p>
    <ClientOnly>
      <span class="text-sm text-neutral-400 self-end">{{
        formatTime(props.time)
      }}</span>
    </ClientOnly>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  content: string;
  time: Date;
  side: 'left' | 'right';
}>();
</script>
