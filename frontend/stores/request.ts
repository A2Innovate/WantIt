import type { Request } from '@/types/request';

export const useRequestStore = defineStore('request', () => {
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
      }

      const response = await api.get('/request', {
        params: {
          content: query.value,
          offset: data.value?.length ?? 0
        }
      });

      if (!isSameQuery) {
        return response.data;
      } else {
        return [...new Set([...(data.value ?? []), ...response.data])];
      }
    },
    {
      dedupe: 'cancel'
    }
  );

  return {
    requests: data,
    status,
    refresh,
    query
  };
});
