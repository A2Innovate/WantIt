<template>
  <div class="flex flex-col items-center">
    <p v-if="success">Email verified successfully</p>
    <p v-else>Email verification failed</p>
    <NuxtLink to="/">
      <p class="font-semibold hover:underline">Go to home</p>
    </NuxtLink>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
});
const success = ref(false);
const route = useRoute();
const api = useApi();

const { data, error } = await useAsyncData(
  'verify-email',
  async () => {
    await api.post(`/auth/verify-email/${route.params.token}`);
    return true;
  },
  {
    server: true
  }
);

success.value = !!data.value && !error.value;
</script>
