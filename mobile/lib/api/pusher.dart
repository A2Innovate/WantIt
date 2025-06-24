import 'package:pusher_client_socket/pusher_client_socket.dart';
import 'package:mobile/api/client.dart'; // for cookieJar
import 'dart:io';

late PusherClient pusherClient;

Future<void> initPusher() async {
  // Load cookies for the auth URL
  final cookies = await cookieJar!.loadForRequest(
    Uri.parse('http://10.0.2.2:8000/api/auth/pusher'),
  );

  // Build cookie header string "name=value; name2=value2"
  final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

  final pusherOptions = PusherOptions(
    key: 'app-key',
    host: '10.0.2.2',
    wsPort: 6001,
    wssPort: 6001,
    encrypted: false,
    authOptions: PusherAuthOptions(
      'http://10.0.2.2:8000/api/auth/pusher',
      headers: {'Cookie': cookieHeader},
    ),
    enableLogging: true,
  );

  pusherClient = PusherClient(options: pusherOptions);
  pusherClient.connect();
}

PusherClient usePusher() {
  return pusherClient;
}
