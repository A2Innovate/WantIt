<template>
  <Transition name="slide-up-blur" mode="out-in">
    <p :key="text">{{ text }}</p>
  </Transition>
</template>

<script setup lang="ts">
const text = ref('What do you want to buy?');
let step = 0;

onMounted(() => {
  setInterval(() => {
    step++;
    switch (step) {
      case 1:
        text.value = 'Or maybe you want to sell?';
        break;
      case 2:
        text.value = "You got something you don't need?";
        break;
      case 3:
        text.value = 'What do you want to buy?';
        step = 0;
        break;
    }
  }, 3000);
});
</script>
