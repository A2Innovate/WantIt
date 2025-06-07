<template>
  <div class="p-3 rounded-lg bg-neutral-900">
    <div class="flex items-center justify-between mb-1">
      <NuxtLink :to="'/user/' + comment.user.id">
        <span
          class="text-xs text-neutral-400 hover:text-neutral-300 transition-colors duration-100"
          >@{{ comment.user.username }}</span
        >
      </NuxtLink>
      <ClientOnly
        ><span
          class="text-xs text-neutral-500"
          :title="new Date(comment.createdAt).toLocaleString()"
          >{{ formatTime(new Date(comment.createdAt)) }}</span
        ></ClientOnly
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
      v-if="
        userStore.current?.id === comment.user.id || userStore.current?.isAdmin
      "
      class="flex gap-2 justify-end"
    >
      <UiButton
        variant="outline"
        :loading="isSavingEdit"
        :icon="
          isEditing ? 'material-symbols:done' : 'material-symbols:edit-rounded'
        "
        @click="handleEdit"
      >
        <span v-if="!isEditing" class="hidden sm:block">Edit</span>
        <span v-else class="hidden sm:block">Save</span>
      </UiButton>
      <UiButton
        icon="material-symbols:delete-rounded"
        variant="outline"
        @click="isDeleteModalOpen = true"
      >
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

        if (
          userStore.current?.isAdmin &&
          userStore.current.id !== props.comment.user.id
        ) {
          await api.put(
            `/comment/${props.comment.id}`,
            {
              content: editedCommentContent.value
            },
            {
              params: {
                pretendUser: props.comment.user.id
              }
            }
          );
        } else {
          await api.put(`/comment/${props.comment.id}`, {
            content: editedCommentContent.value
          });
        }

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
    if (
      userStore.current?.isAdmin &&
      userStore.current.id !== props.comment.user.id
    ) {
      await api.delete(`/comment/${props.comment.id}`, {
        params: {
          pretendUser: props.comment.user.id
        }
      });
    } else {
      await api.delete(`/comment/${props.comment.id}`);
    }
  } finally {
    isDeleting.value = false;
  }
}
</script>
