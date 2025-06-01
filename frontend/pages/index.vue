<template>
  <div>
    <div class="min-h-[calc(100vh-3.5rem)] flex justify-center">
      <div class="flex flex-col gap-4 w-full max-w-xl mt-4 sm:mt-32 mx-4">
        <h2 class="text-2xl sm:text-3xl font-semibold text-center">
          <WhatDoYouWant />
        </h2>
        <div class="flex gap-2">
          <UiInput
            v-model="requestStore.query"
            placeholder="An iPhone..."
            class="w-2/3"
            @update:model-value="requestStore.refresh()"
          />
          <CategoryDropdown
            v-model="requestStore.category"
            placeholder="Category"
            class="w-1/3"
            @update:model-value="requestStore.refresh()"
          />
        </div>
        <div
          v-if="!requestStore.isFetching"
          class="flex flex-col gap-2 sm:mb-32 mb-4"
        >
          <CardRequest
            v-for="request in requestStore.requests"
            :key="request.id"
            :request="request"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import CategoryDropdown from "~/components/CategoryDropdown.vue";
const requestStore = useRequestStore();
</script>
