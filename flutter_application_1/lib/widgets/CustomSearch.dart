import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const CustomSearchField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 5.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Buscar',
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder:const  OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder:const  OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
