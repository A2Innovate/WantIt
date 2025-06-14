import type { Request } from '@/types/request';

const PAGE_SIZE = 10;

export const useRequestStore = defineStore('request', () => {
  const loadedAll = ref(false);
  const lastQuery = ref('');
  const query = ref('');
  const api = useApi();
  const currentAbortController = ref<AbortController | null>(null);

  const { data, refresh, status } = useAsyncData<Request[]>(
    'requests',
    async (): Promise<Request[]> => {
      currentAbortController.value?.abort();
      currentAbortController.value = new AbortController();

      const isSameQuery = query.value === lastQuery.value;
      lastQuery.value = query.value;

      if (!isSameQuery) {
        data.value = [];
        loadedAll.value = false;
      }

      const response = await api.get('/request', {
        params: {
          content: query.value,
          offset: data.value?.length ?? 0
        },
        signal: currentAbortController.value?.signal
      });

      if (response.data.length < PAGE_SIZE) {
        loadedAll.value = true;
      }

      return [...(data.value ?? []), ...response.data];
    },
    {
      dedupe: 'cancel'
    }
  );

  return {
    requests: data,
    status,
    loadedAll,
    refresh,
    query
  };
});
