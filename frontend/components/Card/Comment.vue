<template>
  <div class="p-3 rounded-lg bg-neutral-900">
    <div class="flex items-center justify-between mb-1">
      <span class="text-xs text-neutral-400">@{{ comment.user.username }}</span>
      <ClientOnly
        ><span class="text-xs text-neutral-500">{{
          formatTime(new Date(comment.createdAt))
        }}</span></ClientOnly
      >
    </div>
    <p v-if="!isEditing" class="text-sm text-neutral-300">
      {{ comment.content }}
    </p>
    <UiTextArea
      v-else
      v-model="editedCommentContent"
      class="bg-neutral-950 w-full"
    />
    <span v-if="comment.edited" class="text-xs text-neutral-500">Edited</span>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
    <div
      v-if="userStore.current?.id === comment.user.id"
      class="flex gap-2 justify-end"
    >
      <UiButton
        class="border border-neutral-700"
        :disabled="isSavingEdit"
        @click="handleEdit"
      >
        <div v-if="!isEditing" class="flex items-center gap-2">
          <Icon name="material-symbols:edit-rounded" />
          <span class="hidden sm:block">Edit</span>
        </div>
        <div v-else class="flex items-center gap-2">
          <Icon name="material-symbols:done" />
          <span class="hidden sm:block">Save</span>
        </div>
      </UiButton>
      <UiButton
        class="border border-neutral-700"
        @click="isDeleteModalOpen = true"
      >
        <Icon name="material-symbols:delete-rounded" />
        <span class="hidden sm:block">Delete</span>
      </UiButton>
    </div>
    <Teleport to="body">
      <ModalConfirm
        :is-open="isDeleteModalOpen"
        :is-loading="isDeleting"
        @cancel="isDeleteModalOpen = false"
        @confirm="deleteComment()"
      >
        Are you sure you want to delete this comment?
      </ModalConfirm>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import type { Comment } from '@/types/comment';
import { AxiosError } from 'axios';

const props = defineProps<{
  comment: Comment;
}>();

const isDeleteModalOpen = ref(false);
const isDeleting = ref(false);
const isEditing = ref(false);
const isSavingEdit = ref(false);
const error = ref('');
const api = useApi();
const userStore = useUserStore();
const editedCommentContent = ref(props.comment.content);

async function handleEdit() {
  if (!isEditing.value) {
    isEditing.value = true;
  } else {
    if (editedCommentContent.value !== props.comment.content) {
      try {
        error.value = '';
        isSavingEdit.value = true;

        await api.put(`/comment/${props.comment.id}`, {
          content: editedCommentContent.value
        });

        isEditing.value = false;
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
      isEditing.value = false;
    }
  }
}

async function deleteComment() {
  try {
    isDeleting.value = true;
    await api.delete(`/comment/${props.comment.id}`);
  } finally {
    isDeleting.value = false;
  }
}
</script>
