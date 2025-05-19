<template>
  <div>
    <div class="max-w-3xl mx-auto">
      <h1 class="text-xl font-semibold my-4 px-4">Request</h1>
      <UiCard v-if="!error" class="m-4">
        <p v-if="request">{{ request.content }}</p>
        <p v-else>Loading...</p>
        <p v-if="request">{{ priceFmt(request.budget) }}</p>

        <div class="flex justify-between items-center mt-4">
          <div v-if="userStore.current?.id === request?.user.id" class="flex">
            <UiButton @click="isEditRequestModalOpen = true"
              >Edit request</UiButton
            >
          </div>

          <div
            class="flex w-fit gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full"
          >
            <Icon name="material-symbols:account-circle" />
            <p v-if="request" class="text-sm">{{ request.user.name }}</p>
            <p v-else>Loading...</p>
          </div>
        </div>
      </UiCard>
      <UiCard v-else-if="error" class="m-4">
        <p class="text-red-500 text-center">
          <span v-if="error.statusCode === 404"
            >Request {{ route.params.requestId }} not found
          </span>
          <span v-else> {{ error.message }}</span>
        </p>
      </UiCard>

      <h2
        v-if="request?.offers.length"
        class="text-xl font-semibold mt-6 mb-4 px-4"
      >
        Offers
      </h2>

      <div v-if="request?.offers.length" class="flex flex-col gap-2 m-4">
        <CardOffer
          v-for="offer in request.offers"
          :key="offer.id"
          :offer="offer"
        />
      </div>

      <div v-if="request && userStore.current" class="flex justify-end m-4">
        <UiButton @click="isAddOfferModalOpen = true">Add offer</UiButton>
      </div>
    </div>

    <ModalEditRequest
      v-if="request"
      :is-open="isEditRequestModalOpen"
      :request="request"
      @close="isEditRequestModalOpen = false"
      @update="refresh()"
    />
    <ModalNewOffer
      v-if="request"
      :is-open="isAddOfferModalOpen"
      :request="request"
      @close="isAddOfferModalOpen = false"
    />
  </div>
</template>

<script setup lang="ts">
import type { Request } from '~/types/request';

const route = useRoute();
const api = useApi();
const userStore = useUserStore();

const isEditRequestModalOpen = ref(false);
const isAddOfferModalOpen = ref(false);

const {
  data: request,
  error,
  refresh
} = useAsyncData<Request>('request', async () => {
  const response = await api.get(`/request/${route.params.requestId}`);
  return response.data;
});
</script>
