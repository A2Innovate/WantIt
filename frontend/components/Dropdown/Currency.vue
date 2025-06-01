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
    <DropdownBasePopup :is-open="isOpen">
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
