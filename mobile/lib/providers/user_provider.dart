import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../types/user.dart';
import 'message_provider.dart';

class UserProvider extends ChangeNotifier {
  User? current;

  Future<void> fetchUser() async {
    try {
      final response = await useApi().get('/auth');
      current = User.fromJson(response.data);
      notifyListeners();
    } on DioException catch (e) {
      print('Error fetching user');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await useApi().post('/auth/logout');
    disconnectPusher();
    cookieJar?.deleteAll();
    current = null;
    notifyListeners();
  }

  void fetchFromData(Map<String, dynamic> data) async {
    current = User.fromJson(data);
    notifyListeners();
  }
}
