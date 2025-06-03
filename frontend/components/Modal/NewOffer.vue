<template>
  <UiModal card-class="w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">New offer</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="addOffer">
      <UiImageSelect @update="images = $event" />
      <UiLabel for="content">What is your offer?</UiLabel>
      <UiInput id="content" v-model="content" placeholder="An iPhone..." />
      <UiLabel for="price">Price</UiLabel>
      <div class="flex">
        <DropdownCurrency :model-value="request.currency" readonly />
        <UiInput
          id="price"
          v-model="price"
          class="w-full rounded-l-none"
          type="number"
        />
      </div>
      <ConvertedPrice
        :currency="request.currency"
        :amount="Number(price)"
        class="text-xs"
      />
      <UiLabel for="negotiation">
        Negotiable
        <UiCheckbox id="negotiation" v-model="negotiation" />
      </UiLabel>
      <UiButton type="submit" class="mt-2" :disabled="isLoading">Add</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { createAndEditOfferSchema } from '@/schema/services/request';
import { AxiosError } from 'axios';
import type { Request } from '~/types/request';

const props = defineProps<{
  isOpen: boolean;
  request: Request;
}>();

const emit = defineEmits(['close', 'update']);
const api = useApi();

const images = ref<FileList | null>(null);
const content = ref('');
const price = ref('');
const negotiation = ref(false);
const error = ref('');
const isLoading = ref(false);

async function addOffer() {
  try {
    isLoading.value = true;
    const validation = validate(createAndEditOfferSchema, {
      content: content.value,
      price: Number(price.value),
      negotiation: negotiation.value
    });

    if (validation) {
      error.value = validation;
      return;
    }

    if (images.value && images.value.length > 10) {
      error.value = 'One offer can have up to 10 images.';
      return;
    }

    if (images.value) {
      for (const image of images.value) {
        if (image.size > 1024 * 1024 * 5) {
          error.value =
            'At least one of your images is too large, max size is 5MB.';
          return;
        }
      }
    }

    const response = await api.post<Request>(
      `/request/${props.request.id}/offer`,
      {
        content: content.value,
        price: Number(price.value),
        negotiation: negotiation.value
      }
    );

    if (images.value) {
      await api.postForm(
        `/request/${props.request.id}/offer/${response.data.id}/image`,
        {
          images: images.value
        }
      );
    }

    emit('update');
    emit('close');
    content.value = '';
    price.value = '';
    images.value = null;
    negotiation.value = false;
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
</script>
