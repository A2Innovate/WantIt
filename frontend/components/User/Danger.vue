<template>
  <UiCard>
    <h2 class="text-2xl font-semibold mb-2">Danger zone</h2>
    <UiButton
      class="w-full"
      variant="danger"
      icon="material-symbols:delete"
      @click="deleteModalOpen = true"
    >
      Delete account
    </UiButton>
    <p v-if="message" class="mt-2 text-center">{{ message }}</p>
    <Teleport to="body">
      <ModalConfirm
        :is-open="deleteModalOpen"
        :is-loading="isLoading"
        @confirm="deleteAccount"
        @cancel="deleteModalOpen = false"
      >
        <p class="text-center">
          Are you sure you want to request the deletion of your account?
        </p>
        <p v-if="error" class="text-red-500 text-sm mt-2 text-center">
          {{ error }}
        </p>
      </ModalConfirm>
    </Teleport>
  </UiCard>
</template>

<script setup lang="ts">
import { AxiosError } from 'axios';

const api = useApi();
const isLoading = ref(false);
const message = ref('');
const error = ref('');
const deleteModalOpen = ref(false);

async function deleteAccount() {
  try {
    isLoading.value = true;
    error.value = '';
    const response = await api.delete('/user');
    message.value = response.data.message;
    deleteModalOpen.value = false;
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
