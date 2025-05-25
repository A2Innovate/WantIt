interface LastMessage {
  createdAt: string;
  content: string;
  sender: {
    id: number;
    name: string;
  };
}

export const useMessageStore = defineStore('message', () => {
  const lastMessages = ref<LastMessage[]>([]);

  async function fetchLastMessages() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<LastMessage[]>(() =>
      requestFetch(useRuntimeConfig().public.apiBase + '/api/chat')
    );

    lastMessages.value = response.value ?? [];
  }

  return {
    lastMessages,
    fetchLastMessages
  };
});
