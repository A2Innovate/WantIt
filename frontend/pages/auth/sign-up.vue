<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">{{ t('sign_up') }}</h1>
    <form class="flex flex-col gap-2" @submit.prevent="signUp">
      <div>
        <UiLabel for="name">{{ t('name') }}</UiLabel>
        <UiInput
          id="name"
          v-model="name"
          placeholder="John Doe..."
          autocomplete="name"
          class="w-full"
        />
      </div>
      <div>
        <UiLabel for="username">{{ t('username') }}</UiLabel>
        <div class="flex">
          <UiInputIcon> @ </UiInputIcon>
          <UiInput
            id="username"
            v-model="username"
            placeholder="johndoe..."
            autocomplete="username"
            class="w-full rounded-l-none"
          />
        </div>
      </div>
      <div>
        <UiLabel for="email">{{ t('email') }}</UiLabel>
        <UiInput
          id="email"
          v-model="email"
          placeholder="john.doe@example.com..."
          autocomplete="email"
          class="w-full"
        />
      </div>
      <div>
        <UiLabel for="password">{{ t('password') }}</UiLabel>
        <UiInput
          id="password"
          v-model="password"
          :placeholder="t('password') + '...'"
          autocomplete="new-password"
          type="password"
          class="w-full"
        />
      </div>
      <UiButton class="mt-2">{{ t('sign_up') }}</UiButton>
      <p v-if="error" class="text-red-500 text-sm mt-2 text-center">
        {{ error }}
      </p>
      <UiButton
        class="mt-2 flex gap-2 items-center justify-center"
        type="button"
        @click="signUpWithGoogle"
        ><Icon name="devicon:google" /> {{ t('sign_up_with_google') }}</UiButton
      >
      <div class="flex flex-col">
        <NuxtLink to="/" class="text-center">{{ t('back_to_home') }}</NuxtLink>
        <NuxtLink to="/auth/sign-in" class="text-center"
          >{{ t('have_an_account') }}</NuxtLink
        >
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { signUpSchema } from '@/schema/services/auth';
import { AxiosError } from 'axios';
const { t } = useI18n();

definePageMeta({
  layout: 'auth'
});

const name = ref('');
const username = ref('');
const email = ref('');
const password = ref('');
const api = useApi();
const userStore = useUserStore();
const error = ref('');

if (userStore.current) {
  navigateTo('/');
}

async function signUp() {
  try {
    error.value = '';
    const payload = {
      name: name.value,
      username: username.value,
      email: email.value,
      password: password.value
    };

    const validation = validate(signUpSchema, payload);

    if (validation) {
      error.value = validation;
      return;
    }

    await api.post('/auth/register', payload);

    navigateTo('/auth/sign-in');
  } catch (e) {
    if (e instanceof AxiosError) {
      error.value = e.response?.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  }
}

async function signUpWithGoogle() {
  navigateTo((await api.get('/auth/oauth/google')).data.url, {
    external: true
  });
}
</script>
