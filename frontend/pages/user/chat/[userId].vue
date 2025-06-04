<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <UiCard v-if="!error" class="m-4">
      <div class="flex flex-col gap-4">
        <div class="flex items-center gap-2">
          <div class="w-16 h-16 rounded-full bg-neutral-700">
            <div
              class="w-full h-full flex items-center justify-center font-medium text-2xl"
            >
              {{ data?.person.name.charAt(0) }}
            </div>
          </div>
          <div>
            <h2 v-if="data" class="text-xl font-semibold">
              {{ data.person.name }}
            </h2>
            <UiSkeleton v-else class="w-24 h-4" />
            <h3 v-if="data" class="text-xs text-neutral-400">
              @{{ data.person.username }}
            </h3>
            <UiSkeleton v-else class="w-16 h-4 mt-1" />
          </div>
        </div>
        <div
          ref="messagesContainer"
          class="flex flex-col gap-2 px-0.5 max-h-[calc(90vh-13rem)] overflow-y-auto [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-track]:bg-neutral-700 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-neutral-500"
        >
          <UiMessage
            v-for="message in data?.messages"
            :key="message.id"
            :message="message"
          />
          <div v-if="!data" class="flex flex-col gap-2">
            <UiSkeleton
              v-for="i in 5"
              :key="i"
              class="h-18 w-3/5"
              :class="i % 2 === 0 ? 'self-end' : 'self-start'"
            />
          </div>
        </div>
      </div>
      <form class="flex gap-2 mt-2" @submit.prevent="handleSend">
        <UiInput
          v-model="content"
          placeholder="Type your message..."
          class="w-full"
        />
        <UiButton type="submit">
          <Icon name="material-symbols:send-rounded" />
          Send
        </UiButton>
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

definePageMeta({
  middleware: 'auth'
});

const route = useRoute();
const userStore = useUserStore();
const pusher = usePusher();
const api = useApi();
const messageStore = useMessageStore();
const sendError = ref('');
const requestFetch = useRequestFetch();
const content = ref('');
const messagesContainer = ref<HTMLDivElement>();
let channel: Channel;

if (Number(route.params.userId) === userStore.current?.id) {
  navigateTo('/');
}

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
  requestAnimationFrame(() => {
    if (!messagesContainer.value) return;
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

    messageStore.upsertLastMessage({
      personId: Number(route.params.userId),
      senderName: userStore.current!.name,
      senderUsername: userStore.current!.username,
      createdAt: response.data.createdAt,
      content: response.data.content
    });
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

    messageStore.upsertLastMessage({
      personId: Number(route.params.userId),
      senderName: data.value!.person.name,
      senderUsername: data.value!.person.username,
      createdAt: message.createdAt,
      content: message.content
    });
  });

  channel.bind('update-message', (update: { id: number; content: string }) => {
    const index = data.value?.messages.findIndex((m) => m.id === update.id);
    if (index) {
      data.value!.messages[index] = {
        ...data.value!.messages[index],
        content: update.content,
        edited: true
      };
    }
  });
});

onUnmounted(() => {
  channel.unsubscribe();
  channel.unbind('new-message');
});
</script>
