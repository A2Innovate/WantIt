import Pusher from 'pusher-js';

export function usePusher() {
  const config = useRuntimeConfig().public;

  const pusher = new Pusher(config.pusherKey, {
    wsHost: config.pusherWsHost,
    disableStats: true,
    cluster: config.pusherCluster,
    forceTLS: true,
    enabledTransports: ['ws', 'wss']
  });

  return pusher;
}
