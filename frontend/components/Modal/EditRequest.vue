<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">Edit request</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="editRequest">
      <div class="flex items-center gap-2 self-center">
        <UiLabel for="locationGlobal">Local</UiLabel>
        <UiToggle id="locationGlobal" v-model="locationGlobal" />
        <UiLabel for="locationGlobal">Global</UiLabel>
      </div>
      <UiMapRadiusPicker v-if="!locationGlobal" v-model="location" />
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
      <UiButton type="submit" class="mt-2" :loading="isLoading"
        >Edit request</UiButton
      >
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

const userStore = useUserStore();
const emit = defineEmits(['close', 'update']);
const api = useApi();

const content = ref(props.request.content);
const budget = ref(props.request.budget.toString());
const location = ref({
  lat: props.request.location?.y ?? 37.78,
  lng: props.request.location?.x ?? -122.419,
  radius: props.request.radius ?? 3000
});
const locationGlobal = ref(!props.request.location);
const error = ref('');
const isLoading = ref(false);

async function editRequest() {
  try {
    isLoading.value = true;
    const payload = {
      content: content.value,
      budget: Number(budget.value),
      currency: props.request.currency,
      location: locationGlobal.value
        ? null
        : {
            x: location.value.lng,
            y: location.value.lat
          },
      radius: locationGlobal.value ? null : location.value.radius
    };

    const validation = validate(editRequestSchema, payload);

    if (validation) {
      error.value = validation;
      return;
    }

    if (
      userStore.current?.isAdmin &&
      userStore.current.id !== props.request.user.id
    ) {
      await api.put(`/request/${props.request.id}`, payload, {
        params: {
          pretendUser: props.request.user.id
        }
      });
    } else {
      await api.put(`/request/${props.request.id}`, payload);
    }

    emit('update');
    emit('close');
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = e.response.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  } finally {
    isLoading.value = false;
  }
}
</script>
