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
    <DropdownBasePopup :is-open="isOpen">
      <DropdownBaseElement
        v-for="option in options"
        :key="option.value"
        @click="
          isOpen = false;
          emit('update:modelValue', option.value);
        "
      >
        <p>{{ option.label }}</p>
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
const dropdownRef = ref<HTMLElement | null>(null);

const toggleDropdown = () => {
  if (!props.readonly) {
    isOpen.value = !isOpen.value;
  }
};

function closeDropdown(e: MouseEvent) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    isOpen.value = false;
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', closeDropdown);
});
</script>
