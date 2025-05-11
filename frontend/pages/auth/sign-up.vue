<template>
  <div>
    <h1 class="text-xl font-semibold mb-4">Sign up</h1>
    <form class="flex flex-col gap-2" @submit.prevent="signUp">
      <div>
        <UiLabel for="name">Name</UiLabel>
        <UiInput
          id="name"
          v-model="name"
          placeholder="John Doe..."
          autocomplete="name"
          class="w-full"
        />
      </div>
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
          autocomplete="new-password"
          type="password"
          class="w-full"
        />
      </div>
      <UiButton class="mt-2">Sign up</UiButton>
      <p v-if="error" class="text-red-500 mt-2">{{ error }}</p>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
});
const name = ref('');
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
    await api.post('/auth/register', {
      name: name.value,
      email: email.value,
      password: password.value
    });

    navigateTo('/auth/sign-in');
  } catch (e) {
    console.error(e);
  }
}
</script>
