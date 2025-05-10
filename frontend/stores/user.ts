import type { User } from '@/types/user';

export const useUserStore = defineStore('user', () => {
  const current = ref<User | null>(null);

  async function fetchUser() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<User>(() =>
      requestFetch(useRuntimeConfig().public.apiBase + '/api/auth')
    );

    current.value = response.value;
  }

  async function logout() {
    await useApi().post('/auth/logout');
    current.value = null;
  }

  return {
    current,
    fetchUser,
    logout
  };
});
