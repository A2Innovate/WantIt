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
  const requestFetch = useRequestFetch();
  const { data: lastMessages, refresh: fetchLastMessages } = useAsyncData<
    LastMessage[]
  >('last-messages', () =>
    requestFetch<LastMessage[]>(
      useRuntimeConfig().public.apiBase + '/api/chat',
      {
        credentials: 'include'
      }
    )
  );

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
    if (!lastMessages.value) {
      return;
    }

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
    upsertLastMessage
  };
});
