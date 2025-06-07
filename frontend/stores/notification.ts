import type { Notification } from '~/types/notification';

export const useNotificationStore = defineStore('notification', () => {
  const current = ref<Notification[]>([]);

  async function fetchNotifications() {
    const requestFetch = useRequestFetch();
    const { data: response } = await useAsyncData<Notification[]>(
      'notifications',
      () =>
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
    try {
      notification.read = true;
      await useApi().post(`/notification/${notification.id}/read`);
    } catch (e) {
      console.error(e);
      notification.read = false;
    }
  }

  async function deleteNotification(notification: Notification) {
    try {
      current.value = current.value.filter((n) => n.id !== notification.id);
      await useApi().delete(`/notification/${notification.id}`);
    } catch (e) {
      console.error(e);
      current.value.push(notification);
    }
  }

  async function clearNotifications() {
    const oldNotifications = [...current.value];

    try {
      current.value = [];
      await useApi().post('/notification/clear');
    } catch (e) {
      console.error(e);
      current.value = oldNotifications;
    }
  }

  return {
    current,
    fetchNotifications,
    markAsRead,
    deleteNotification,
    clearNotifications
  };
});
