<template>
  <div>
    <div
      class="flex justify-center items-center bg-neutral-950 border-b border-neutral-800 h-14"
    >
      <div class="max-w-5xl w-full flex justify-between items-center px-4">
        <h1 class="text-2xl font-semibold">WantIt</h1>
        <div v-if="userStore.current" class="flex items-center gap-2">
          <div
            class="flex items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
          >
            <Icon name="material-symbols:add" />
          </div>
          <AccountDropdown>
            <div
              class="flex gap-2 items-center bg-neutral-900 h-8 px-2 rounded-full cursor-pointer"
              role="button"
              tabindex="0"
            >
              <Icon name="material-symbols:account-circle" />
              <p class="text-sm">{{ userStore.current.name }}</p>
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
  </div>
</template>

<script setup lang="ts">
const userStore = useUserStore();
</script>
