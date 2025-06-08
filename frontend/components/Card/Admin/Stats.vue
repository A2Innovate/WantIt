<template>
  <UiCard>
    <div class="flex items-center justify-between mb-2">
      <h2 class="sm:text-xl">
        {{ props.type.charAt(0).toUpperCase() + props.type.slice(1) }} created
        in the last <span class="font-semibold">30</span> days
      </h2>
      <UiButton
        icon="material-symbols:refresh"
        size="small"
        :loading="isLoading"
        @click="
          cache = false;
          refresh();
        "
      />
    </div>
    <Transition name="slide-up-blur" mode="out-in">
      <UiChartLine v-if="data" :x="data.day" :y="data.count" />
      <UiSkeletonLoader v-else class="h-60" />
    </Transition>
  </UiCard>
</template>

<script setup lang="ts">
import type { Stats } from '~/types/stats';

const props = defineProps<{
  type: 'users' | 'offers' | 'requests';
}>();

const cache = ref(true);
const isLoading = ref(false);

const requestFetch = useRequestFetch();
const { data, refresh } = useAsyncData(
  `admin-stats-${props.type}`,
  async () => {
    isLoading.value = true;
    try {
      const response = await requestFetch<Stats>(
        useRuntimeConfig().public.apiBase + '/api/admin/stats/' + props.type,
        {
          params: {
            cache: cache.value
          },
          credentials: 'include'
        }
      );
      return response;
    } finally {
      isLoading.value = false;
    }
  }
);
</script>
