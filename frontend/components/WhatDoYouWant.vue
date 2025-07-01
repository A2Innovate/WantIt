<template>
  <Transition name="slide-up-blur" mode="out-in">
    <p :key="text">{{ text }}</p>
  </Transition>
</template>

<script setup lang="ts">
const { t } = useI18n();
const text = ref(t('what_do_you_want_to_buy'));
let step = 0;

onMounted(() => {
  setInterval(() => {
    step++;
    switch (step) {
      case 1:
        text.value = t('or_maybe_you_want_to_sell');
        break;
      case 2:
        text.value = t('you_got_something_you_dont_need');
        break;
      case 3:
        text.value = t('what_do_you_want_to_buy');
        step = 0;
        break;
    }
  }, 3000);
});
</script>
