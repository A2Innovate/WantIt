<template>
  <div v-if="images.length" class="relative">
    <div
      ref="scrollContainer"
      class="flex overflow-x-scroll scroll-0 snap-x snap-mandatory gap-2 h-100"
    >
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="snap-center w-full h-full object-contain flex-shrink-0"
      />
    </div>
    <div
      v-if="images.length > 1"
      class="absolute top-0 left-0 w-full h-full flex justify-between items-center pointer-events-none px-4"
    >
      <button
        class="bg-neutral-900/50 hover:bg-neutral-800 transition-colors pointer-events-auto cursor-pointer backdrop-blur-sm p-2 rounded-full flex"
        @click="prevImage"
      >
        <Icon name="material-symbols:chevron-left" size="2em" />
      </button>
      <button
        class="bg-neutral-900/50 hover:bg-neutral-800 transition-colors pointer-events-auto cursor-pointer backdrop-blur-sm p-2 rounded-full flex"
        @click="nextImage"
      >
        <Icon name="material-symbols:chevron-right" size="2em" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ images: string[] }>();

const scrollContainer = ref<HTMLElement | null>(null);

function nextImage() {
  scrollContainer.value?.scrollTo({
    left: scrollContainer.value.scrollLeft + scrollContainer.value.offsetWidth,
    behavior: 'smooth'
  });
}

function prevImage() {
  scrollContainer.value?.scrollTo({
    left: scrollContainer.value.scrollLeft - scrollContainer.value.offsetWidth,
    behavior: 'smooth'
  });
}
</script>

<style scoped>
.scroll-0::-webkit-scrollbar {
  display: none;
}
</style>
