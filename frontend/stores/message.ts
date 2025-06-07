interface LastMessage {
  createdAt: string;
  content: string;
  person: {
    id: number;
    name: string;
    username: string;
  };
}

export const useMessageStore = defineStore('message', () => {
  const lastMessages = ref<LastMessage[]>([]);

  async function fetchLastMessages() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<LastMessage[]>(
      'last-messages',
      () =>
        requestFetch<LastMessage[]>(
          useRuntimeConfig().public.apiBase + '/api/chat',
          {
            credentials: 'include'
          }
        )
    );

    lastMessages.value = response.value ?? [];
  }

  async function refreshLastMessages() {
    const response = await useApi().get<LastMessage[]>('/chat');
    lastMessages.value = response.data;
  }

  function upsertLastMessage({
    personId,
    senderName,
    senderUsername,
    createdAt,
    content
  }: {
    personId: number;
    senderName: string;
    senderUsername: string;
    createdAt: string;
    content: string;
  }) {
    const index = lastMessages.value.findIndex(
      (msg) => msg.person.id === personId
    );

    if (index === -1) {
      lastMessages.value.push({
        createdAt,
        content,
        person: {
          id: personId,
          name: senderName,
          username: senderUsername
        }
      });
    } else {
      lastMessages.value[index] = {
        ...lastMessages.value[index],
        createdAt,
        content
      };
    }
  }

  return {
    lastMessages,
    fetchLastMessages,
    refreshLastMessages,
    upsertLastMessage
  };
});
