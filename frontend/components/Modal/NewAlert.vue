<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">New alert</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="addAlert">
      <div class="flex items-center gap-2 self-center">
        <UiLabel for="locationGlobal">Local</UiLabel>
        <UiToggle id="locationGlobal" v-model="locationGlobal" />
        <UiLabel for="locationGlobal">Global</UiLabel>
      </div>
      <UiMapRadiusPicker v-if="!locationGlobal" v-model="location" />
      <UiLabel for="content">Content</UiLabel>
      <UiInput id="content" v-model="content" placeholder="Galaxy S23..." />
      <UiLabel for="budget">Price</UiLabel>
      <div class="flex">
        <DropdownCurrency v-model="selectedCurrency" />
        <UiInput
          id="budget"
          v-model="budget"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <UiDropdown v-model="budgetComparisonMode" :options="comparisonModes" />
      <UiButton type="submit" class="mt-2">Add</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { AxiosError } from 'axios';
import { createAlertSchema } from '@/schema/services/user';

defineProps<{
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
const error = ref('');
const budgetComparisonMode = ref('EQUALS');
const comparisonModes = computed(() => [
  {
    value: 'EQUALS',
    label: `Equals ${budget.value} ${selectedCurrency.value}`
  },
  {
    value: 'LESS_THAN',
    label: `Less than ${budget.value} ${selectedCurrency.value}`
  },
  {
    value: 'LESS_THAN_OR_EQUAL_TO',
    label: `Less than or equal to ${budget.value} ${selectedCurrency.value}`
  },
  {
    value: 'GREATER_THAN',
    label: `Greater than ${budget.value} ${selectedCurrency.value}`
  },
  {
    value: 'GREATER_THAN_OR_EQUAL_TO',
    label: `Greater than ${budget.value} ${selectedCurrency.value} or equal to ${budget.value} ${selectedCurrency.value}`
  }
]);

async function addAlert() {
  try {
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

    const validation = validate(createAlertSchema, payload);

    if (validation) {
      error.value = validation;
      return;
    }

    await api.post('/user/alert', payload);

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
  }
}
</script>
