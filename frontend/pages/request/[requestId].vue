<template>
  <div>
    <div class="max-w-3xl mx-auto min-h-[calc(100vh-8.5rem)]">
      <h1 v-if="request" class="text-xl font-semibold my-4 px-4">Request</h1>
      <UiSkeleton v-else class="h-6 w-20 my-4 mx-4" />
      <UiCard v-if="!error" class="m-4">
        <div v-if="request && request.location" class="mb-4">
          <LMap
            style="height: 15rem"
            :zoom="2"
            :center="[request.location.y, request.location.x]"
            :use-global-leaflet="false"
          >
            <LTileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors'
              layer-type="base"
              name="OpenStreetMap"
            />
            <LCircle
              :lat-lng="[request.location.y, request.location.x]"
              :radius="request.radius"
            />
            <LMarker :lat-lng="[request.location.y, request.location.x]" />
          </LMap>
        </div>
        <UiSkeletonLoader v-else-if="!request" class="h-60 mb-4 w-full" />

        <p v-if="request">{{ request.content }}</p>
        <UiSkeleton v-else class="h-6 w-1/2" />
        <p v-if="request">
          {{ priceFmt(request.budget, request.currency) }}
          <ConvertedPrice
            class="text-xs"
            :currency="request.currency"
            :amount="request.budget"
          />
        </p>
        <UiSkeleton v-else class="h-6 w-24 mt-1" />

        <div class="flex justify-between items-center mt-4">
          <div
            v-if="
              (userStore.current &&
                userStore.current.id === request?.user.id) ||
              userStore.current?.isAdmin
            "
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
            <UiSkeleton v-else class="h-4 w-24" />
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

      <div class="flex justify-end m-4">
        <UiButton
          v-if="request && userStore.current"
          @click="isAddOfferModalOpen = true"
          >Add offer</UiButton
        >
        <UiSkeleton v-else-if="!request" class="h-8 w-24" />
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
import type { Comment } from '~/types/comment';

const route = useRoute();
const api = useApi();
const userStore = useUserStore();
const requestStore = useRequestStore();
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
    if (
      userStore.current?.isAdmin &&
      userStore.current.id !== request.value?.user.id
    ) {
      await api.delete(`/request/${route.params.requestId}`, {
        params: {
          pretendUser: request.value?.user.id
        }
      });
    } else {
      await api.delete(`/request/${route.params.requestId}`);
    }
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

  channel.bind('update-offer', (data: Partial<Offer>) => {
    if (request.value) {
      const offer = request.value.offers.find((offer) => offer.id === data.id);
      if (offer) {
        offer.content = data.content ?? offer.content;
        offer.price = data.price ?? offer.price;
        offer.negotiation = data.negotiation ?? offer.negotiation;
      }
    }
  });

  channel.bind('delete-offer', (offerId: number) => {
    if (request.value) {
      request.value.offers = request.value.offers.filter(
        (offer) => offer.id !== offerId
      );
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

  channel.bind(
    'delete-offer-images',
    (data: { offerId: number; images: string[] }) => {
      const offer = request.value?.offers.find(
        (offer) => offer.id === data.offerId
      );
      if (offer) {
        offer.images = offer.images.filter(
          (image) => !data.images.includes(image.name)
        );
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

  channel.bind('new-offer-comment', (data: Comment) => {
    const offer = request.value?.offers.find(
      (offer) => offer.id === data.offerId
    );
    if (offer) {
      data.createdAt = new Date().toString();
      offer.comments.push(data);
    }
  });

  channel.bind(
    'update-offer-comment',
    (data: { offerId: number; commentId: number; content: string }) => {
      const offer = request.value?.offers.find(
        (offer) => offer.id === data.offerId
      );
      if (offer) {
        const comment = offer.comments.find(
          (comment) => comment.id === data.commentId
        );
        if (comment) {
          comment.content = data.content;
          comment.edited = true;
        }
      }
    }
  );

  channel.bind(
    'delete-offer-comment',
    (data: { offerId: number; commentId: number }) => {
      const offer = request.value?.offers.find(
        (offer) => offer.id === data.offerId
      );
      if (offer) {
        offer.comments = offer.comments.filter(
          (comment) => comment.id !== data.commentId
        );
      }
    }
  );

  channel.bind('delete-request', () => {
    requestStore.refresh();
    navigateTo('/');
  });
});

onUnmounted(() => {
  channel.unsubscribe();
  channel.unbind_all();
});
</script>
