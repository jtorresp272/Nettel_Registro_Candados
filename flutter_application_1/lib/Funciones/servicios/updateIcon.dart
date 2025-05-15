// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/notification_state.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class updateIconAppBar {
  void triggerNotification(BuildContext context, bool value) {
    final notificationState =
        Provider.of<NotificationState>(context, listen: false);
    notificationState.updateNotification(value);
  }
}
