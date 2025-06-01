<template>
    <div ref="dropdownRef" class="relative">
      <button
        :class="[
          'flex items-center justify-between h-12 w-full px-4 bg-neutral-800 hover:bg-neutral-700 border border-neutral-600 rounded-lg text-neutral-300 text-base font-medium transition-all duration-200',
          props.triggerClass
        ]"
        type="button"
        @click="toggleDropdown"
      >
        <span class="truncate" v-text="props.modelValue"></span>
        <Icon
          name="material-symbols:keyboard-arrow-down"
          class="text-neutral-400 transition-transform duration-200"
          :class="{ 'rotate-180': isOpen }"
          size="1.5em"
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
          class="absolute mt-2 w-full max-h-64 overflow-y-auto bg-neutral-800 border border-neutral-600 rounded-lg shadow-lg z-10 divide-y divide-neutral-700"
        >
          <div
            v-for="category in REQUEST_CATEGORIES"
            :key="category"
            class="px-4 py-2 text-neutral-300 hover:bg-neutral-700 cursor-pointer transition-colors"
            @click="
              isOpen = false;
              emit('update:modelValue', category);
            "
          >
            {{ category }}
          </div>
        </div>
      </Transition>
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
    