<template>
  <div>
    <div
      class="flex justify-center items-center bg-neutral-950 border-b border-neutral-800 h-14"
    >
      <div class="max-w-5xl w-full flex justify-between items-center px-4">
        <NuxtLink
          class="text-2xl font-semibold hover:text-neutral-300 transition-colors duration-150"
          to="/"
          >WantIt</NuxtLink
        >
        <div v-if="userStore.current" class="flex items-center gap-2">
          <div
            class="flex items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
            @click="isAddRequestModalOpen = true"
          >
            <Icon name="material-symbols:add" />
          </div>
          <DropdownNotifications />
          <AccountDropdown>
            <div
              class="flex gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
              role="button"
              tabindex="0"
            >
              <Icon name="material-symbols:account-circle" />
              <p class="text-sm select-none">{{ userStore.current.name }}</p>
            </div>
          </AccountDropdown>
        </div>
        <div v-else class="flex items-center gap-2">
          <NuxtLink class="text-sm" to="/auth/sign-in">Sign in</NuxtLink>
          <NuxtLink class="text-sm" to="/auth/sign-up">Sign up</NuxtLink>
        </div>
      </div>
    </div>
    <slot />
    <ModalNewRequest
      :is-open="isAddRequestModalOpen"
      @close="isAddRequestModalOpen = false"
    />
    <footer
      class="bg-neutral-950 border-t border-neutral-800 h-16 px-4 flex gap-2 justify-between items-center"
    >
      <p>© {{ new Date().getFullYear() }} A2Innovate.</p>
      <NuxtLink
        to="https://github.com/A2Innovate/WantIt"
        class="flex hover:text-neutral-300 transition-colors"
        target="_blank"
      >
        <Icon name="mdi:github" size="2em" />
      </NuxtLink>
    </footer>
  </div>
</template>

<script setup lang="ts">
const userStore = useUserStore();
const isAddRequestModalOpen = ref(false);
</script>
