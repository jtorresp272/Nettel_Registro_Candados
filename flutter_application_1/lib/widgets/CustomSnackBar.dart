// ignore_for_file: file_names

import 'package:flutter/material.dart';

void customSnackBar(BuildContext context,
    {required String mensaje, Color? colorFondo, Color? colorText}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje,
        style: TextStyle(color: colorText ?? Colors.white),
      ),
      backgroundColor: colorFondo ?? Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
