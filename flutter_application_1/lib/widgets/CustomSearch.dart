// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        focusNode: focusNode,
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Buscar',
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: getColorAlmostBlue()),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: getColorAlmostBlue()),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: getColorAlmostBlue()),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              if (onClear != null) {
                controller.clear();
                onClear!();
              }
            },
            icon: Icon(controller.text.isEmpty ? Icons.search : Icons.close),
            iconSize: 20.0,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
