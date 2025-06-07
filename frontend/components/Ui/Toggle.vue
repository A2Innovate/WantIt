<template>
  <label class="inline-flex items-center cursor-pointer">
    <input
      type="checkbox"
      value=""
      class="sr-only peer"
      :checked="modelValue"
      :disabled="disabled"
      @change="handleInput"
    />
    <div
      class="relative w-11 h-6 peer-focus:outline-none rounded-full peer bg-neutral-700 peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-neutral-600 after:border after:rounded-full after:h-5 after:w-5 after:transition-all border-neutral-800 peer-checked:bg-sky-600"
    ></div>
  </label>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: boolean;
  disabled?: boolean;
}>();

const emit = defineEmits(['update:modelValue']);

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).checked);
}
</script>
