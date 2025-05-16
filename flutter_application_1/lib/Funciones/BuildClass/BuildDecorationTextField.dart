// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

/* Decoracion de texto  */
Text decorationText(String texto) {
  return Text(
    texto,
    style: const TextStyle(color: Colors.black),
  );
}

/* Decoracion de un textfromfield */
InputDecoration decorationTextField(
    {required String text,
    required BuildContext context,
    Color? color,
    String? hint}) {
  // Variable para el color dependiendo del tema
  final customColors = Theme.of(context).extension<CustomColors>()!;
  return InputDecoration(
    hintText: hint ?? '',
    hintStyle: TextStyle(color: customColors.label),
    labelText: text,
    labelStyle: TextStyle(color: customColors.label),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: customColors.label!,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: customColors.label!),
      borderRadius: BorderRadius.circular(10),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: Colors.white54,
  );
}

/* Decoracion de texfromfield con acciones de cambio */
InputDecoration decorationTextFieldwithAction(
    {required String text,
    required bool isEnabled,
    required BuildContext context,
    required VoidCallback onPressed}) {
  // Variable para el color dependiendo del tema
  final customColors = Theme.of(context).extension<CustomColors>()!;
  return InputDecoration(
    labelText: text,
    suffixIcon: IconButton(
      onPressed: onPressed,
      icon: Icon(isEnabled ? Icons.edit_off : Icons.edit),
    ),
    suffixIconColor: customColors.icons,
    labelStyle: TextStyle(
      color: customColors.label,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: customColors.label!,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: customColors.label!,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: Colors.white54,
  );
}
