<template>
  <div class="max-w-6xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <CardAdminStats type="requests" />
        <CardAdminStats type="offers" />
        <CardAdminStats type="users" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});
</script>
