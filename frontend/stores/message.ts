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
    const { data: response } = await useAsyncData<LastMessage[]>(() =>
      requestFetch<LastMessage[]>(
        useRuntimeConfig().public.apiBase + '/api/chat',
        {
          credentials: 'include'
        }
      )
    );

    lastMessages.value = response.value ?? [];
  }

  return {
    lastMessages,
    fetchLastMessages
  };
});
