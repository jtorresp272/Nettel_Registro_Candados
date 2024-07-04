import 'package:flutter/material.dart';

List<String> menu = [
  'claveM',
  'claveA',
  'eKey',
  'secret',
  'iv',
  'proximity',
  'open',
  'time',
  'imei',
  'gps',
  'sensors',
];

class customDrop extends StatefulWidget {
  final ValueChanged<String> selection;
  customDrop({super.key, required this.selection});

  @override
  State<customDrop> createState() => customDropState();
}

class customDropState extends State<customDrop> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = menu.first;

    return SizedBox(
      width: 150.0,
      child: DropdownButtonFormField<String>(
        value: dropdownValue,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
        ),
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        onChanged: (String? value) {
          setState(() {
            dropdownValue = value!;
            widget.selection(value);
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(color: Colors.black54, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(color: Colors.black54, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(color: Colors.black54, width: 1.0),
          ),
        ),
        itemHeight: 48.0,
        isDense: true,
        items: menu.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black, fontSize: 14.0),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
      ),
    );
  }
}
