<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">New request</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="addRequest">
      <div class="flex items-center gap-2 self-center">
        <div
          class="flex items-center gap-1 transition-colors"
          :class="locationGlobal ? 'text-neutral-400' : 'text-sky-400'"
        >
          <Icon name="material-symbols:location-on" />
          <span class="font-medium text-sm">Local</span>
        </div>
        <UiToggle
          id="locationGlobal"
          v-model="locationGlobal"
          :disabled="isLoading"
        />
        <div
          class="flex items-center gap-1 transition-colors"
          :class="locationGlobal ? 'text-sky-400' : 'text-neutral-400'"
        >
          <span class="font-medium text-sm">Global</span>
          <Icon name="material-symbols:globe" />
        </div>
      </div>
      <UiMapRadiusPicker v-if="!locationGlobal" v-model="location" />
      <UiLabel for="content">What do you want?</UiLabel>
      <UiInput
        id="content"
        v-model="content"
        placeholder="An iPhone..."
        :disabled="isLoading"
      />
      <UiLabel for="budget">Budget</UiLabel>
      <div class="flex">
        <DropdownCurrency v-model="selectedCurrency" :readonly="isLoading" />
        <UiInput
          id="budget"
          v-model="budget"
          :disabled="isLoading"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <UiButton type="submit" class="mt-2" :loading="isLoading">Add</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { createRequestSchema } from '@/schema/services/request';
import { AxiosError } from 'axios';

const props = defineProps<{
  isOpen: boolean;
}>();

const userStore = useUserStore();
const emit = defineEmits(['close']);
const api = useApi();

const content = ref('');
const selectedCurrency = ref(userStore.current?.preferredCurrency ?? 'USD');
const budget = ref('');
const location = ref({
  lat: 37.78,
  lng: -122.419,
  radius: 3000
});
const locationGlobal = ref(false);
const isLoading = ref(false);
const error = ref('');

async function addRequest() {
  try {
    isLoading.value = true;
    const payload = {
      content: content.value,
      budget: Number(budget.value),
      currency: selectedCurrency.value,
      location: locationGlobal.value
        ? null
        : {
            x: location.value.lng,
            y: location.value.lat
          },
      radius: locationGlobal.value ? null : location.value.radius
    };

    const validation = validate(createRequestSchema, payload);

    if (validation) {
      error.value = validation;
      return;
    }

    const response = await api.post('/request', payload);

    navigateTo(`/request/${response.data.id}`);
    emit('close');
    content.value = '';
    budget.value = '';
    error.value = '';
    location.value = {
      lat: 37.78,
      lng: -122.419,
      radius: 3000
    };
    locationGlobal.value = false;
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

watch(
  () => props.isOpen,
  async () => {
    if (props.isOpen) {
      location.value = {
        ...(await getLocation()),
        radius: 3000
      };
    }
  }
);
</script>
