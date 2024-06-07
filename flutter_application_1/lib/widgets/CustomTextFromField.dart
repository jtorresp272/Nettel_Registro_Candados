// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String text;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.text,
    required this.icon,
    required this.obscureText,
    required this.onChanged,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        color: Colors.black,
      ),
      keyboardType: widget.obscureText
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText ? _obscureText : false,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: getColorAlmostBlue(),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: getColorAlmostBlue()),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white54,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.black38,
        ),
        labelText: widget.text,
        labelStyle: TextStyle(
          color: getColorAlmostBlue(),
        ),
        suffixIconColor: getColorAlmostBlue(),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        prefixIconColor: getColorAlmostBlue(),
        prefixIcon: Icon(widget.icon),
      ),
      onFieldSubmitted: (value) {
        //aqui se puede llamar a la funcion de preguntar si esta valido los campos ingresados
      },
    );
  }
}
