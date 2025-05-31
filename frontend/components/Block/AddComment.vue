<template>
  <div>
    <form class="flex gap-2" @submit.prevent="handleSubmit">
      <UiTextArea v-model="content" rows="2" class="w-full" />
      <UiButton :disabled="isSending">Send</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { addCommentSchema } from '~/schema/services/request';
import { AxiosError } from 'axios';

const props = defineProps<{
  requestId: number;
  offerId: number;
}>();

const api = useApi();
const content = ref('');
const isSending = ref(false);
const error = ref('');

async function handleSubmit() {
  const validation = validate(addCommentSchema, {
    content: content.value
  });

  if (validation) {
    error.value = validation;
    return;
  }

  try {
    isSending.value = true;

    await api.post(
      `/request/${props.requestId}/offer/${props.offerId}/comment`,
      {
        content: content.value
      }
    );

    content.value = '';
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
