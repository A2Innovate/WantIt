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
          <div v-if="requestStore.isFetching" class="flex flex-col gap-2">
            <UiSkeletonLoader v-for="i in 2" :key="i" class="h-28" />
          </div>
          <UiButton
            v-if="requestStore.requests?.length"
            @click="
              requestStore.offset = requestStore.requests.length;
              requestStore.refresh();
            "
          >
            <Icon name="material-symbols:arrow-downward-rounded" />
            Load more
          </UiButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const requestStore = useRequestStore();

requestStore.refresh();
</script>
