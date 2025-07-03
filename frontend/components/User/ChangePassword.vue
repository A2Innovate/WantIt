<template>
  <UiCard card-class="sm:min-w-md">
    <h2 class="text-2xl font-semibold">{{ t('change_password') }}</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="changePassword">
      <UiLabel for="old_password">{{ t('old_password') }}</UiLabel>
      <UiInput
        id="old_password"
        v-model="oldPassword"
        type="password"
        autocomplete="current-password"
      />
      <UiLabel for="new_password">{{ t('new_password') }}</UiLabel>
      <UiInput
        id="new_password"
        v-model="newPassword"
        type="password"
        autocomplete="new-password"
      />
      <UiLabel for="repeat_new_password">{{
        t('repeat_new_password')
      }}</UiLabel>
      <UiInput
        id="repeat_new_password"
        v-model="repeatNewPassword"
        type="password"
        autocomplete="new-password"
      />
      <UiButton type="submit" class="mt-2">{{ t('change_password') }}</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiCard>
</template>

<script setup lang="ts">
import { AxiosError } from 'axios';
import { changePasswordSchema } from '~/schema/services/auth';

const emit = defineEmits(['close']);
const api = useApi();
const { t } = useI18n();

const oldPassword = ref('');
const newPassword = ref('');
const repeatNewPassword = ref('');
const error = ref('');

async function changePassword() {
  try {
    const validation = validate(changePasswordSchema, {
      oldPassword: oldPassword.value,
      newPassword: newPassword.value
    });

    if (validation) {
      error.value = t(validation);
      return;
    }
    if (newPassword.value !== repeatNewPassword.value) {
      error.value = t('passwords_dont_match');
      return;
    }

    await api.post('/auth/change-password', {
      oldPassword: oldPassword.value,
      newPassword: newPassword.value
    });

    emit('close');
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = t(e.response.data.message);
    } else {
      error.value = t('unknown_error');
    }
  }
}
</script>
