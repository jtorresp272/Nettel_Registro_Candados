// ignore_for_file: file_names

import 'package:flutter/material.dart';

void customSnackBar(BuildContext context, String mensaje, Color colorFondo) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: colorFondo,
      duration: const Duration(seconds: 2),
    ),
  );
}
