<template>
  <div>
    <div class="max-w-3xl mx-auto">
      <h1 class="text-xl font-semibold my-4 px-4">Request</h1>
      <UiCard v-if="!error" class="m-4">
        <p v-if="request">{{ request.content }}</p>
        <p v-else>Loading...</p>
        <p v-if="request">
          {{ priceFmt(request.budget, request.currency) }}
          <ConvertedPrice
            class="text-xs"
            :currency="request.currency"
            :amount="request.budget"
          />
        </p>

        <div class="flex justify-between items-center mt-4">
          <div
            v-if="userStore.current?.id === request?.user.id"
            class="flex gap-2"
          >
            <UiButton @click="isEditRequestModalOpen = true">
              <Icon name="material-symbols:edit-rounded" />
              <span class="hidden sm:block">Edit</span>
            </UiButton>
            <UiButton @click="isDeleteRequestModalOpen = true">
              <Icon name="material-symbols:delete-rounded" />
              <span class="hidden sm:block">Delete</span>
            </UiButton>
          </div>

          <div
            class="flex w-fit gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full"
          >
            <Icon name="material-symbols:account-circle" class="shrink-0" />
            <p v-if="request" class="text-sm break-all">
              {{ request.user.username }}
            </p>
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
          :currency="request.currency"
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
      @update="refresh()"
    />
    <ModalConfirm
      v-if="request"
      :is-open="isDeleteRequestModalOpen"
      :is-loading="isDeletingRequest"
      @cancel="isDeleteRequestModalOpen = false"
      @confirm="deleteRequest()"
    >
      <p class="text-center">
        Are you sure you want to delete this request?
        <br />
        <span class="text-red-500 text-xs"
          >This action will also delete all offers associated with this
          request.</span
        >
      </p>
    </ModalConfirm>
  </div>
</template>

<script setup lang="ts">
import type { Request } from '~/types/request';
import type { Channel } from 'pusher-js';
import type { Offer } from '~/types/offer';

const route = useRoute();
const api = useApi();
const userStore = useUserStore();
const pusher = usePusher();

const isEditRequestModalOpen = ref(false);
const isAddOfferModalOpen = ref(false);
const isDeleteRequestModalOpen = ref(false);
const isDeletingRequest = ref(false);
let channel: Channel;

const {
  data: request,
  error,
  refresh
} = useAsyncData<Request>('request', async () => {
  const response = await api.get(`/request/${route.params.requestId}`);
  return response.data;
});

async function deleteRequest() {
  try {
    isDeletingRequest.value = true;
    await api.delete(`/request/${route.params.requestId}`);
    navigateTo('/');
  } catch (error) {
    console.error(error);
  } finally {
    isDeletingRequest.value = false;
  }
}

onMounted(() => {
  channel = pusher.subscribe(`public-request-${route.params.requestId}`);

  channel.bind('new-offer', (data: Offer) => {
    if (!request.value?.offers.find((offer) => offer.id === data.id)) {
      request.value?.offers.push(data);
    }
  });

  channel.bind(
    'update-offer-images',
    (data: { offerId: number; images: string[] }) => {
      const offer = request.value?.offers.find(
        (offer) => offer.id === data.offerId
      );
      if (offer) {
        offer.images = data.images.map((image) => ({ name: image }));
      }
    }
  );

  channel.bind('update-request', (data: Partial<Request>) => {
    if (request.value) {
      request.value = {
        ...request.value,
        ...data
      };
    }
  });

  channel.bind('delete-request', () => {
    navigateTo('/');
  });
});

onUnmounted(() => {
  channel.unsubscribe();
  channel.unbind_all();
});
</script>
