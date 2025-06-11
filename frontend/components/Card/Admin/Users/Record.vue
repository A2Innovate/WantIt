<template>
  <div>
    <div class="flex py-2">
      <div class="flex w-full justify-start items-center gap-2">
        <div class="w-8 h-8 rounded-full bg-neutral-700">
          <div
            class="w-full h-full flex items-center justify-center font-medium text-xs"
          >
            {{ user.name.charAt(0).toUpperCase() }}
          </div>
        </div>
        <div>
          <p class="flex items-center gap-1">
            {{ user.name }}
            <span
              v-if="user.isAdmin"
              class="text-xs text-green-600 bg-green-200 px-1 rounded"
              >Admin</span
            >
            <Transition name="slide-down-blur">
              <span
                v-if="user.isBlocked"
                class="text-xs text-red-600 bg-red-200 px-1 rounded"
                >Blocked</span
              >
            </Transition>
          </p>
          <p class="text-xs text-neutral-400">{{ user.email }}</p>
        </div>
      </div>
      <UiButton
        class="ml-auto"
        :disabled="user.isAdmin"
        :icon="
          user.isBlocked
            ? 'material-symbols:lock-open'
            : 'material-symbols:lock'
        "
        :loading="isBlocking"
        :variant="user.isBlocked ? 'outline' : 'danger'"
        @click="switchBlock"
      >
        <p v-if="user.isBlocked">Unblock</p>
        <p v-else>Block</p>
      </UiButton>
    </div>
    <hr v-if="!isLast" class="border-neutral-700" />
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types/user';

const props = defineProps<{ user: User; isLast?: boolean }>();

const isBlocking = ref(false);
const api = useApi();

async function switchBlock() {
  try {
    isBlocking.value = true;
    await api.post('/admin/users/' + props.user.id + '/switch-block');
  } finally {
    isBlocking.value = false;
  }
}
</script>
