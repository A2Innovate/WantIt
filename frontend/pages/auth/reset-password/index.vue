<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Reset password</h1>
    <form class="flex flex-col gap-2" @submit.prevent="resetPassword">
      <div>
        <UiLabel for="email">Email</UiLabel>
        <UiInput
          id="email"
          v-model="email"
          placeholder="john.doe@example.com..."
          autocomplete="email"
          type="email"
          class="w-full"
        />
      </div>
      <UiButton class="mt-2">Reset password</UiButton>
      <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
      <p v-if="success" class="text-green-500 mt-2 text-center">
        Check your email for the reset password link
      </p>
    </form>
  </div>
</template>
<script setup lang="ts">
import { AxiosError } from 'axios';
import { requestPasswordResetSchema } from '~/schema/services/auth';

definePageMeta({
  layout: 'auth'
});

const email = ref('');
const api = useApi();
const userStore = useUserStore();

const error = ref('');
const success = ref(false);

if (userStore.current) {
  navigateTo('/');
}

async function resetPassword() {
  error.value = '';
  success.value = false;
  try {
    const validation = validate(requestPasswordResetSchema, {
      email: email.value
    });

    if (validation) {
      error.value = validation;
      return;
    }
    await api.post('/auth/request-password-reset', {
      email: email.value
    });
    success.value = true;
  } catch (e) {
    if (e instanceof AxiosError) {
      error.value = e.response?.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  }
}
</script>
