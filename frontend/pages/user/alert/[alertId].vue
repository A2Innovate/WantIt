<template>
  <div class="max-w-3xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Alert</h1>
      <UiCard>
        <UiMapPoints
          v-if="data?.alert.location"
          class="mb-4"
          :data="mapPoints"
          @marker:click="
            (event) => {
              highlightId = event.id;
              $router.replace({ hash: `#request-${event.id}` });
            }
          "
        />
        <UiSkeletonLoader v-else-if="!data" class="mb-4 h-60 w-full" />
        <h3 v-if="data">{{ data.alert.content }}</h3>
        <UiSkeleton v-else class="h-6 w-1/2" />
        <p v-if="data" class="flex items-center gap-1">
          {{
            COMPARISON_MODES.find(
              (mode) => mode.value === data?.alert.budgetComparisonMode
            )?.label
          }}
          {{ priceFmt(data.alert.budget, data.alert.currency) }}
          <ConvertedPrice
            class="text-xs"
            :currency="data.alert.currency"
            :amount="data.alert.budget"
          />
        </p>
        <UiSkeleton v-else class="h-6 w-24 mt-1" />
        <div v-if="data" class="flex gap-2 mt-4">
          <UiButton @click="isEditAlertModalOpen = true">
            <Icon name="material-symbols:edit-rounded" />
            <span class="hidden sm:block">Edit</span>
          </UiButton>
          <UiButton @click="isDeleteAlertModalOpen = true">
            <Icon name="material-symbols:delete-rounded" />
            <span class="hidden sm:block">Delete</span>
          </UiButton>
        </div>
      </UiCard>
      <div v-if="data?.requests.length" class="flex flex-col gap-2">
        <CardRequest
          v-for="request in data.requests"
          :id="`request-${request.id}`"
          :key="request.id"
          :class="{
            'ring-1 ring-neutral-400': highlightId === request.id
          }"
          :request="request"
        />
      </div>
      <Teleport to="body">
        <ModalConfirm
          :is-open="isDeleteAlertModalOpen"
          :is-loading="isDeletingAlert"
          @cancel="isDeleteAlertModalOpen = false"
          @confirm="deleteAlert"
        >
          <p class="text-center">Are you sure you want to delete this alert?</p>
        </ModalConfirm>
      </Teleport>
      <Teleport to="body">
        <ModalEditAlert
          v-if="data"
          :is-open="isEditAlertModalOpen"
          :alert="data.alert"
          @close="isEditAlertModalOpen = false"
        />
      </Teleport>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Alert } from '~/types/alert';
import type { Channel } from 'pusher-js';
import type { Request } from '~/types/request';

definePageMeta({
  middleware: 'auth'
});

const route = useRoute();
const requestFetch = useRequestFetch();
const isDeleteAlertModalOpen = ref(false);
const isDeletingAlert = ref(false);
const isEditAlertModalOpen = ref(false);
const api = useApi();
const pusher = usePusher();
const highlightId = ref<number | null>(null);
let channel: Channel;
const mapPoints = computed(() => {
  if (!data.value) {
    return [];
  }

  const requests = data.value.requests
    .filter(
      (
        request
      ): request is Request & {
        location: { x: number; y: number };
        radius: number;
      } => request.location !== null && request.radius !== null
    )
    .map((request) => ({
      id: request.id,
      location: request.location,
      radius: request.radius,
      content: request.content,
      color: 'blue',
      clickable: true
    }));

  const alert = {
    id: data.value.alert.id,
    location: data.value.alert.location,
    radius: data.value.alert.radius,
    content: 'Your alert',
    color: 'red'
  };

  return [...requests, alert];
});

const { data } = useAsyncData('alert', async () => {
  const response = await requestFetch<{ alert: Alert; requests: Request[] }>(
    useRuntimeConfig().public.apiBase +
      '/api/user/alert/' +
      route.params.alertId,
    {
      credentials: 'include'
    }
  );
  return response;
});

async function deleteAlert() {
  try {
    isDeletingAlert.value = true;
    await api.delete(`/user/alert/${route.params.alertId}`);
    navigateTo('/user/alerts');
  } catch (error) {
    console.error(error);
  } finally {
    isDeletingAlert.value = false;
  }
}

onMounted(() => {
  channel = pusher.subscribe(
    `private-user-${useUserStore().current?.id}-alert-${route.params.alertId}`
  );

  channel.bind('update-alert', ({ alert }: { alert: Alert }) => {
    if (data.value) {
      data.value.alert = alert;
    }
  });

  channel.bind('delete-alert', () => {
    navigateTo('/user/alerts');
  });

  channel.bind('new-match', (request: Request) => {
    if (data.value) {
      data.value.requests.push(request);
    }
  });
});

onUnmounted(() => {
  if (channel) {
    channel.unbind_all();
    channel.unsubscribe();
  }
});
</script>
