<template>
  <div>
    <LMap
      style="height: 15rem"
      :zoom="0"
      :center="[0, 0]"
      :use-global-leaflet="false"
    >
      <LTileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors'
        layer-type="base"
        name="OpenStreetMap"
      />
      <LMarker
        v-for="item in data"
        :key="item.id"
        :lat-lng="[item.location.y, item.location.x]"
        @click="item.clickable ? emit('marker:click', item) : undefined"
      >
        <LTooltip>{{ item.content }}</LTooltip>
      </LMarker>
      <LCircle
        v-for="item in data"
        :key="item.id"
        :lat-lng="[item.location.y, item.location.x]"
        :radius="item.radius"
        :color="item.color"
      />
    </LMap>
  </div>
</template>

<script setup lang="ts">
interface Point {
  id: number;
  color: string;
  location: {
    x: number;
    y: number;
  };
  radius: number;
  content: string;
  clickable?: boolean;
}

defineProps<{
  data: Point[];
}>();

const emit = defineEmits(['marker:click']);
</script>
