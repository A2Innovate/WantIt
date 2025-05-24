<template>
  <div ref="dropdownRef" class="relative">
    <div role="button" tabindex="0" @click="toggleDropdown">
      <slot />
    </div>

    <transition
      enter-active-class="transition ease-out duration-100"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-75"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="isOpen"
        class="absolute right-0 mt-2 w-40 rounded-md bg-neutral-900 border border-neutral-700 shadow-lg z-20"
      >
        <ul class="py-1 text-sm text-white">
          <li>
            <NuxtLink
              :to="`/user/${userStore.current?.id}`"
              class="flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition"
              ><Icon name="material-symbols:account-circle" /> Profile
            </NuxtLink>
          </li>
          <li>
            <NuxtLink
              to="/user/settings"
              class="flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition"
              ><Icon name="material-symbols:settings" /> Settings
            </NuxtLink>
          </li>
          <li>
            <button
              class="w-full text-left flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition"
              @click="signOut"
            >
              <Icon name="material-symbols:logout" /> Sign out
            </button>
          </li>
        </ul>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
const isOpen = ref(false);
const dropdownRef = ref<HTMLElement | null>(null);

function toggleDropdown() {
  isOpen.value = !isOpen.value;
}

function closeDropdown(e: MouseEvent) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    isOpen.value = false;
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', closeDropdown);
});

const userStore = useUserStore();
function signOut() {
  userStore.logout();
  isOpen.value = false;
  navigateTo('/');
}
</script>
