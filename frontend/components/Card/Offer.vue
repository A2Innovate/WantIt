<template>
  <UiCard>
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <NuxtLink :to="`/user/${offer.user.id}`">
          <div class="flex items-center space-x-2 group">
            <div class="w-8 h-8 rounded-full bg-neutral-700">
              <div
                class="w-full h-full flex items-center justify-center font-medium group-hover:text-neutral-300 transition-colors"
              >
                {{ offer.user.name.charAt(0) }}
              </div>
            </div>
            <div>
              <span
                class="text-sm text-gray-400 group-hover:text-gray-500 transition-colors"
                >Offered by</span
              >
              <span
                class="ml-1 font-medium group-hover:text-neutral-300 transition-colors"
              >
                @{{ offer.user.username }}
              </span>
            </div>
          </div>
        </NuxtLink>
        <span
          class="px-2 py-1 rounded-full text-xs font-medium tracking-wide"
          :class="{
            'bg-emerald-500/20 text-emerald-400': offer.negotiation,
            'bg-neutral-800 text-gray-400': !offer.negotiation
          }"
        >
          {{ offer.negotiation ? 'NEGOTIABLE' : 'FIXED' }}
        </span>
      </div>

      <UiImageCarousel
        :images="
          offer.images.map(
            (image) =>
              `${useRuntimeConfig().public.s3Endpoint}/${useRuntimeConfig().public.s3Bucket}/request/${offer.requestId}/offer/${offer.id}/images/${image.name}`
          )
        "
      />

      <p class="text-gray-300 text-sm leading-relaxed">
        {{ offer.content }}
      </p>

      <div
        v-if="userStore.current?.id === offer.user.id"
        class="flex justify-end"
      >
        <UiButton @click="isDeleteModalOpen = true">
          <Icon name="material-symbols:delete-rounded" />
          <span class="hidden sm:block">Delete</span>
        </UiButton>
      </div>

      <div class="flex pt-4 border-t items-center gap-1 border-neutral-800/80">
        <span class="text-xl font-semibold">
          {{ priceFmt(offer.price, currency) }}
        </span>
        <ConvertedPrice
          class="text-xs"
          :currency="currency"
          :amount="offer.price"
        />
      </div>

      <div
        v-if="offer.comments.length > 0"
        class="pt-4 border-t border-neutral-800/80 mt-4"
      >
        <h4 class="text-md font-semibold mb-2 text-neutral-200">Comments</h4>
        <div class="flex flex-col gap-2">
          <CardComment
            v-for="comment in offer.comments"
            :key="comment.id"
            :comment="comment"
          />
        </div>
      </div>
      <BlockAddComment v-if="userStore.current" :offer-id="offer.id" />
    </div>
    <Teleport to="body">
      <ModalConfirm
        :is-open="isDeleteModalOpen"
        :is-loading="isDeleting"
        @cancel="isDeleteModalOpen = false"
        @confirm="deleteOffer()"
      >
        Are you sure you want to delete this offer?
      </ModalConfirm>
    </Teleport>
  </UiCard>
</template>

<script setup lang="ts">
import type { Offer } from '@/types/offer';

const userStore = useUserStore();
const props = defineProps<{ offer: Offer; currency: string }>();

const api = useApi();
const isDeleteModalOpen = ref(false);
const isDeleting = ref(false);

async function deleteOffer() {
  try {
    isDeleting.value = true;
    await api.delete(
      `/request/${props.offer.requestId}/offer/${props.offer.id}`
    );
  } finally {
    isDeleting.value = false;
  }
}
</script>
