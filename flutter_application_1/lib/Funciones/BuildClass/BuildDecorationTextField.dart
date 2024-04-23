// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';

/* Decoracion de texto  */
Text decorationText(String texto) {
  return Text(
    texto,
    style: const TextStyle(color: Colors.black),
  );
}

/* Decoracion de un textfromfield */
InputDecoration decorationTextField({required String text, Color? color,String? hint}) {
  return InputDecoration(
    hintText: hint?? '',
    labelText: text,
    labelStyle: TextStyle(color: color ?? getColorAlmostBlue()),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: color ?? getColorAlmostBlue(),
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: color ?? getColorAlmostBlue()),
      borderRadius: BorderRadius.circular(10),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: Colors.white,
  );
}

/* Decoracion de texfromfield con acciones de cambio */
InputDecoration decorationTextFieldwithAction(
    {required String text,
    required bool isEnabled,
    required VoidCallback onPressed}) {
  return InputDecoration(
    labelText: text,
    suffixIcon: IconButton(
      onPressed: onPressed,
      icon: Icon(isEnabled ? Icons.edit_off : Icons.edit),
    ),
    suffixIconColor: getColorAlmostBlue(),
    labelStyle: TextStyle(
      color: getColorAlmostBlue(),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: getColorAlmostBlue(),
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: getColorAlmostBlue(),
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
