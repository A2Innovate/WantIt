<template>
  <div class="max-w-2xl mx-auto min-h-[calc(100vh-8.5rem)]">
    <div class="m-4 flex flex-col gap-4">
      <h1 class="text-xl font-semibold">Admin</h1>
      <UiCard>
        <div>
          <VChart
            :style="{ width: '100%', height: '400px' }"
            :option="option"
          />
        </div>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'admin']
});

const option = ref({
  dataset: {
    dimensions: ['Product', '2015', '2016', '2017'],
    source: [
      {
        Product: 'Matcha Latte',
        2015: 54,
        2016: 42,
        2017: 23
      }
    ]
  },
  xAxis: { type: 'category' },
  yAxis: {},
  series: [{ type: 'line' }, { type: 'line' }, { type: 'line' }]
});
</script>
