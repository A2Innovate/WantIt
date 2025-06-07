<template>
  <div>
    <Icon
      v-for="i in amount"
      :key="i"
      :name="
        i <= value ? 'material-symbols:star' : 'material-symbols:star-outline'
      "
      size="1.5rem"
      class="text-amber-300"
      :class="{
        'cursor-pointer transition-colors hover:text-amber-100': !readonly
      }"
      @click="handleClick(i)"
    />
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(
  defineProps<{ value: number; amount?: number; readonly?: boolean }>(),
  {
    amount: 5
  }
);

const emit = defineEmits(['update:modelValue']);

function handleClick(i: number) {
  if (!props.readonly) {
    emit('update:modelValue', i);
  }
}
</script>
