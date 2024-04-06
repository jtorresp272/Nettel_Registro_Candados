
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';

class customCheckBox extends StatelessWidget{
  final String name;
  final Function(bool?) onPressed;
  final bool isPressed;

  const customCheckBox({
    Key? key,
    required this.name,
    required this.onPressed,
    required this.isPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
        fillColor:MaterialStateColor.resolveWith((states) => isPressed ?  Colors.red:Colors.transparent),
        side: const BorderSide(
          color: Colors.black,
          width: 2.0,
          style: BorderStyle.solid,
        ),
        value: isPressed, 
        onChanged: (value){
          onPressed(value);
        },
        ),
        Text(
          name,
          style: TextStyle(
            color: isPressed ? Colors.red:Colors.black,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
