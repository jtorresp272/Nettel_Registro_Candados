import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationState extends ChangeNotifier {
  bool _hasNotification = false;

  bool get hasNotification => _hasNotification;

  void updateNotification(bool value) {
    _hasNotification = value;
    notifyListeners();
  }
}
