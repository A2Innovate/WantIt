<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">{{ t('settings') }}</h1>
      <UiCard>
        <form class="flex flex-col gap-2" @submit.prevent="updateProfile">
          <div>
            <UiLabel for="name">{{ t('name') }}</UiLabel>
            <UiInput id="name" v-model="name" class="w-full" />
          </div>
          <div>
            <UiLabel for="username">{{ t('username') }}</UiLabel>
            <div class="flex">
              <UiInputIcon> @ </UiInputIcon>
              <UiInput
                id="username"
                v-model="username"
                class="w-full rounded-l-none"
              />
            </div>
          </div>
          <div>
            <UiLabel for="email">{{ t('email') }}</UiLabel>
            <UiInput id="email" v-model="email" class="w-full" />
          </div>
          <div>
            <UiLabel for="preferredCurrency">{{ t('preferred_currency') }}</UiLabel>
            <DropdownCurrency
              id="preferredCurrency"
              v-model="preferredCurrency"
              class="h-8"
              trigger-class="w-32 rounded-lg"
            />
          </div>
          <div>
          <UiLabel for="language">{{ t('language') }}</UiLabel>
          <select
  v-model="language"
  class="w-32 h-8 rounded-lg border border-neutral-600 bg-neutral-900 text-neutral-300 text-sm px-2 pr-6 appearance-none cursor-pointer transition-colors hover:bg-neutral-800 focus:outline-none focus:ring-1 focus:ring-neutral-500"
>
  <option
    v-for="localeOption in locales"
    :key="localeOption.code"
    :value="localeOption.code"
    class="bg-neutral-900 text-neutral-300"
  >
    {{ localeOption.name }}
  </option>
</select>

        </div>

          <UiButton type="submit">{{ t('save') }}</UiButton>
          <p v-if="submitted && !error" class="text-green-500 text-center mt-2">
            {{ t('profile_updated_successfully') }}
          </p>
          <p v-if="error" class="text-red-500 text-center mt-2">{{ t(error) }}</p>
        </form>
      </UiCard>
      <UserChangePassword />
      <UserSecurity />
      <UserDanger />
    </div>
  </div>
</template>

<script setup lang="ts">
import { updateProfileSchema } from '@/schema/services/user';
import { AxiosError } from 'axios';
const { locale, locales, t, setLocale } = useI18n();

definePageMeta({
  middleware: 'auth'
});

const userStore = useUserStore();
const api = useApi();

const name = ref(userStore.current?.name ?? '');
const username = ref(userStore.current?.username ?? '');
const email = ref(userStore.current?.email ?? '');
const preferredCurrency = ref(userStore.current?.preferredCurrency ?? 'USD');
const error = ref('');
const submitted = ref(false);

const language = ref(locale.value);

watch(language, (newLang) => {
  setLocale(newLang);
});

async function updateProfile() {
  submitted.value = false;
  error.value = '';

  try {
    const validation = validate(updateProfileSchema, {
      name: name.value,
      username: username.value,
      email: email.value,
      preferredCurrency: preferredCurrency.value
    });

    if (validation) {
      error.value = validation;
      return;
    }

    await api.put('/user/update', {
      name: name.value,
      username: username.value,
      email: email.value,
      preferredCurrency: preferredCurrency.value
    });

    userStore.current!.name = name.value;
    userStore.current!.preferredCurrency = preferredCurrency.value;
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
