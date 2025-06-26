import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import '../pages/main_page.dart';

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({super.key});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _listenToLinks();
  }

  void _handleUri(Uri uri) {

    switch (uri.host) {
      case 'request':
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/request/${uri.pathSegments.last}');
        });
        break;
      default:
        break;
    }
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleUri(uri);
    } catch (e) {
      debugPrint('Initial link error: $e');
    }
  }

  void _listenToLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage(); // default home page
  }
}
