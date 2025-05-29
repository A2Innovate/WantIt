<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">New request</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="addRequest">
      <UiLabel for="content">What do you want?</UiLabel>
      <UiInput id="content" v-model="content" placeholder="An iPhone..." />
      <UiLabel for="budget">Budget</UiLabel>
      <div class="flex">
        <DropdownCurrency v-model="selectedCurrency" />
        <UiInput
          id="budget"
          v-model="budget"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <UiButton type="submit" class="mt-2">Add</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { createRequestSchema } from '@/schema/services/request';
import { AxiosError } from 'axios';

defineProps<{
  isOpen: boolean;
}>();

const userStore = useUserStore();
const emit = defineEmits(['close']);
const api = useApi();

const content = ref('');
const selectedCurrency = ref(userStore.current?.preferredCurrency ?? 'USD');
const budget = ref('');
const error = ref('');

async function addRequest() {
  try {
    const validation = validate(createRequestSchema, {
      content: content.value,
      budget: Number(budget.value),
      currency: selectedCurrency.value
    });

    if (validation) {
      error.value = validation;
      return;
    }

    const response = await api.post('/request', {
      content: content.value,
      budget: Number(budget.value),
      currency: selectedCurrency.value
    });

    navigateTo(`/request/${response.data.id}`);
    emit('close');
    content.value = '';
    budget.value = '';
    error.value = '';
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = e.response.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  }
}
</script>
