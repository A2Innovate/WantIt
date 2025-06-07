<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <UiCard> </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});
</script>
