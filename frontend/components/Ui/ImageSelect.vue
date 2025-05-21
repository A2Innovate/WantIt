<template>
  <div class="border border-neutral-700 rounded-md p-2 hover:bg-neutral-900">
    <div>
      <label
        for="file"
        class="cursor-pointer text-center text-neutral-200 flex flex-col items-center justify-center gap-2"
      >
        <Icon name="material-symbols:photo" size="3em" />
        <p class="text-sm">Choose images</p>
      </label>
      <input
        id="file"
        type="file"
        multiple
        accept="image/*"
        class="hidden"
        @change="handleFileChange"
      />
    </div>
    <div v-if="imageUrls.length" class="grid grid-cols-3 gap-2 mt-2">
      <img
        v-for="image in imageUrls"
        :key="image"
        :src="image"
        class="h-32 w-full rounded-lg object-contain border border-neutral-800 p-1"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
const emit = defineEmits<{ update: [FileList | null] }>();

const files = ref<FileList | null>(null);

const imageUrls = computed(() => {
  if (!files.value) return [];
  return Array.from(files.value).map((file) => URL.createObjectURL(file));
});

function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement;
  files.value = target.files;
  emit('update', target.files);
}
</script>
