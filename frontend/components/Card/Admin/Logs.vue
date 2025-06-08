<template>
  <UiCard class="relative px-0 py-0 overflow-hidden">
    <div
      class="pointer-events-none rounded-lg absolute bottom-0 left-0 right-0 h-full bg-gradient-to-t from-black/80 to-transparent"
    />

    <div class="h-96 overflow-y-auto [&::-webkit-scrollbar]:w-0 relative">
      <TransitionGroup name="slide-down-blur" tag="div">
        <div v-for="log in logs" :key="log.id">
          <div
            class="hover:bg-neutral-800 flex justify-between items-center transition-colors duration-75 px-4 py-2"
          >
            <div class="w-1/6 flex items-center gap-2">
              <div class="w-5 h-5 rounded-full bg-neutral-700">
                <div
                  class="w-full h-full flex items-center justify-center font-medium text-xs"
                >
                  S
                </div>
              </div>
              <p>System</p>
            </div>
            <p class="w-4/6">{{ log.message }}</p>
            <p class="text-xs text-neutral-400 w-1/6 text-right">
              {{ formatTime(new Date(log.createdAt)) }}
            </p>
          </div>
          <hr v-if="log !== logs[logs.length - 1]" class="border-neutral-800" />
        </div>
      </TransitionGroup>
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
