<template>
  <textarea
    class="bg-neutral-900 px-4 py-2 min-h-10 rounded-lg outline-0 hover:ring focus:ring focus:ring-neutral-700 ring-neutral-800 transition-all [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-track]:bg-neutral-700 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-neutral-500"
    v-bind="$attrs"
    :value="modelValue"
    @input="handleInput"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string;
}>();

const emit = defineEmits(['update:modelValue']);

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLTextAreaElement).value);
}
</script>
