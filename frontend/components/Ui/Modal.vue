<template>
  <Transition name="fade" mode="out-in">
    <div
      v-if="isOpen"
      class="fixed top-0 w-full h-screen flex items-center justify-center bg-black/50 backdrop-blur-sm z-100"
      @click.self="emit('close')"
    >
      <UiCard :class="cardClass">
        <slot />
      </UiCard>
    </div>
  </Transition>
</template>

<script setup lang="ts">
defineProps<{
  isOpen: boolean;
  cardClass?: string;
}>();

const emit = defineEmits(['close']);
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease-in-out;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
