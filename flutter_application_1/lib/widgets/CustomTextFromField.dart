import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String text;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.text,
    required this.icon,
    required this.obscureText,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.obscureText
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText ? _obscureText : false,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 68, 91, 164),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white54,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.black12,
        ),
        labelText: widget.text,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 68, 91, 164),
        ),
        suffixIconColor: const Color.fromARGB(255, 68, 91, 164),
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
        prefixIconColor: const Color.fromARGB(255, 68, 91, 164),
        prefixIcon: Icon(widget.icon),
      ),
      onFieldSubmitted: (value) {
        //aqui se puede llamar a la funcion de preguntar si esta valido los campos ingresados
      },
    );
  }
}
