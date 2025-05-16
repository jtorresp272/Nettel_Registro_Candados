// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      children: [
        Checkbox(
          fillColor: WidgetStateColor.resolveWith(
              (states) => isPressed ? Colors.red : customColors.label!),
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
            color: isPressed ? Colors.red : customColors.label,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
