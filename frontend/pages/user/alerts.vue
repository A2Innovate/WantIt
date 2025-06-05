<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <div class="flex items-center justify-between">
        <h1 class="text-xl font-semibold">Alerts</h1>
        <UiButton class="h-7" @click="isOpen = true">
          <Icon name="material-symbols:add" />
        </UiButton>
      </div>
      <UiCard>
        {{ data }}
      </UiCard>
    </div>
    <Teleport to="body">
      <ModalNewAlert :is-open="isOpen" @close="isOpen = false" />
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: 'auth'
});

const isOpen = ref(false);
const requestFetch = useRequestFetch();

const { data } = useAsyncData('alerts', async () => {
  const response = await requestFetch(
    useRuntimeConfig().public.apiBase + '/api/user/alerts',
    {
      credentials: 'include'
    }
  );
  return response;
});
</script>
