import type { Notification } from '~/types/notification';

export const useNotificationStore = defineStore('notification', () => {
  const current = ref<Notification[]>([]);

  async function fetchNotifications() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<Notification[]>(() =>
      requestFetch<Notification[]>(
        useRuntimeConfig().public.apiBase + '/api/notification',
        {
          credentials: 'include'
        }
      )
    );

    current.value = response.value ?? [];
  }

  return {
    current,
    fetchNotifications
  };
});
