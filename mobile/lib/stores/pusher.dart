import 'package:mobile/providers/message_provider.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart';
import 'package:mobile/stores/client.dart'; // for cookieJar
import 'package:mobile/api_config.dart';

import '../types/notification.dart';

PusherClient? pusherClient;
Channel? userChannel;

void disconnectPusher() {
  try {
    if (userChannel != null) {
      pusherClient?.unsubscribe(userChannel!.name);
    }
    userChannel = null;
  } catch (e) {
    print('Error disconnecting private channel from Pusher: $e');
  }
}

Future<bool> initPusher(int userId, MessagesProvider messagesProvider) async {
  // Load cookies for the auth URL
  final cookies = await cookieJar!.loadForRequest(
    Uri.parse('${ApiConfig.baseUrl}/api/auth/pusher'),
  );
  // if (cookies.isEmpty) {
  //   return false;
  // }

  // Build cookie header string "name=value; name2=value2"
  final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

  final pusherOptions = PusherOptions(
    key: ApiConfig.pusherAppKey,
    host: ApiConfig.pusherHost,
    encrypted: true,
    authOptions: PusherAuthOptions(
      '${ApiConfig.baseUrl}/api/auth/pusher',
      headers: {'Cookie': cookieHeader},
    ),
    enableLogging: true,
  );

  pusherClient = PusherClient(options: pusherOptions);
  pusherClient?.connect();

  if (userId != -1) {
    bindPrivateChannel(userId, messagesProvider);
  }

  return true;
}

Future<void> bindPrivateChannel(
  int userId,
  MessagesProvider messagesProvider,
) async {
  final cookies = await cookieJar!.loadForRequest(
    Uri.parse('${ApiConfig.baseUrl}/api/auth/pusher'),
  );
  pusherClient?.options.authOptions.headers['Cookie'] = cookies
      .map((c) => '${c.name}=${c.value}')
      .join('; ');
  userChannel = pusherClient?.subscribe('private-user-$userId');
  userChannel?.bind('new-notification', (event) {
    try {
      NotificationData notification = NotificationData.fromJson(event);
      if (notification.type == NotificationType.NEW_MESSAGE) {
        messagesProvider.fetchRefreshMessages();
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  });
}

PusherClient usePusher() {
  if (pusherClient == null) {
    throw StateError('Pusher client not initialized. Call initPusher() first.');
  }
  return pusherClient!;
}
