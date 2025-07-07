import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/stores/pusher.dart';
import '../types/user.dart';

class UserProvider extends ChangeNotifier {
  User? current;
  List<UserSession>? sessions;

  Future<void> fetchUser() async {
    try {
      final response = await useApi().get('/auth');
      current = User.fromJson(response.data);
    } on DioException {
      // ignore
    }
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    try {
      final response = await useApi().get('/auth/sessions');
      sessions = (response.data as List)
          .map((e) => UserSession.fromJson(e))
          .toList();
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
