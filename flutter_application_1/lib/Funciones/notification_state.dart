import 'package:flutter/material.dart';

class NotificationState extends ChangeNotifier {
  bool _hasNotification = false;

  bool get hasNotification => _hasNotification;

  void updateNotification(bool value) {
    _hasNotification = value;
    notifyListeners();
  }
}
