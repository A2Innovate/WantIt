<template>
  <input
    class="accent-neutral-600"
    :checked="modelValue"
    type="checkbox"
    v-bind="$attrs"
    @input="handleInput"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue: boolean;
}>();

const emit = defineEmits(['update:modelValue']);

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).checked);
}
</script>
