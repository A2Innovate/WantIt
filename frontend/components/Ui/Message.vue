<template>
  <div
    :class="[
      'p-4 rounded-lg border border-neutral-700 bg-neutral-900 flex flex-col break-all w-full max-w-56 sm:max-w-xs relative',
      isSender ? 'self-end' : 'self-start'
    ]"
  >
    <div v-if="isSender" ref="dropdownRef" class="absolute top-0 right-0">
      <button
        class="cursor-pointer text-neutral-300 p-1 flex"
        @click="isOptionsModalOpen = !isOptionsModalOpen"
      >
        <Icon
          name="material-symbols:keyboard-arrow-down"
          class="transition-all"
          :class="{ 'rotate-180': isOptionsModalOpen }"
        />
      </button>
      <DropdownBasePopup
        :is-open="isOptionsModalOpen"
        popup-class="right-0"
        :dropdown-ref="dropdownRef"
        @update:is-open="isOptionsModalOpen = $event"
      >
        <DropdownBaseElement
          @click="
            isOptionsModalOpen = false;
            handleEdit();
          "
        >
          <p class="flex items-center gap-2">
            <Icon name="material-symbols:edit-rounded" />
            Edit
          </p>
        </DropdownBaseElement>
      </DropdownBasePopup>
    </div>
    <p v-if="!editMode">{{ message.content }}</p>
    <UiTextArea v-else v-model="editedContent" class="mb-2 bg-neutral-950" />
    <button
      v-if="editMode"
      class="p-1 px-2 border border-neutral-700 hover:bg-neutral-800 rounded-lg flex w-fit ml-auto transition cursor-pointer"
      @click="handleEdit"
    >
      <p class="flex items-center gap-2 text-xs">
        <Icon v-if="!isSavingEdit" name="material-symbols:done" />
        <UiLoader v-else :size="1" variant="white" />
        <span v-if="!isSavingEdit">Save</span>
        <span v-else>Saving</span>
      </p>
    </button>
    <span v-if="message.edited && !editMode" class="text-xs text-neutral-500"
      >(edited)
    </span>

    <div class="flex justify-between">
      <ClientOnly>
        <span class="text-sm text-neutral-400 ml-auto">
          {{ formatTime(new Date(message.createdAt)) }}
        </span>
      </ClientOnly>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Message } from '@/types/message';
import { AxiosError } from 'axios';

const props = defineProps<{
  message: Message;
}>();
const editMode = ref(false);
const editedContent = ref(props.message.content);
const error = ref('');
const api = useApi();
const isOptionsModalOpen = ref(false);
const isSavingEdit = ref(false);
const dropdownRef = ref<HTMLElement | undefined>(undefined);

const isSender = computed(() => {
  return props.message.senderId === useUserStore().current?.id;
});

async function handleEdit() {
  if (!editMode.value) {
    editMode.value = true;
  } else {
    if (editedContent.value !== props.message.content) {
      try {
        error.value = '';
        isSavingEdit.value = true;

        await api.put(`/chat/message/${props.message.id}`, {
          content: editedContent.value
        });

        editMode.value = false;
      } catch (e) {
        if (e instanceof AxiosError && e.response?.data.message) {
          error.value = e.response.data.message;
        } else {
          error.value = 'Something went wrong';
        }
      } finally {
        isSavingEdit.value = false;
      }
    } else {
      editMode.value = false;
    }
  }
}
</script>
