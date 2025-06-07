<template>
  <div ref="dropdownRef" class="relative">
    <DropdownBaseTrigger
      :readonly="readonly"
      :is-open="isOpen"
      :class="triggerClass"
      @click="toggleDropdown"
    >
      <span class="text-neutral-300 text-sm font-medium" v-text="modelValue" />
    </DropdownBaseTrigger>
    <DropdownBasePopup
      :is-open="isOpen"
      :dropdown-ref="dropdownRef"
      @update:is-open="isOpen = $event"
    >
      <DropdownBaseElement
        v-for="currency in CURRENCIES_NAMES"
        :key="currency.currency"
        @click="
          isOpen = false;
          emit('update:modelValue', currency.currency);
        "
      >
        <p>{{ currency.currency }}</p>
        <small class="text-neutral-400 text-xs">{{ currency.name }}</small>
      </DropdownBaseElement>
    </DropdownBasePopup>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  modelValue: string;
  readonly?: boolean;
  triggerClass?: string;
}>();

const emit = defineEmits(['update:modelValue']);
const isOpen = ref(false);
const dropdownRef = ref<HTMLElement | undefined>(undefined);

const toggleDropdown = () => {
  if (!props.readonly) {
    isOpen.value = !isOpen.value;
  }
};
</script>
