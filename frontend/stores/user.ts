import type { User, UserSession } from '@/types/user';

export const useUserStore = defineStore('user', () => {
  const current = ref<User | null>(null);
  const sessions = ref<UserSession[] | null>(null);

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
    sessions.value = null;
  }

  async function fetchSessions() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<UserSession[]>(() =>
      requestFetch(useRuntimeConfig().public.apiBase + '/api/auth/sessions', {
        credentials: 'include'
      })
    );

    sessions.value = response.value;
  }

  return {
    current,
    sessions,
    fetchUser,
    logout,
    fetchSessions
  };
});
