<template>
  <div ref="dropdownRef" class="relative">
    <DropdownBaseTrigger
      class="rounded-lg"
      wfull
      :readonly="readonly"
      :is-open="isOpen"
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
        v-for="option in options"
        :key="option.value"
        @click="
          isOpen = false;
          emit('update:modelValue', option.value);
        "
      >
        <p class="break-all">{{ option.label }}</p>
      </DropdownBaseElement>
    </DropdownBasePopup>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  modelValue: string;
  options: { value: string; label: string }[];
  readonly?: boolean;
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
