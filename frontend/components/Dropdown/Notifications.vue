<template>
  <div ref="dropdownRef" class="relative">
    <button
      class="flex gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
      @click="toggleDropdown"
    >
      <span
        v-if="notificationStore.current.filter((n) => !n.read).length"
        class="text-xs rounded-full bg-red-500 w-4 h-4 flex items-center justify-center absolute bottom-5 left-5"
        >{{ notificationStore.current.filter((n) => !n.read).length }}</span
      >
      <Icon name="material-symbols:notifications" />
    </button>
    <DropdownBasePopup :is-open="isOpen" popup-class="right-0">
      <DropdownBaseElement
        v-for="notification in notificationStore.current.sort(
          (a, b) => b.id - a.id
        )"
        :key="notification.id"
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
const dropdownRef = ref<HTMLElement | null>(null);

const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
};

function closeDropdown(e: MouseEvent) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    isOpen.value = false;
  }
}

function getLink(notification: Notification) {
  if (
    notification.type === NotificationType.NEW_OFFER ||
    notification.type === NotificationType.NEW_OFFER_COMMENT
  ) {
    return `/request/${notification.relatedRequestId}`;
  }
  if (notification.type === NotificationType.NEW_MESSAGE) {
    return `/user/chat/${notification.relatedUserId}`;
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', closeDropdown);
});
</script>
