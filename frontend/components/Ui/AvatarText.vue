<template>
  <div
    class="rounded-full bg-neutral-700"
    :class="{
      'w-5 h-5': size === 'small',
      'w-6 h-6': size === 'medium',
      'w-8 h-8': size === 'large'
    }"
  >
    <div
      class="w-full h-full flex items-center justify-center font-medium text-xs capitalize"
    >
      <span>{{ text }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{ text?: string; size?: 'small' | 'medium' | 'large' }>(),
  {
    text: '',
    size: 'medium'
  }
);
</script>
