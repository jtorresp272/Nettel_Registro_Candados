import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:provider/provider.dart';

class updateIconAppBar {
  void triggerNotification(BuildContext context, bool value) {
    final notificationState =
        Provider.of<NotificationState>(context, listen: false);
    notificationState.updateNotification(value);
  }
}
