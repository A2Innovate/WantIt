<template>
  <div class="max-w-2xl mx-auto">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Chat</h1>
      <UiCard>
        <div class="flex flex-col gap-2">
          <UiCard
            v-for="message in messageStore.lastMessages"
            :key="message.sender.id"
          >
            <p>{{ message.sender.name }}</p>
            <p>{{ message.content }}</p>
          </UiCard>
        </div>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
const messageStore = useMessageStore();
</script>
