import tailwindcss from '@tailwindcss/vite';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/i18n',
    '@nuxt/fonts',
    '@nuxt/icon',
    '@nuxt/eslint',
    '@pinia/nuxt',
    '@nuxtjs/leaflet',
    'nuxt-echarts'
  ],
  css: ['~/assets/css/main.css'],
  runtimeConfig: {
    public: {
      apiBase: '',
      s3Endpoint: '',
      s3Bucket: '',
      pusherKey: '',
      pusherCluster: '',
      pusherWsHost: ''
    }
  },
  i18n: {
    locales: [
      { code: 'en', iso: 'en-US', file: 'en.json', name: 'English' },
      { code: 'pl', iso: 'pl-PL', file: 'pl.json', name: 'Polski' }
    ],
    defaultLocale: 'en',
  },
  echarts: {
    charts: ['LineChart', 'BarChart'],
    components: ['GridComponent', 'TooltipComponent']
  },
  vite: {
    plugins: [tailwindcss()]
  }
});
