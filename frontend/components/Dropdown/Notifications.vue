<template>
  <div ref="dropdownRef" class="relative">
    <button
      class="flex gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
      @click="toggleDropdown"
    >
      <span
        v-if="notificationStore.current.length"
        class="text-xs rounded-full bg-red-500 w-4 h-4 flex items-center justify-center absolute bottom-5 left-5"
        >{{ notificationStore.current.length }}</span
      >
      <Icon name="material-symbols:notifications" />
    </button>
    <DropdownBasePopup :is-open="isOpen" popup-class="right-0">
      <DropdownBaseElement
        v-for="notification in notificationStore.current"
        :key="notification.id"
        @click="isOpen = false"
      >
        <NuxtLink :to="getLink(notification)" class="text-sm">
          <p v-if="notification.type === NotificationType.NEW_OFFER">
            {{ notification.relatedRequest?.content }} has a new offer
          </p>
          <p v-else-if="notification.type === NotificationType.NEW_MESSAGE">
            {{ notification.relatedUser?.name }} sent you a message
          </p>
          <p
            v-else-if="notification.type === NotificationType.NEW_OFFER_COMMENT"
          >
            {{ notification.relatedUser?.name }} commented on your offer
          </p>
          <small class="text-neutral-400 text-xs">{{
            formatTime(new Date(notification.createdAt))
          }}</small>
        </NuxtLink>
      </DropdownBaseElement>
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
