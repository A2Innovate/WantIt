<template>
  <div
    :class="[
      'p-4 rounded-lg border border-neutral-700 bg-neutral-900 flex flex-col break-all w-full max-w-56 sm:max-w-xs',
      message.senderId === useUserStore().current?.id
        ? 'self-end'
        : 'self-start'
    ]"
  >
    <p v-if="!editMode">{{ message.content }}</p>
    <UiTextArea v-else v-model="editedContent" class="mb-2 bg-neutral-950" />
    <span v-if="message.edited && !editMode" class="text-xs text-neutral-500"
      >(edited)
    </span>

    <div class="flex justify-between">
      <button
        v-if="message.senderId === useUserStore().current?.id"
        class="p-1 border border-neutral-700 rounded-lg flex"
        @click="handleEdit"
      >
        <Icon v-if="!editMode" name="material-symbols:edit-rounded" />
        <Icon v-else name="material-symbols:done" />
      </button>
      <ClientOnly>
        <span class="text-sm text-neutral-400 ml-auto">
          {{ formatTime(new Date(message.createdAt)) }}
        </span>
      </ClientOnly>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Message } from '@/types/message';
import { AxiosError } from 'axios';

const props = defineProps<{
  message: Message;
}>();
const editMode = ref(false);
const editedContent = ref(props.message.content);
const error = ref('');
const api = useApi();
const isSavingEdit = ref(false);

async function handleEdit() {
  if (!editMode.value) {
    editMode.value = true;
  } else {
    if (editedContent.value !== props.message.content) {
      try {
        error.value = '';
        isSavingEdit.value = true;

        await api.put(`/chat/message/${props.message.id}`, {
          content: editedContent.value
        });

        editMode.value = false;
      } catch (e) {
        if (e instanceof AxiosError && e.response?.data.message) {
          error.value = e.response.data.message;
        } else {
          error.value = 'Something went wrong';
        }
      } finally {
        isSavingEdit.value = false;
      }
    } else {
      editMode.value = false;
    }
  }
}
</script>
