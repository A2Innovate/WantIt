<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Reset password</h1>
    <form class="flex flex-col gap-2" @submit.prevent="resetPassword">
      <div>
        <UiLabel for="password">New Password</UiLabel>
        <UiInput
          id="password"
          v-model="password"
          placeholder="Password..."
          autocomplete="new-password"
          type="password"
          class="w-full"
        />
      </div>
      <UiButton class="mt-2">Reset password</UiButton>
      <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
      <p v-if="success" class="text-green-500 mt-2 text-center">
        Password reset successfully
      </p>
    </form>
  </div>
</template>
<script setup lang="ts">
import { AxiosError } from 'axios';
import { resetPasswordSchema } from '~/schema/services/auth';

definePageMeta({
  layout: 'auth'
});

const password = ref('');
const api = useApi();
const userStore = useUserStore();

const error = ref('');
const success = ref(false);
const route = useRoute();

if (userStore.current) {
  navigateTo('/');
}

async function resetPassword() {
  error.value = '';
  success.value = false;
  try {
    const validation = validate(resetPasswordSchema, {
      password: password.value,
      token: route.params.token
    });

    if (validation) {
      error.value = validation;
      return;
    }
    await api.post('/auth/reset-password', {
      password: password.value,
      token: route.params.token
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
