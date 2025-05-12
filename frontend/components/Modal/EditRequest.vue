<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">Edit request</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="editRequest">
      <UiLabel for="content">What do you want?</UiLabel>
      <UiInput id="content" v-model="content" />
      <UiLabel for="budget">Budget</UiLabel>
      <UiInput id="budget" v-model="budget" type="number" />
      <UiButton type="submit" class="mt-2">Edit request</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { editRequestSchema } from '~/schema/services/request';
import type { Request } from '~/types/request';

const props = defineProps<{
  isOpen: boolean;
  request?: Request;
}>();
const localRequest = ref<Request | undefined>(props.request);
const emit = defineEmits(['close']);
const api = useApi();

const content = ref(props.request?.content ?? '');
const budget = ref(props.request?.budget.toString() ?? '');
const error = ref('');

async function editRequest() {
  if (!localRequest.value) {
    return;
  }
  try {
    const validation = validate(editRequestSchema, {
      content: content.value,
      budget: Number(budget.value)
    });

    if (validation) {
      error.value = validation;
      return;
    }

    const response = await api.put(`/request/${localRequest.value.id}`, {
      content: content.value,
      budget: Number(budget.value)
    });

    console.log(response.data);

    if (localRequest.value) {
      localRequest.value.content = content.value;
      localRequest.value.budget = Number(budget.value);
    }

    emit('close');
  } catch (error) {
    console.error(error);
  }
}
</script>
