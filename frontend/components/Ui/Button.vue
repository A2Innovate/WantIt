<template>
  <component
    :is="as"
    class="bg-neutral-900 px-4 py-2 flex items-center justify-center gap-2 rounded-lg hover:bg-neutral-800 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    v-bind="$attrs"
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
    as: 'button'
  }
);
</script>
