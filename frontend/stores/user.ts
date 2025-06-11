import type { User, UserSession } from '@/types/user';

export const useUserStore = defineStore('user', () => {
  const requestFetch = useRequestFetch();
  const { data: current, refresh: fetchUser } = useAsyncData<User>('user', () =>
    requestFetch(useRuntimeConfig().public.apiBase + '/api/auth')
  );

  async function logout() {
    await useApi().post('/auth/logout');
    current.value = null;
    sessions.value = null;
  }

  const { data: sessions, refresh: fetchSessions } = useAsyncData<
    UserSession[]
  >('user-sessions', () =>
    requestFetch<UserSession[]>(
      useRuntimeConfig().public.apiBase + '/api/auth/sessions',
      {
        credentials: 'include'
      }
    )
  );

  return {
    current,
    sessions,
    fetchUser,
    logout,
    fetchSessions
  };
});
