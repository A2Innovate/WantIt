<template>
  <UiModal card-class="w-md m-4" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">Edit offer</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="editOffer">
      <UiLabel v-if="props.offer.images.length" for="images"
        >Current images</UiLabel
      >
      <div v-if="props.offer.images.length" class="grid grid-cols-3 gap-2 mt-2">
        <div
          v-for="image in props.offer.images"
          :key="image.name"
          class="relative"
        >
          <img
            :src="`${useRuntimeConfig().public.s3Endpoint}/${useRuntimeConfig().public.s3Bucket}/request/${props.offer.requestId}/offer/${props.offer.id}/images/${image.name}`"
            class="h-32 w-full rounded-lg object-contain border border-neutral-800 p-1"
          />
          <UiButton
            type="button"
            class="absolute top-1 right-1"
            :class="{
              'bg-red-500 hover:bg-red-600': imagesMarkedForDeletion.includes(
                image.name
              )
            }"
            @click="handleImageMark(image.name)"
          >
            <Icon name="material-symbols:delete-rounded" />
          </UiButton>
        </div>
      </div>
      <UiLabel for="newImages">New images</UiLabel>
      <UiImageSelect @update="newImages = $event" />
      <UiLabel for="content">What is your offer?</UiLabel>
      <UiInput id="content" v-model="content" placeholder="An iPhone..." />
      <UiLabel for="price">Price</UiLabel>
      <div class="flex">
        <DropdownCurrency :model-value="currency" readonly />
        <UiInput
          id="price"
          v-model="price"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <ConvertedPrice
        :currency="currency"
        :amount="Number(price)"
        class="text-xs"
      />
      <UiLabel for="negotiation">
        Negotiable
        <UiToggle id="negotiation" v-model="negotiation" />
      </UiLabel>
      <UiButton type="submit" class="mt-2" :loading="isLoading">Save</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { createAndEditOfferSchema } from '@/schema/services/request';
import { AxiosError } from 'axios';
import type { Offer } from '~/types/offer';

const props = defineProps<{
  isOpen: boolean;
  offer: Offer;
  currency: string;
}>();

const emit = defineEmits(['close']);
const api = useApi();
const userStore = useUserStore();

const imagesMarkedForDeletion = ref<string[]>([]);
const newImages = ref<FileList | null>();
const content = ref(props.offer.content);
const price = ref(props.offer.price.toString());
const negotiation = ref(props.offer.negotiation);
const error = ref('');
const isLoading = ref(false);

async function editOffer() {
  try {
    isLoading.value = true;

    const mainPayload = {
      content: content.value,
      price: Number(price.value),
      negotiation: negotiation.value
    };

    const validation = validate(createAndEditOfferSchema, mainPayload);

    if (validation) {
      error.value = validation;
      return;
    }

    if (
      newImages.value &&
      props.offer.images.length -
        imagesMarkedForDeletion.value.length +
        newImages.value.length >
        10
    ) {
      error.value = 'One offer can have up to 10 images.';
      return;
    }

    if (newImages.value) {
      for (const image of newImages.value) {
        if (image.size > 1024 * 1024 * 5) {
          error.value =
            'At least one of your new images is too large, max size is 5MB.';
          return;
        }
      }
    }

    if (imagesMarkedForDeletion.value.length) {
      if (
        userStore.current?.isAdmin &&
        userStore.current.id !== props.offer.user.id
      ) {
        await api.delete(
          `/request/${props.offer.requestId}/offer/${props.offer.id}/images`,
          {
            data: {
              images: imagesMarkedForDeletion.value
            },
            params: {
              pretendUser: props.offer.user.id
            }
          }
        );
      } else {
        await api.delete(
          `/request/${props.offer.requestId}/offer/${props.offer.id}/images`,
          {
            data: {
              images: imagesMarkedForDeletion.value
            }
          }
        );
      }
      imagesMarkedForDeletion.value = [];
    }

    if (
      userStore.current?.isAdmin &&
      userStore.current.id !== props.offer.user.id
    ) {
      await api.put(
        `/request/${props.offer.requestId}/offer/${props.offer.id}`,
        mainPayload,
        {
          params: {
            pretendUser: props.offer.user.id
          }
        }
      );
    } else {
      await api.put(
        `/request/${props.offer.requestId}/offer/${props.offer.id}`,
        mainPayload
      );
    }

    if (newImages.value) {
      if (
        userStore.current?.isAdmin &&
        userStore.current.id !== props.offer.user.id
      ) {
        await api.postForm(
          `/request/${props.offer.requestId}/offer/${props.offer.id}/image`,
          {
            images: newImages.value
          },
          {
            params: {
              pretendUser: props.offer.user.id
            }
          }
        );
      } else {
        await api.postForm(
          `/request/${props.offer.requestId}/offer/${props.offer.id}/image`,
          {
            images: newImages.value
          }
        );
      }
    }

    emit('close');
    newImages.value = null;
    error.value = '';
  } catch (e) {
    if (e instanceof AxiosError && e.response?.data.message) {
      error.value = e.response.data.message;
    } else {
      error.value = 'Something went wrong';
    }
  } finally {
    isLoading.value = false;
  }
}

function handleImageMark(imageName: string) {
  if (imagesMarkedForDeletion.value.includes(imageName)) {
    imagesMarkedForDeletion.value = imagesMarkedForDeletion.value.filter(
      (name) => name !== imageName
    );
  } else {
    imagesMarkedForDeletion.value.push(imageName);
  }
}
</script>
