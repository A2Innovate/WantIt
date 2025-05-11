<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Sign in</h1>
    <form class="flex flex-col gap-2" @submit.prevent="signIn">
      <div>
        <UiLabel for="email">Email</UiLabel>
        <UiInput
          id="email"
          v-model="email"
          placeholder="john.doe@example.com..."
          autocomplete="email"
          class="w-full"
        />
      </div>
      <div>
        <UiLabel for="password">Password</UiLabel>
        <UiInput
          id="password"
          v-model="password"
          placeholder="Password..."
          autocomplete="current-password"
          type="password"
          class="w-full"
        />
      </div>
      <UiButton class="mt-2">Sign in</UiButton>
      <p v-if="error" class="text-red-500 mt-2">{{ error }}</p>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
});

const email = ref('');
const password = ref('');
const api = useApi();
const userStore = useUserStore();

const error = ref('');

if (userStore.current) {
  navigateTo('/');
}

async function signIn() {
  try {
    const response = await api.post('/auth/login', {
      email: email.value,
      password: password.value
    });

    userStore.current = response.data;
    navigateTo('/');
  } catch (e) {
    console.error(e);
  }
}
</script>
