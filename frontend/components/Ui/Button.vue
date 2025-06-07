<template>
  <component
    :is="as"
    class="bg-neutral-900 flex items-center justify-center gap-2 rounded-lg hover:bg-neutral-800 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    :class="{
      'px-2 py-1': size === 'small',
      'px-4 py-2': size === 'medium',
      'px-6 py-3': size === 'large',
      'border border-neutral-700': variant === 'outline'
    }"
    :disabled="loading || disabled"
    v-bind="$attrs"
  >
    <UiLoader v-if="loading" :size="1" variant="white" />
    <Icon v-else-if="icon" :name="icon" />
    <slot />
  </component>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    as?: string | Component;
    icon?: string;
    loading?: boolean;
    disabled?: boolean;
    size?: 'small' | 'medium' | 'large';
    variant?: 'default' | 'outline';
  }>(),
  {
    as: 'button',
    icon: undefined,
    loading: false,
    disabled: false,
    size: 'medium',
    variant: 'default'
  }
);
</script>
