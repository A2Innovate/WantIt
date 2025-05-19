<template>
  <UiModal card-class="sm:min-w-sm" :is-open="isOpen" @close="emit('close')">
    <div class="flex flex-col items-center gap-4">
      <div class="w-16 h-16 rounded-full bg-neutral-700">
        <div
          class="w-full h-full flex items-center justify-center font-medium text-2xl"
        >
          {{ user.name.charAt(0) }}
        </div>
      </div>
      <h2 class="text-2xl font-semibold">{{ user.name }}</h2>
    </div>
  </UiModal>
</template>

<script setup lang="ts">
defineProps<{
  isOpen: boolean;
  user: {
    name: string;
  };
}>();

const emit = defineEmits(['close']);
</script>
