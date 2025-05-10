import axios from 'axios';

export function useApi() {
  const api = axios.create({
    baseURL: useRuntimeConfig().public.apiBase + '/api',
    withCredentials: true
  });

  return api;
}
