<template>
  <UiCard>
    <div v-for="log in logs" :key="log.id">
      <div>
        <div
          class="hover:bg-neutral-800 flex justify-between items-center transition-colors duration-75 py-1 px-2"
        >
          <p>{{ log.message }}</p>
          <p class="text-xs text-neutral-400">
            {{ formatTime(new Date(log.createdAt)) }}
          </p>
        </div>
        <hr v-if="log !== logs[logs.length - 1]" class="border-neutral-800" />
      </div>
    </div>
  </UiCard>
</template>

<script setup lang="ts">
const logs = ref([
  {
    id: 1,
    message: 'Hello world',
    createdAt: new Date()
  },
  {
    id: 2,
    message: 'Hello world',
    createdAt: new Date().setDate(new Date().getDate() - 1)
  }
]);
</script>
