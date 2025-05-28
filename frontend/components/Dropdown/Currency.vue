<template>
  <div ref="dropdownRef" class="relative">
    <button
      class="flex items-center justify-between w-18 h-full px-3 bg-neutral-800 hover:bg-neutral-700 border border-neutral-600 rounded-l-lg transition-all"
      @click="toggleDropdown"
    >
      <span class="text-neutral-300 text-sm font-medium">{{
        selectedCurrency
      }}</span>
      <Icon
        name="material-symbols:keyboard-arrow-down"
        class="text-neutral-400 transition-all duration-200 shrink-0"
        :class="{ 'rotate-180': isOpen }"
        size="1.25em"
      />
    </button>
    <Transition
      enter-active-class="transition ease-out duration-100"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-75"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="isOpen"
        class="absolute mt-2 w-48 h-64 overflow-y-scroll bg-neutral-800 border border-neutral-600 rounded-lg shadow-lg z-10 divide-y divide-neutral-700 [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-track]:bg-neutral-700 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-neutral-500"
      >
        <div
          v-for="currency in CURRENCIES_NAMES"
          :key="currency.currency"
          class="px-4 py-2 text-neutral-300 hover:bg-neutral-700 cursor-pointer transition-colors"
          @click="
            selectedCurrency = currency.currency;
            isOpen = false;
            emit('update:modelValue', currency.currency);
          "
        >
          <p>{{ currency.currency }}</p>
          <small class="text-neutral-400 text-xs">{{ currency.name }}</small>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string;
}>();
const emit = defineEmits(['update:modelValue']);
const isOpen = ref(false);
const selectedCurrency = ref('USD');
const dropdownRef = ref<HTMLElement | null>(null);

const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
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
