<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <UiCard>
        <h2 class="text-xl mb-2">
          Accounts created in the last
          <span class="font-semibold">30</span> days
        </h2>
        <VChart
          v-if="data"
          :option="option"
          autoresize
          :style="{ width: '100%', height: '15rem' }"
        />
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});

const requestFetch = useRequestFetch();
const { data } = await useAsyncData('users', async () => {
  const response = await requestFetch<{ day: string[]; count: number[] }>(
    useRuntimeConfig().public.apiBase + '/api/admin/stats/users',
    {
      credentials: 'include'
    }
  );
  return response;
});

const option = ref<ECOption>({
  xAxis: {
    data: data.value?.day,
    axisLabel: { color: 'white' }
  },
  yAxis: {
    axisLabel: { color: 'white' }
  },
  series: [
    {
      data: data.value?.count,
      type: 'line',
      smooth: true,
      lineStyle: {
        color: 'white'
      },
      itemStyle: {
        color: 'white'
      }
    }
  ],
  grid: {
    left: '0',
    right: '0',
    top: '3%',
    bottom: '0',
    containLabel: true
  }
});
</script>
