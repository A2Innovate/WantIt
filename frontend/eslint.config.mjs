// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs';

export default withNuxt({
  rules: {
    'vue/html-self-closing': 'off' // Fixes conflict with Prettier: https://github.com/prettier/prettier/issues/5246
  }
}); // Your custom configs here
