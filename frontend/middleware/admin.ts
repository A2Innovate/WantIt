export default defineNuxtRouteMiddleware(async () => {
  const userStore = useUserStore();

  if (!userStore.current?.isAdmin) {
    return navigateTo('/');
  }
});
