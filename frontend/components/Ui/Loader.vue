<template>
  <div
    class="rounded-full animate-spin"
    :class="{
      'border-t-neutral-700 border-neutral-800': variant === 'default',
      'border-t-neutral-500 border-neutral-600': variant === 'white'
    }"
    :style="{
      width: size + 'rem',
      height: size + 'rem',
      borderWidth: size / 8 + 'rem'
    }"
  ></div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ size?: number; variant?: 'default' | 'white' }>(), {
  size: 2,
  variant: 'default'
});
</script>
