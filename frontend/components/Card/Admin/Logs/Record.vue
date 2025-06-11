<template>
  <div>
    <div
      class="hover:bg-neutral-800 flex md:flex-row gap-1 md:gap-0 flex-col justify-between items-center transition-colors duration-75 px-4 py-2"
    >
      <NuxtLink
        class="md:w-1/6 flex w-full justify-start items-center gap-2"
        :class="
          log.user ? 'hover:text-neutral-300 transition-colors' : ''
        "
        :to="log.user ? `/user/${log.user?.id}` : ''"
      >
        <UiAvatarText :text="getAvatar()" size="small" />
        <p
          :class="
            log.ip ? 'blur-xs hover:blur-none transition-all' : ''
          "
        >
          {{ log.user?.name || log.ip || 'System' }}
        </p>
      </NuxtLink>
      <div class="w-full md:w-4/6">
        <p v-if="log.type === 'USER_LOGIN'">Logged in</p>
        <p v-else-if="log.type === 'USER_LOGIN_FAILURE'">
          Failed login attempt to
          <span class="blur-xs hover:blur-none transition-all">{{
            log.content
          }}</span>
        </p>
        <p v-else-if="log.type === 'USER_LOGOUT'">Logged out</p>
        <p v-else-if="log.type === 'USER_REGISTRATION'">Registered</p>
        <p v-else-if="log.type === 'REQUEST_CREATE'">
          Created request {{ log.content }}
        </p>
        <p v-else-if="log.type === 'REQUEST_UPDATE'">
          Updated request {{ log.content }}
        </p>
        <p v-else-if="log.type === 'REQUEST_DELETE'">
          Deleted request {{ log.content }}
        </p>
        <p v-else-if="log.type === 'OFFER_CREATE'">
          Created offer {{ log.content }}
        </p>
        <p v-else-if="log.type === 'OFFER_UPDATE'">
          Updated offer {{ log.content }}
        </p>
        <p v-else-if="log.type === 'OFFER_DELETE'">
          Deleted offer {{ log.content }}
        </p>
        <p v-else-if="log.type === 'RATELIMIT_HIT'">
          Hit rate limit on {{ log.content }}
        </p>
      </div>
      <ClientOnly>
        <p
          class="text-xs text-neutral-400 w-full md:w-1/6 text-right"
        >
          {{ formatTime(new Date(log.createdAt)) }}
        </p>
      </ClientOnly>
    </div>
    <hr
      v-if="isLast"
      class="border-neutral-800"
    />
  </div>
</template>

<script setup lang="ts">
import type { Log } from '~/types/log';


const props = defineProps<{
  log: Log
  isLast?: boolean;
}>();

function getAvatar() {
  if (props.log.user) {
    return props.log.user.name.charAt(0).toUpperCase();
  }

  if (props.log.ip) {
    return 'IP';
  }

  return 'S'
}
</script>