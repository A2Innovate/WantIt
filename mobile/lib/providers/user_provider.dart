import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import '../types/user.dart';

class UserProvider extends ChangeNotifier {
  User? current;

  Future<void> fetchUser() async {
    try {
      final response = await useApi().get('/auth');
      current = User.fromJson(response.data);
    } on DioException {
      // ignore
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

  void fetchFromData(Map<String, dynamic> data) {
    current = User.fromJson(data);
    notifyListeners();
  }
}
