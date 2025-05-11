<template>
  <div>
    <h1 class="text-xl font-semibold mb-4 px-4 mx">Settings</h1>
    <UiCard class="p-4">
      <form class="flex flex-col gap-2" @submit.prevent="updateProfile">
        <div>
          <UiLabel for="name">Name</UiLabel>
          <UiInput id="name" v-model="name" class="w-full" />
        </div>
        <div>
          <UiLabel for="email">Email</UiLabel>
          <UiInput id="email" v-model="email" class="w-full" />
        </div>
        <UiButton type="submit">Save</UiButton>
        <p v-if="submitted && !error" class="text-green-500 mt-2">
          Profile updated successfully
        </p>
        <p v-if="error" class="text-red-500 mt-2">{{ error }}</p>
      </form>
    </UiCard>
  </div>
</template>

<script setup lang="ts">
const userStore = useUserStore();
const api = useApi();

const name = ref(userStore.current?.name ?? '');
const email = ref(userStore.current?.email ?? '');
const error = ref('');
const submitted = ref(false);

async function updateProfile() {
  submitted.value = false;
  error.value = '';

  try {
    await api.put('/user/update', {
      name: name.value,
      email: email.value
    });

    userStore.current!.name = name.value;
    submitted.value = true;
    if (userStore.current!.email !== email.value) {
      navigateTo('/');
      userStore.current = null;
    }
  } catch {
    // TODO: Handle error
  }
}
</script>
