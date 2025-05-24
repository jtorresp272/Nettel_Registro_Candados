// floating_action_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/enums.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialog.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';

class FloatingActionHandler {
  static void handle({
    required BuildContext context,
    required FloatingActions action,
    required void Function(String) onNumberReceived,
  }) {
    switch (action) {
      case FloatingActions.qr:
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => const CustomQrScan(),
        ))
            .then((result) {
          if (result != null) {
            onNumberReceived(result as String);
          }
        });
        break;

      case FloatingActions.write:
        showDialog(
          context: context,
          builder: (context) => CustomAboutDialog(
            title: 'Ingrese número',
            whoIs: 'manual',
            manual: onNumberReceived,
          ),
        );
        break;

      case FloatingActions.historial:
        showDialog(
          context: context,
          builder: (context) => const CustomAboutDialog(
            title: 'Ingrese número candado',
            whoIs: 'taller',
          ),
        );
        break;
    }
  }
}
