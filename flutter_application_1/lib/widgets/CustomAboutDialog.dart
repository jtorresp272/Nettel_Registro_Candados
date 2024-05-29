// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';

class CustomAboutDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String? whoIs;
  const CustomAboutDialog({
    super.key,
    required this.title,
    this.hint,
    this.whoIs,
  });

  @override
  _CustomAboutDialogState createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  TextEditingController _textController = TextEditingController();
  bool wait = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: getColorAlmostBlue(),
        ),
      ),
      content: TextField(
        style: const TextStyle(
          color: Colors.black,
        ),
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.name,
        decoration: decorationTextField(
            text: 'número Candado', hint: widget.hint ?? '0093'),
      ),
      actions: [
        if (!wait)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: getColorAlmostBlue()),
            ),
          ),
        if (!wait)
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => getColorAlmostBlue()),
            ),
            onPressed: () async {
              String text = _textController.text;
              if (text.isNotEmpty && text.length > 3) {
                if (widget.whoIs != 'taller') {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => DialogScanQr(
                      scannedNumber: text,
                      who: 'puerto',
                    ),
                  );
                } else {
                  setState(() {
                    wait = true;
                  });
                  final bool isData =
                      await getDataHistorial(numero: text.toUpperCase());

                  setState(() {
                    wait = false;
                  });

                  Navigator.of(context).pop();
                  if (isData) {
                    Navigator.of(context).pushNamed('/historial');
                  } else {
                    customSnackBar(
                        context,
                        'No se pudo encontrar el número o el número no tiene datos en el historial',
                        Colors.red);
                  }
                }
              }
            },
            child: const Text(
              'Siguiente',
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (wait)
          CircularProgressIndicator(
            strokeWidth: 4,
            color: getBackgroundColor(),
            backgroundColor: getColorAlmostBlue(),
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
