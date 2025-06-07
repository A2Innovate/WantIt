<template>
  <UiModal card-class="sm:min-w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">Edit alert</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="updateAlert">
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
      <UiLabel for="content">Phrase to match</UiLabel>
      <UiInput id="content" v-model="content" placeholder="Galaxy S23..." />
      <UiLabel for="budget">Budget to match</UiLabel>
      <div class="flex">
        <DropdownCurrency v-model="selectedCurrency" />
        <UiInput
          id="budget"
          v-model="budget"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <UiDropdown
        v-if="budget"
        class="h-10"
        :model-value="`${COMPARISON_MODES.find((mode) => mode.value === budgetComparisonMode)!.label} ${selectedCurrency} ${budget}`"
        :options="
          COMPARISON_MODES.map((mode) => ({
            value: mode.value,
            label: `${mode.label} ${selectedCurrency} ${budget}`
          }))
        "
        @update:model-value="budgetComparisonMode = $event"
      />
      <UiButton type="submit" class="mt-2" :loading="isLoading">Save</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { AxiosError } from 'axios';
import { createEditAlertSchema } from '@/schema/services/user';
import type { Alert } from '@/types/alert';

const props = defineProps<{
  isOpen: boolean;
  alert: Alert;
}>();

const emit = defineEmits(['close']);
const api = useApi();

const content = ref(props.alert.content);
const selectedCurrency = ref(props.alert.currency);
const budget = ref(props.alert.budget.toString());
const location = ref({
  lat: props.alert.location?.y,
  lng: props.alert.location?.x,
  radius: props.alert.radius
});
const locationGlobal = ref(!props.alert.location);
const error = ref('');
const isLoading = ref(false);
const budgetComparisonMode = ref(props.alert.budgetComparisonMode);

async function updateAlert() {
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
      radius: locationGlobal.value ? null : location.value.radius,
      budgetComparisonMode: budgetComparisonMode.value
    };

    const validation = validate(createEditAlertSchema, payload);

    if (validation) {
      error.value = validation;
      return;
    }

    await api.put(`/user/alert/${props.alert.id}`, payload);

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
