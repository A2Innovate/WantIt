import type { Request } from '@/types/request';

export const useRequestStore = defineStore('request', () => {
  const offset = ref(0);
  const lastQuery = ref('');
  const query = ref('');
  const isFetching = ref(false);
  const api = useApi();

  const { data, refresh } = useAsyncData<Request[]>(
    'requests',
    async (): Promise<Request[]> => {
      const isSameQuery = query.value === lastQuery.value;
      lastQuery.value = query.value;
      if (!isSameQuery) {
        data.value = [];
      }

      isFetching.value = true;
      const response = await api.get('/request', {
        params: {
          content: query.value,
          offset: data.value?.length ?? 0
        }
      });

      isFetching.value = false;
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
    isFetching,
    refresh,
    offset,
    query
  };
});
