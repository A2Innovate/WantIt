<template>
  <input
    class="bg-neutral-900 px-4 py-2 rounded-lg outline-0 hover:ring focus:ring focus:ring-neutral-700 ring-neutral-800 transition-all"
    :value="modelValue"
    v-bind="$attrs"
    @input="handleInput"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string;
}>();

const emit = defineEmits(['update:modelValue']);

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).value);
}
</script>
