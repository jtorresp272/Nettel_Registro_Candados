import 'package:flutter/material.dart';

class RowWithText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  const RowWithText({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color tilColor = titleColor ?? Colors.black;
    final Color subColor = subtitleColor ?? Colors.black;
    return Row(
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            color: tilColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: subColor),
        )
      ],
    );
  }
}
