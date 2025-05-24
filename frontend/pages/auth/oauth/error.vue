<template>
  <div>
    <h1>Error</h1>
    <p v-if="error">An error occurred: {{ error }}</p>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
});

const route = useRoute();
const error = route.query.message;
</script>
