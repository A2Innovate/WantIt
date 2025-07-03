<template>
  <div>
    <form class="flex gap-2 items-end" @submit.prevent="handleSubmit">
      <UiTextArea
        v-model="content"
        rows="1"
        class="w-full"
        :placeholder="t('add_comment')"
      />
      <UiButton :loading="isSending" class="h-10">{{ t('send') }}</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { addCommentSchema } from '~/schema/services/comment';
import { AxiosError } from 'axios';
const { t } = useI18n();

const props = defineProps<{
  offerId: number;
}>();

const api = useApi();
const content = ref('');
const isSending = ref(false);
const error = ref('');

async function handleSubmit() {
  isSending.value = true;

  const validation = validate(addCommentSchema, {
    content: content.value,
    offerId: props.offerId
  });

  if (validation) {
    error.value = validation;
    isSending.value = false;
    return;
  }

  try {
    error.value = '';

    await api.post(`/comment`, {
      offerId: props.offerId,
      content: content.value
    });

    content.value = '';
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = t(e.response.data.message);
    } else {
      error.value = t('unknown_error');
    }
  } finally {
    isSending.value = false;
  }
}
</script>
