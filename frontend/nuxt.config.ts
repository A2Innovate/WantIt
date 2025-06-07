import tailwindcss from '@tailwindcss/vite';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
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
  echarts: {
    renderer: 'svg',
    charts: ['LineChart'],
    components: ['GridComponent']
  },
  vite: {
    plugins: [tailwindcss()]
  }
});
