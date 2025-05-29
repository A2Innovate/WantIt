<template>
  <div class="max-w-2xl mx-auto">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Settings</h1>
      <UiCard>
        <form class="flex flex-col gap-2" @submit.prevent="updateProfile">
          <div>
            <UiLabel for="name">Name</UiLabel>
            <UiInput id="name" v-model="name" class="w-full" />
          </div>
          <div>
            <UiLabel for="email">Email</UiLabel>
            <UiInput id="email" v-model="email" class="w-full" />
          </div>
          <div>
            <UiLabel for="prefferedCurrency">Preffered currency</UiLabel>
            <DropdownCurrency
              id="prefferedCurrency"
              v-model="prefferedCurrency"
              class="h-8"
              trigger-class="w-32 rounded-lg"
            />
          </div>
          <UiButton type="submit">Save</UiButton>
          <p v-if="submitted && !error" class="text-green-500 text-center mt-2">
            Profile updated successfully
          </p>
          <p v-if="error" class="text-red-500 text-center mt-2">{{ error }}</p>
        </form>
      </UiCard>
      <UserChangePassword />
    </div>
  </div>
</template>

<script setup lang="ts">
import { updateProfileSchema } from '@/schema/services/user';
import { AxiosError } from 'axios';

definePageMeta({
  middleware: 'auth'
});

const userStore = useUserStore();
const api = useApi();

const name = ref(userStore.current?.name ?? '');
const email = ref(userStore.current?.email ?? '');
const prefferedCurrency = ref(userStore.current?.prefferedCurrency ?? 'USD');

const error = ref('');
const submitted = ref(false);

async function updateProfile() {
  submitted.value = false;
  error.value = '';

  try {
    const validation = validate(updateProfileSchema, {
      name: name.value,
      email: email.value,
      prefferedCurrency: prefferedCurrency.value
    });

    if (validation) {
      error.value = validation;
      return;
    }

    await api.put('/user/update', {
      name: name.value,
      email: email.value,
      prefferedCurrency: prefferedCurrency.value
    });

    userStore.current!.name = name.value;
    userStore.current!.prefferedCurrency = prefferedCurrency.value;
    submitted.value = true;
    if (userStore.current!.email !== email.value) {
      navigateTo('/');
      userStore.current = null;
    }
  } catch (e) {
    if (e instanceof AxiosError) {
      error.value = e.response?.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  }
}
</script>
