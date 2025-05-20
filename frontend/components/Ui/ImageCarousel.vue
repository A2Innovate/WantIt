<template>
  <div class="relative">
    <div class="flex overflow-x-scroll scroll-0 snap-x snap-mandatory gap-2">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="snap-center w-full h-full object-cover flex-shrink-0"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ images: string[] }>();
</script>

<style scoped>
.scroll-0::-webkit-scrollbar {
  display: none;
}
</style>
