<template>
  <Transition
    enter-active-class="transition ease-out duration-100"
    enter-from-class="opacity-0 scale-95"
    enter-to-class="opacity-100 scale-100"
    leave-active-class="transition ease-in duration-75"
    leave-from-class="opacity-100 scale-100"
    leave-to-class="opacity-0 scale-95"
  >
    <div
      v-if="isOpen"
      class="absolute mt-2 w-48 max-h-48 sm:max-h-64 overflow-y-auto bg-neutral-900 border border-neutral-600 rounded-lg shadow-lg z-10 divide-y divide-neutral-700 [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-track]:bg-neutral-700 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-neutral-500"
      :class="popupClass"
    >
      <slot />
    </div>
  </Transition>
</template>

<script setup lang="ts">
const props = defineProps<{
  isOpen: boolean;
  popupClass?: string;
  dropdownRef?: HTMLElement;
}>();
const emit = defineEmits(['update:isOpen']);

function closeDropdown(e: MouseEvent) {
  if (props.dropdownRef && !props.dropdownRef.contains(e.target as Node)) {
    emit('update:isOpen', false);
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', closeDropdown);
});
</script>
