<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
    <NuxtRouteAnnouncer />
  </div>
</template>

<script setup lang="ts">
import type { Channel } from 'pusher-js';
import type { Notification } from '~/types/notification';
import { NotificationType } from '~/types/notification';

const pusher = usePusher();
const route = useRoute();
const userStore = useUserStore();
const messageStore = useMessageStore();
const currencyStore = useCurrencyStore();
const notificationStore = useNotificationStore();

if (!userStore.current) {
  await userStore.fetchUser();
}

currencyStore.fetchRates();
messageStore.fetchLastMessages();
notificationStore.fetchNotifications();

let userChannel: Channel;

onMounted(() => {
  userChannel = pusher.subscribe(`private-user-${userStore.current?.id}`);

  userChannel.bind('notification-read', (data: { notificationId: number }) => {
    notificationStore.current.find((n) => n.id === data.notificationId)!.read =
      true;
  });

  userChannel.bind('new-notification', (data: Notification) => {
    const isUserViewingChat =
      data.type === NotificationType.NEW_MESSAGE &&
      route.name === 'user-chat-userId' &&
      route.params.userId == data.relatedUserId.toString();

    const isUserViewingRequest =
      (data.type === NotificationType.NEW_OFFER ||
        data.type === NotificationType.NEW_OFFER_COMMENT) &&
      route.name === 'request-requestId' &&
      route.params.requestId == data.relatedRequestId.toString();

    if (isUserViewingChat || isUserViewingRequest) {
      notificationStore.deleteNotification(data);
      return;
    }

    notificationStore.current.push(data);
  });

  userChannel.bind(
    'notification-delete',
    (data: { notificationId: number }) => {
      notificationStore.current = notificationStore.current.filter(
        (n) => n.id !== data.notificationId
      );
    }
  );

  userChannel.bind('notification-clear', () => {
    notificationStore.current = [];
  });
});

onUnmounted(() => {
  userChannel.unbind_all();
  userChannel.unsubscribe();
});
</script>
