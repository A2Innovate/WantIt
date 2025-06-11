export default defineNuxtRouteMiddleware(() => {
  const userStore = useUserStore();

  if (!userStore.current?.isAdmin) {
    return navigateTo('/');
  }
});
