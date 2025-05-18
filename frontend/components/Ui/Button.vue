<template>
  <button
    class="bg-neutral-900 px-4 py-2 rounded-lg hover:bg-neutral-800 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    v-bind="$attrs"
  >
    <slot />
  </button>
</template>

<script setup lang="ts"></script>
