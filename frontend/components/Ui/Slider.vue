<template>
  <input
    class="accent-neutral-600"
    type="range"
    :value="modelValue"
    v-bind="$attrs"
    @input="handleInput"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue: number;
}>();
const emit = defineEmits(['update:modelValue']);

function handleInput(event: Event) {
  emit('update:modelValue', Number((event.target as HTMLInputElement).value));
}
</script>
