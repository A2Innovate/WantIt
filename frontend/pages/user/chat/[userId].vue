<template>
  <div class="max-w-2xl mx-auto">
    <UiCard v-if="!error && data" class="m-4">
      <div class="flex flex-col gap-4">
        <div class="flex flex-col items-center gap-4">
          <div class="w-16 h-16 rounded-full bg-neutral-700">
            <div
              class="w-full h-full flex items-center justify-center font-medium text-2xl"
            >
              {{ data.sender.name.charAt(0) }}
            </div>
          </div>
          <h2 class="text-2xl font-semibold">{{ data.sender.name }}</h2>
        </div>
        <div class="flex flex-col-reverse gap-2">
          <UiMessage
            v-for="message in data.messages"
            :key="message.id"
            :content="message.content"
            :time="message.createdAt"
            :side="
              useUserStore().current?.id === message.sender.id
                ? 'right'
                : 'left'
            "
          />
        </div>
      </div>
      <form class="flex gap-2 mt-2" @submit.prevent="handleSend">
        <UiInput
          v-model="content"
          placeholder="Type your message..."
          class="w-full"
        />
        <UiButton type="submit">Send</UiButton>
      </form>
    </UiCard>
    <UiCard v-else-if="error" class="m-4">
      <p class="text-red-500 text-center">
        <span v-if="error.statusCode === 404"
          >Chat with user {{ route.params.userId }} not found
        </span>
        <span v-else> {{ error.message }}</span>
      </p>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
import type { Chat } from '~/types/chat';

const route = useRoute();
const requestFetch = useRequestFetch();
const content = ref('');

const { data, error } = useAsyncData<Chat>(async () => {
  const response = await requestFetch<Chat>(
    useRuntimeConfig().public.apiBase + '/api/chat/' + route.params.userId,
    {
      credentials: 'include'
    }
  );
  return response;
});

function handleSend() {
  content.value = '';
  // TODO
}
</script>
