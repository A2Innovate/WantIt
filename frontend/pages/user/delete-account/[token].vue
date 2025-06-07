<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Account deletion</h1>
    <form
      class="flex flex-col gap-2 text-center"
      @submit.prevent="deleteAccount"
    >
      <p>This is the final step to delete your account.</p>
      <p>
        This action also deletes all your requests, offers, messages and
        personal data.
      </p>
      <b class="font-semibold text-red-400 text-sm"
        >Once deleted, you will not be able to recover it.</b
      >
      <UiButton
        class="mt-2"
        variant="danger"
        icon="material-symbols:delete"
        :loading="isLoading"
        >Delete account</UiButton
      >
      <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
      <p v-if="success" class="mt-2 text-center">
        Your account has been deleted.
      </p>
    </form>
  </div>
</template>
<script setup lang="ts">
import { AxiosError } from 'axios';

definePageMeta({
  layout: 'auth'
});

const error = ref('');
const success = ref(false);
const isLoading = ref(false);
const route = useRoute();
const api = useApi();

async function deleteAccount() {
  error.value = '';
  success.value = false;
  isLoading.value = true;
  try {
    await api.post('/user/delete-account', {
      token: route.params.token
    });

    success.value = true;
  } catch (e) {
    if (e instanceof AxiosError) {
      error.value = e.response?.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  } finally {
    isLoading.value = false;
  }
}
</script>
