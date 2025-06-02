<template>
  <component
    :is="as"
    class="px-4 py-2 text-neutral-300 hover:bg-neutral-700 cursor-pointer transition-colors"
  >
    <slot />
  </component>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    as?: string | Component;
  }>(),
  {
    as: 'div'
  }
);
</script>
