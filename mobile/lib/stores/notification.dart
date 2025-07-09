import 'package:mobile/types/notification.dart';

List<NotificationData> _notifications = [];

/*
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
 */
