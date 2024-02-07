import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CustomElevatedButton createState() => _CustomElevatedButton();
}

class _CustomElevatedButton extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            const Color.fromARGB(255, 68, 91, 164),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          minimumSize: MaterialStateProperty.all(const Size(250, 45))),
      child: Text(
        widget.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
