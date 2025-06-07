<template>
  <UiModal
    :is-open="isOpen"
    card-class="sm:max-w-md w-full m-4"
    @close="emit('close')"
  >
    <UiCard
      v-if="userStore.current && userStore.current?.id !== Number(props.userId)"
      class="w-full mb-4"
    >
      <BlockAddReview class="w-full" :user-id="Number(props.userId)" />
    </UiCard>
    <div
      class="flex flex-col items-center gap-4 max-h-64 overflow-y-auto [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:rounded-full [&::-webkit-scrollbar-track]:bg-neutral-700 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-neutral-500"
    >
      <CardReview
        v-for="review in data"
        :key="review.id"
        class="w-full"
        :review="review"
      />
      <UiSkeletonLoader v-if="!data && !error" class="h-64 w-full" />
      <p v-else-if="error" class="text-red-500 text-center">
        {{ error?.message }}
      </p>
      <p v-else-if="data?.length === 0" class="text-center text-neutral-400">
        No reviews found
      </p>
    </div>
  </UiModal>
</template>

<script setup lang="ts">
import type { Channel } from 'pusher-js';
import type { Review } from '~/types/review';

const api = useApi();
const userStore = useUserStore();
const pusher = usePusher();
let channel: Channel;

const props = defineProps<{
  isOpen: boolean;
  userId: string;
}>();

const emit = defineEmits(['close']);

const { data, error } = useAsyncData<Review[]>(
  `reviews-${props.userId}`,
  async () => {
    const response = await api.get(`/user/${props.userId}/reviews`);
    return response.data;
  }
);

onMounted(() => {
  channel = pusher.subscribe(`public-user-${props.userId}-reviews`);
  channel.bind('delete-review', ({ reviewId }: { reviewId: string }) => {
    if (data.value) {
      data.value = data.value.filter(
        (review) => review.id !== Number(reviewId)
      );
    }
  });

  channel.bind('add-review', (review: Review) => {
    if (data.value) {
      data.value.push(review);
    }
  });

  channel.bind('update-review', (review: Review) => {
    if (data.value) {
      const index = data.value.findIndex((r) => r.id === review.id);
      if (index !== -1) {
        data.value[index] = {
          ...data.value[index],
          ...review,
          edited: true
        };
      }
    }
  });
});

onUnmounted(() => {
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
