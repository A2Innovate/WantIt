import Pusher from 'pusher-js';
import type { UserAuthenticationCallback } from 'pusher-js';

export function usePusher() {
  const config = useRuntimeConfig().public;
  const api = useApi();

  function authHandler(
    params: { socketId: string; channelName?: string },
    callback: UserAuthenticationCallback
  ) {
    api
      .post('/auth/pusher', {
        socket_id: params.socketId,
        channel_name: params.channelName
      })
      .then((res) => {
        callback(null, res.data);
      })
      .catch((err) => {
        callback(err, null);
      });
  }

  /*
   * Custom handler overrides endpoint and transport,
   * but for some reason they're still needed to not cause a type error
   */
  const pusher = new Pusher(config.pusherKey, {
    wsHost: config.pusherWsHost,
    disableStats: true,
    cluster: config.pusherCluster,
    forceTLS: true,
    enabledTransports: ['ws', 'wss'],
    channelAuthorization: {
      customHandler: authHandler,
      endpoint: config.apiBase + '/api/auth/pusher',
      transport: 'ajax'
    },
    userAuthentication: {
      customHandler: authHandler,
      transport: 'ajax',
      endpoint: config.apiBase + '/api/auth/pusher'
    }
  });

  return pusher;
}
