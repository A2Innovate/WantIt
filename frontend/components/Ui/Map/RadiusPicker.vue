<template>
  <div>
    <div class="rounded-lg overflow-hidden">
      <LMap
        style="height: 15rem"
        :zoom="10"
        :center="[lat, lng]"
        :use-global-leaflet="false"
        :options="{ zoomControl: false }"
      >
        <LTileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors'
          layer-type="base"
          name="OpenStreetMap"
        />
        <LMarker
          :lat-lng="[lat, lng]"
          draggable
          @dragend="handleMarkerDragEnd"
        />
        <LCircle :lat-lng="[lat, lng]" :radius="radius" />
      </LMap>
    </div>
    <div class="flex items-center gap-2 mt-2">
      <UiSlider
        v-model="radius"
        :min="3000"
        :max="1000000"
        class="w-4/5"
        @input="updateValue"
      />
      <p class="text-sm w-1/5 text-center">
        {{ Math.round(radius / 1000) }} km
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { DragEndEvent } from 'leaflet';

const props = defineProps<{
  modelValue?: {
    lat: number;
    lng: number;
    radius: number;
  };
}>();

const emit = defineEmits(['update:modelValue']);
const lat = ref(props.modelValue?.lat ?? 37.78);
const lng = ref(props.modelValue?.lng ?? -122.419);
const radius = ref(props.modelValue?.radius ?? 3000);

function handleMarkerDragEnd(e: DragEndEvent) {
  const position = e.target.getLatLng();
  lat.value = position.lat;
  lng.value = position.lng;
  updateValue();
}

function updateValue() {
  emit('update:modelValue', {
    lat: lat.value,
    lng: lng.value,
    radius: radius.value
  });
}
</script>
