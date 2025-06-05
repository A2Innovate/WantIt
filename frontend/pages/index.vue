<template>
  <div>
    <div class="min-h-[calc(100vh-3.5rem)] flex justify-center">
      <div class="flex flex-col gap-4 w-full max-w-xl mt-4 sm:mt-32 mx-4">
        <h2 class="text-2xl sm:text-3xl font-semibold text-center">
          <WhatDoYouWant />
        </h2>
        <UiInput
          v-model="requestStore.query"
          placeholder="An iPhone..."
          class="w-full"
          @update:model-value="requestStore.refresh()"
        />
        <div class="flex flex-col gap-2 sm:mb-32 mb-4">
          <CardRequest
            v-for="request in requestStore.requests"
            :key="request.id"
            :request="request"
          />
          <div
            v-if="requestStore.status === 'pending'"
            class="flex flex-col gap-2"
          >
            <UiSkeletonLoader v-for="i in 10" :key="i" class="h-28" />
          </div>
          <p
            v-if="
              !requestStore.requests?.length &&
              requestStore.status === 'success'
            "
            class="text-center text-neutral-500"
          >
            No requests found
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const requestStore = useRequestStore();

if (!requestStore.requests?.length) {
  requestStore.refresh();
}

function handleScroll() {
  if (requestStore.requests?.length && !requestStore.loadedAll) {
    const distanceToBottom =
      document.documentElement.scrollHeight -
      (window.scrollY + window.innerHeight);
    if (distanceToBottom < window.innerHeight) {
      requestStore.refresh();
    }
  }
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll);
});

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll);
});
</script>
