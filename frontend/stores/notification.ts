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

  async function markAsRead(notification: Notification) {
    notification.read = true;
    await useApi().post(`/notification/${notification.id}/read`);
  }

  async function deleteNotification(notification: Notification) {
    current.value = current.value.filter((n) => n.id !== notification.id);
    await useApi().delete(`/notification/${notification.id}`);
  }

  async function clearNotifications() {
    current.value = [];
    await useApi().post('/notification/clear');
  }

  return {
    current,
    fetchNotifications,
    markAsRead,
    deleteNotification,
    clearNotifications
  };
});
