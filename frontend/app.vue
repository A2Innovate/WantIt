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

const pusher = usePusher();
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
});

onUnmounted(() => {
  userChannel.unbind_all();
  userChannel.unsubscribe();
});
</script>
