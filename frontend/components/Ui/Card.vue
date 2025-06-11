<template>
  <component
    :is="as"
    class="p-4 rounded-lg border bg-neutral-950 transition-all"
    :class="{
      'border-neutral-700': variant === 'default',
      'border-green-500 shadow-lg shadow-green-500/20': variant === 'success'
    }"
    v-bind="$attrs"
  >
    <slot />
  </component>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    as?: string | Component;
    variant?: 'default' | 'success';
  }>(),
  {
    as: 'div',
    variant: 'default'
  }
);
</script>
