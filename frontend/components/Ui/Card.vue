<template>
  <component
    :is="as"
    class="p-4 rounded-lg border border-neutral-700 bg-neutral-950"
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
    as: 'div'
  }
);
</script>
