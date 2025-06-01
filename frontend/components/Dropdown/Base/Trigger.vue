<template>
  <button
    :class="[
      'flex items-center h-full px-3 bg-neutral-800 hover:bg-neutral-700 border border-neutral-600 rounded-l-lg transition-all',
      {
        'justify-center w-14': readonly,
        'justify-between w-18': !readonly
      }
    ]"
    type="button"
    @click="emit('click')"
  >
    <slot />
    <Icon
      v-if="!readonly"
      name="material-symbols:keyboard-arrow-down"
      class="text-neutral-400 transition-all duration-200 shrink-0"
      :class="{ 'rotate-180': isOpen }"
      size="1.25em"
    />
  </button>
</template>

<script setup lang="ts">
defineProps<{
  readonly?: boolean;
  isOpen?: boolean;
}>();

const emit = defineEmits(['click']);
</script>
