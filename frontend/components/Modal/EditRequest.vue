<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">Edit request</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="editRequest">
      <UiLabel for="location">Location</UiLabel>
      <UiMapRadiusPicker id="location" v-model="location" />
      <UiLabel for="content">What do you want?</UiLabel>
      <UiInput id="content" v-model="content" />
      <UiLabel for="budget">Budget</UiLabel>
      <div class="flex">
        <DropdownCurrency :model-value="request.currency" readonly />
        <UiInput
          id="budget"
          v-model="budget"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <UiButton type="submit" class="mt-2">Edit request</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { AxiosError } from 'axios';
import { editRequestSchema } from '~/schema/services/request';
import type { Request } from '~/types/request';

const props = defineProps<{
  isOpen: boolean;
  request: Request;
}>();

const emit = defineEmits(['close', 'update']);
const api = useApi();

const content = ref(props.request.content);
const budget = ref(props.request.budget.toString());
const location = ref({
  lng: props.request.location.x,
  lat: props.request.location.y,
  radius: props.request.radius
});
const error = ref('');

async function editRequest() {
  try {
    const validation = validate(editRequestSchema, {
      content: content.value,
      budget: Number(budget.value),
      location: {
        x: location.value.lng,
        y: location.value.lat
      },
      radius: location.value.radius
    });

    if (validation) {
      error.value = validation;
      return;
    }

    await api.put(`/request/${props.request.id}`, {
      content: content.value,
      budget: Number(budget.value),
      location: {
        x: location.value.lng,
        y: location.value.lat
      },
      radius: location.value.radius
    });

    emit('update');
    emit('close');
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = e.response.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  }
}
</script>
