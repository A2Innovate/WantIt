<template>
  <UiModal card-class="w-md" :is-open="isOpen" @close="emit('close')">
    <h2 class="text-2xl font-semibold">{{ t('new_offer') }}</h2>
    <form class="flex flex-col gap-2 mt-2" @submit.prevent="addOffer">
      <UiImageSelect @update="images = $event" />
      <UiLabel for="content">{{ t('what_is_your_offer') }}</UiLabel>
      <UiInput id="content" v-model="content" placeholder="An iPhone..." />
      <UiLabel for="price">{{ t('price') }}</UiLabel>
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
        {{ t('negotiable') }}
        <UiCheckbox id="negotiation" v-model="negotiation" />
      </UiLabel>
      <UiButton type="submit" class="mt-2" :loading="isLoading">{{ t('add') }}</UiButton>
    </form>
    <p v-if="error" class="text-red-500 mt-2 text-center">{{ error }}</p>
  </UiModal>
</template>

<script setup lang="ts">
import { createAndEditOfferSchema } from '@/schema/services/request';
import { AxiosError } from 'axios';
import type { Request } from '~/types/request';

const { t } = useI18n();

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
      error.value = t(validation);
      return;
    }

    if (images.value && images.value.length > 10) {
      error.value = t('max_offer_images');
      return;
    }

    if (images.value) {
      for (const image of images.value) {
        if (image.size > 1024 * 1024 * 5) {
          error.value = t('max_image_size');
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
      error.value = t('unknown_error');
    }
  } finally {
    isLoading.value = false;
  }
}
</script>
