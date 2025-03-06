// ignore_for_file: file_names

import 'package:flutter/material.dart';

// ignore: camel_case_types
class customCheckBox extends StatelessWidget {
  final String name;
  final Function(bool?) onPressed;
  final bool isPressed;

  const customCheckBox({
    super.key,
    required this.name,
    required this.onPressed,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          fillColor: WidgetStateColor.resolveWith(
              (states) => isPressed ? Colors.red : Colors.transparent),
          side: const BorderSide(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          value: isPressed,
          onChanged: (value) {
            onPressed(value);
          },
        ),
        Text(
          name,
          style: TextStyle(
            color: isPressed ? Colors.red : Colors.black,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
