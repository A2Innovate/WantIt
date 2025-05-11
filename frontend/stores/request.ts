import type { Request } from '@/types/request';

export const useRequestStore = defineStore('request', () => {
  const query = ref('');
  const isFetching = ref(false);
  const api = useApi();

  const { data: requests, refresh } = useAsyncData<Request[]>(
    'requests',
    async () => {
      isFetching.value = true;
      const response = await api.get('/request', {
        params: {
          content: query.value
        }
      });
      isFetching.value = false;
      return response.data;
    }
  );

  return {
    requests,
    isFetching,
    refresh,
    query
  };
});
