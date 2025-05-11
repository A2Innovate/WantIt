export default defineNuxtRouteMiddleware(async () => {
  const userStore = useUserStore();

  if (!userStore.current) {
    await userStore.fetchUser();

    if (!userStore.current) {
      return navigateTo('/auth/sign-in');
    }
  }
});
