<template>
  <div class="max-w-2xl mx-auto">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Chat</h1>
      <UiCard>
        <div
          v-if="messageStore.lastMessages.length > 0"
          class="flex flex-col gap-2"
        >
          <UiCard
            v-for="message in messageStore.lastMessages"
            :key="message.person.id"
            :as="NuxtLink"
            :to="`/user/chat/${message.person.id}`"
            class="hover:bg-neutral-800 transition-colors cursor-pointer"
          >
            <div class="flex items-center gap-4">
              <div
                class="w-12 h-12 rounded-full bg-neutral-700 flex items-center justify-center text-xl font-medium"
              >
                {{ message.person.name.charAt(0).toUpperCase() }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <h3 class="font-medium truncate">
                    @{{ message.person.username }}
                  </h3>
                  <span class="text-sm text-neutral-400">
                    {{ formatTime(new Date(message.createdAt)) }}
                  </span>
                </div>
                <p class="text-sm text-neutral-400 truncate">
                  {{ message.content }}
                </p>
              </div>
            </div>
          </UiCard>
        </div>
        <p v-else class="text-center text-neutral-400">No messages</p>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { NuxtLink } from '#components';

const messageStore = useMessageStore();

messageStore.fetchLastMessages();
</script>
