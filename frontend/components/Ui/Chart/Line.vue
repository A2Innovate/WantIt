<template>
  <VChart
    :option="option"
    autoresize
    :style="{ width: '100%', height: '15rem' }"
  />
</template>

<script setup lang="ts" generic="T, K">
const props = defineProps<{ x: T[]; y: K[] }>();
const option = ref<ECOption>({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  xAxis: {
    data: props.x,
    axisLabel: { color: 'white' }
  },
  yAxis: {
    axisLabel: { color: 'white' }
  },
  series: [
    {
      data: props.y,
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
