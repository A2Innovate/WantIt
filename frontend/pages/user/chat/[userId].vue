<template>
  <div class="max-w-2xl mx-auto">
    <UiCard v-if="!error && data" class="m-4">
      <div class="flex flex-col gap-4">
        <div class="flex flex-col items-center gap-4">
          <div class="w-16 h-16 rounded-full bg-neutral-700">
            <div
              class="w-full h-full flex items-center justify-center font-medium text-2xl"
            >
              {{ data.person.name.charAt(0) }}
            </div>
          </div>
          <h2 class="text-2xl font-semibold">{{ data.person.name }}</h2>
        </div>
        <div
          ref="messagesContainer"
          class="flex flex-col gap-2 max-h-[calc(90vh-13rem)] overflow-y-auto"
        >
          <UiMessage
            v-for="message in data.messages"
            :key="message.id"
            :content="message.content"
            :time="new Date(message.createdAt)"
            :side="
              useUserStore().current?.id === message.senderId ? 'right' : 'left'
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
      <p
        v-if="sendError"
        class="text-red-500 mt-2 text-center"
        v-text="sendError"
      ></p>
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
import { AxiosError } from 'axios';
import { sendChatMessageSchema } from '~/schema/services/chat';
import type { Message } from '~/types/message';
import type { Channel } from 'pusher-js';

const route = useRoute();
const userStore = useUserStore();
const pusher = usePusher();
const api = useApi();
const sendError = ref('');
const requestFetch = useRequestFetch();
const content = ref('');
const messagesContainer = ref<HTMLDivElement>();
let channel: Channel;

const { data, error } = useAsyncData<Chat>(async () => {
  const response = await requestFetch<Chat>(
    useRuntimeConfig().public.apiBase + '/api/chat/' + route.params.userId,
    {
      credentials: 'include'
    }
  );
  return response;
});

function scrollToBottom() {
  if (!messagesContainer.value) return;

  requestAnimationFrame(() => {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  });
}

async function handleSend() {
  try {
    const validation = validate(sendChatMessageSchema, {
      content: content.value
    });

    if (validation) {
      sendError.value = validation;
      return;
    }

    const response = await api.post<Message>('/chat/' + route.params.userId, {
      content: content.value
    });

    // Magic trick for Server/Client time desync
    response.data.createdAt = new Date().toISOString();

    data.value?.messages.push(response.data);

    scrollToBottom();
  } catch (e) {
    if (e instanceof AxiosError) {
      error.value = e.response?.data.message;
    }
  }
  content.value = '';
}

onMounted(() => {
  channel = pusher.subscribe(
    `private-user-${userStore.current?.id}-chat-${route.params.userId}`
  );

  channel.bind('new-message', (message: Message) => {
    data.value?.messages.push(message);
    scrollToBottom();
  });
});

onUnmounted(() => {
  channel.unsubscribe();
  channel.unbind('new-message');
});
</script>
