<template>
  <div class="p-3 rounded-lg bg-neutral-900">
    <div class="flex items-start justify-between mb-1">
      <NuxtLink :to="'/user/' + review.reviewer.id">
        <span
          class="text-xs text-neutral-400 hover:text-neutral-300 transition-colors duration-100"
          >@{{ review.reviewer.username }}</span
        >
      </NuxtLink>
      <div class="flex flex-col justify-end">
        <UiStars :value="review.rating" readonly />
        <ClientOnly
          ><span
            class="text-xs text-neutral-500 text-right"
            :title="new Date(review.createdAt).toLocaleString()"
            >{{ formatTime(new Date(review.createdAt)) }}</span
          ></ClientOnly
        >
      </div>
    </div>

    <p v-if="!isEditing" class="text-sm text-neutral-300">
      {{ review.content }}
    </p>
    <UiTextArea
      v-else
      v-model="editedReviewContent"
      class="bg-neutral-950 w-full"
    />
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
    <div
      v-if="
        userStore.current?.id === review.reviewer.id ||
        userStore.current?.isAdmin
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
        @confirm="deleteReview()"
      >
        Are you sure you want to delete this review?
      </ModalConfirm>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import type { Review } from '@/types/review';
import { AxiosError } from 'axios';

const props = defineProps<{
  review: Review;
}>();

const isDeleteModalOpen = ref(false);
const isDeleting = ref(false);
const isEditing = ref(false);
const isSavingEdit = ref(false);
const error = ref('');
const api = useApi();
const userStore = useUserStore();
const editedReviewContent = ref(props.review.content);

async function handleEdit() {
  if (!isEditing.value) {
    isEditing.value = true;
  } else {
    if (editedReviewContent.value !== props.review.content) {
      try {
        error.value = '';
        isSavingEdit.value = true;

        if (
          userStore.current?.isAdmin &&
          userStore.current.id !== props.review.reviewer.id
        ) {
          await api.put(
            `/user/review/${props.review.id}`,
            {
              content: editedReviewContent.value
            },
            {
              params: {
                pretendUser: props.review.reviewer.id
              }
            }
          );
        } else {
          await api.put(`/user/review/${props.review.id}`, {
            content: editedReviewContent.value
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

async function deleteReview() {
  try {
    isDeleting.value = true;
    if (
      userStore.current?.isAdmin &&
      userStore.current.id !== props.review.reviewer.id
    ) {
      await api.delete(`/user/review/${props.review.id}`, {
        params: {
          pretendUser: props.review.reviewer.id
        }
      });
    } else {
      await api.delete(`/user/review/${props.review.id}`);
    }
  } finally {
    isDeleting.value = false;
  }
}
</script>
