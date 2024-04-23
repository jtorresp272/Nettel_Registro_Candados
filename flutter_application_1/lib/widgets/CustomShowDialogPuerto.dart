// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';

class CustomAboutDialog extends StatefulWidget {
  const CustomAboutDialog({
    super.key,
  });

  @override
  _CustomAboutDialogState createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Text(
        'Ingrese número',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: getColorAlmostBlue(),
        ),
      ),
      content: TextField(
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: decorationTextField(text: '', hint: '0093'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: TextStyle(color: getColorAlmostBlue()),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => getColorAlmostBlue()),
          ),
          onPressed: () {
            String text = _textController.text;
            if (text.isNotEmpty) {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => DialogScanQr(
                  scannedNumber: text,
                  who: 'puerto',
                ),
              );
            }
          },
          child: const Text(
            'Siguiente',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
