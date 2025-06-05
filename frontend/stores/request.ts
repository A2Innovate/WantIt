import type { Request } from '@/types/request';

export const useRequestStore = defineStore('request', () => {
  const loadedAll = ref(false);
  const lastQuery = ref('');
  const query = ref('');
  const api = useApi();

  const { data, refresh, status } = useAsyncData<Request[]>(
    'requests',
    async (): Promise<Request[]> => {
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
        }
      });

      if (response.data.length < 10) {
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
