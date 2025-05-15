import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: label,
      tooltip: label,
      onPressed: onPressed,
      mini: true, // Tamaño reducido
      backgroundColor: Colors.white,
      elevation: 0.0,
      shape: CircleBorder(
        side: BorderSide(
          color: getColorAlmostBlue(),
        ),
      ), // 🔵 Forma circular explícita
      child: Icon(
        icon,
        color: getColorAlmostBlue(),
      ),
    );
  }
}
