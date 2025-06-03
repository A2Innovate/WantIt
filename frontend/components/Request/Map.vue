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
        v-for="request in requestsWithLocation"
        :key="request.id"
        :lat-lng="[request.location!.y, request.location!.x]"
      >
        <LTooltip>{{ request.content }}</LTooltip>
      </LMarker>
      <LCircle
        v-for="request in requestsWithLocation"
        :key="request.id"
        :lat-lng="[request.location!.y, request.location!.x]"
        :radius="request.radius"
      />
    </LMap>
  </div>
</template>

<script setup lang="ts">
const requestStore = useRequestStore();
const requestsWithLocation = computed(() => {
  return requestStore.requests?.filter((request) => request.location);
});
</script>
