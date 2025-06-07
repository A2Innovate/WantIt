<template>
  <div>
    <form class="flex flex-col gap-2 items-end" @submit.prevent="handleSubmit">
      <div class="flex items-center justify-between w-full">
        <p class="font-semibold">Add review</p>
        <UiStars :value="rating" @update:model-value="rating = $event" />
      </div>

      <div class="flex flex-col gap-2 items-end w-full">
        <UiTextArea
          v-model="content"
          rows="1"
          class="w-full"
          placeholder="The item was..."
        />
        <UiButton
          :loading="isSending"
          class="w-full"
          icon="material-symbols:send-rounded"
          >Send</UiButton
        >
      </div>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { addEditReviewSchema } from '~/schema/services/user';
import { AxiosError } from 'axios';

const props = defineProps<{
  userId: number;
}>();

const api = useApi();
const content = ref('');
const rating = ref(0);
const isSending = ref(false);
const error = ref('');

async function handleSubmit() {
  isSending.value = true;

  const payload = {
    content: content.value || null,
    rating: rating.value
  };

  const validation = validate(addEditReviewSchema, payload);

  if (validation) {
    error.value = validation;
    isSending.value = false;
    return;
  }

  try {
    error.value = '';

    await api.post(`/user/${props.userId}/review`, payload);

    content.value = '';
    rating.value = 5;
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = e.response.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  } finally {
    isSending.value = false;
  }
}
</script>
