<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <UiCard>
        <VChart
          :option="option"
          autoresize
          style="width: 100%; height: 15rem"
        />
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});

const option = ref<ECOption>({
  xAxis: {
    data: ['0', '1', '2', '3', '4', '5', '6'],
    axisLabel: { color: 'white' }
  },
  yAxis: {
    axisLabel: { color: 'white' }
  },
  series: [
    {
      data: [120, 200, 150, 80, 70, 110, 130],
      type: 'line',
      smooth: true,
      lineStyle: {
        color: 'white'
      },
      itemStyle: {
        color: 'white'
      }
    }
  ]
});
</script>
