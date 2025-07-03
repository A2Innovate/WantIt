<template>
  <UiCard>
    <div class="flex items-center justify-between mb-2">
      <h2 class="sm:text-xl">
        {{ t('ratelimits_hit_in_last_24_hours') }}
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
      <UiChartBar
        v-if="data && data.endpoints.length"
        :x="data.endpoints"
        :y="data.count"
      />
      <div
        v-else-if="status !== 'pending'"
        class="h-60 text-neutral-400 flex items-center justify-center"
      >
        <p>{{ t('no_ratelimits_hit') }}</p>
      </div>
      <UiSkeletonLoader v-else class="h-60" />
    </Transition>
  </UiCard>
</template>

<script setup lang="ts">
const cache = ref(true);
const isLoading = ref(false);
const { t } = useI18n();

const requestFetch = useRequestFetch();
const { data, refresh, status } = useAsyncData(
  `admin-stats-ratelimit-exceeded`,
  async () => {
    isLoading.value = true;
    try {
      const response = await requestFetch<{
        endpoints: string[];
        count: number[];
      }>(
        useRuntimeConfig().public.apiBase +
          '/api/admin/stats/ratelimit/endpoints',
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
