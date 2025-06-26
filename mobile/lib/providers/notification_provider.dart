import 'package:flutter/material.dart';
import 'package:mobile/stores/client.dart';

import '../types/notification.dart';

class NotificationProvider extends ChangeNotifier {

  List<NotificationData> notifications = [];
  Future<void> fetchNotifications() async{

    final response = await useApi().get('/notification');

    response.data.map((e) => notifications.add(NotificationData.fromJson(e))).toList();

    notifyListeners();
  }
  Future<void> markAsRead(NotificationData notification) async{
    try {
      notification.read = true;
      await useApi().post('/notification/${notification.id}/read');
    } catch (e) {
      print(e);
      notification.read = false;
    }
    notifyListeners();
  }
  Future<void> deleteNotification(NotificationData notification) async{
    try {
      notifications = notifications.where((element) => element.id == notification.id).toList();
      await useApi().delete('/notification/${notification.id}');
    } catch (e) {
      print(e);
      notifications.add(notification);
    }
    notifyListeners();
  }


}
