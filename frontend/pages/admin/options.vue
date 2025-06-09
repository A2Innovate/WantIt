<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin / Options</h1>
      <UiCard>
        <UiTextArea v-model="log" class="resize-none h-64 w-full" readonly />
        <UiButton>Start</UiButton>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});

const log = ref('');
</script>
