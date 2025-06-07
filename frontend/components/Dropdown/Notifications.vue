<template>
  <div ref="dropdownRef" class="relative">
    <button
      class="flex gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
      @click="toggleDropdown"
    >
      <Transition
        enter-active-class="transition ease-out"
        enter-from-class="opacity-0 scale-75"
        enter-to-class="opacity-100 scale-100"
        leave-active-class="transition ease-in"
        leave-from-class="opacity-100 scale-100"
        leave-to-class="opacity-0 scale-75"
      >
        <span
          v-if="unreadCount"
          class="text-xs rounded-full bg-red-500 w-4 h-4 flex items-center justify-center absolute bottom-5 left-5"
          >{{ unreadCount }}</span
        >
      </Transition>
      <Icon name="material-symbols:notifications" />
    </button>
    <DropdownBasePopup
      :is-open="isOpen"
      popup-class="right-0"
      :dropdown-ref="dropdownRef"
      @update:is-open="isOpen = $event"
    >
      <div
        v-if="notificationStore.current.length"
        class="p-2 flex justify-between"
      >
        <p v-if="unreadCount" class="text-neutral-400 text-xs">
          {{ unreadCount }} unread
        </p>
        <button
          class="text-neutral-400 text-xs hover:text-neutral-300 transition cursor-pointer flex items-center gap-1"
          @click="notificationStore.clearNotifications()"
        >
          <Icon name="material-symbols:delete" size="1em" />
          Clear
        </button>
      </div>
      <DropdownBaseElement
        v-for="notification in notificationStore.current.sort(
          (a, b) => b.id - a.id
        )"
        :key="notification.id"
        :class="notification.read ? '' : 'bg-neutral-800'"
        @click="
          isOpen = false;
          notificationStore.deleteNotification(notification);
        "
        @mouseover="
          !notification.read && notificationStore.markAsRead(notification)
        "
      >
        <NuxtLink :to="getLink(notification)" class="text-sm">
          <p v-if="notification.type === NotificationType.NEW_OFFER">
            <span class="font-semibold">{{
              notification.relatedRequest?.content
            }}</span>
            has a new offer
          </p>
          <p v-else-if="notification.type === NotificationType.NEW_MESSAGE">
            <span class="font-semibold">{{
              notification.relatedUser?.name
            }}</span>
            sent you a message
          </p>
          <p
            v-else-if="notification.type === NotificationType.NEW_OFFER_COMMENT"
          >
            <span class="font-semibold">{{
              notification.relatedUser?.name
            }}</span>
            commented on your offer
            <span class="font-semibold">{{
              notification.relatedOffer?.content
            }}</span>
          </p>
          <p v-else-if="notification.type === NotificationType.NEW_ALERT_MATCH">
            <span class="font-semibold">{{
              notification.relatedRequest?.content
            }}</span>
            matched with your alert
          </p>
          <small class="text-neutral-400 text-xs">{{
            formatTime(new Date(notification.createdAt))
          }}</small>
        </NuxtLink>
      </DropdownBaseElement>
      <p
        v-if="!notificationStore.current.length"
        class="text-center m-4 text-neutral-400"
      >
        No notifications
      </p>
    </DropdownBasePopup>
  </div>
</template>

<script setup lang="ts">
import { NuxtLink } from '#components';
import { NotificationType } from '~/types/notification';
import type { Notification } from '~/types/notification';

const notificationStore = useNotificationStore();
const isOpen = ref(false);
const dropdownRef = ref<HTMLElement | undefined>(undefined);

const unreadCount = computed(() => {
  return notificationStore.current.filter((n) => !n.read).length;
});

const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
};

function getLink(notification: Notification) {
  if (
    notification.type === NotificationType.NEW_OFFER ||
    notification.type === NotificationType.NEW_OFFER_COMMENT ||
    notification.type === NotificationType.NEW_ALERT_MATCH
  ) {
    return `/request/${notification.relatedRequestId}`;
  }

  if (notification.type === NotificationType.NEW_MESSAGE) {
    return `/user/chat/${notification.relatedUserId}`;
  }

  return '#';
}
</script>
