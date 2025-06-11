<template>
  <div class="flex items-center justify-center bg-neutral-900 rounded-lg">
    <UiLoader :size="loaderSize" />
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ loaderSize?: number }>(), {
  loaderSize: 4
});
</script>
