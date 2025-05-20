// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

class CustomAboutDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String? whoIs;
  final Function(String)? manual;
  const CustomAboutDialog({
    super.key,
    required this.title,
    this.hint,
    this.whoIs,
    this.manual,
  });

  @override
  _CustomAboutDialogState createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  final TextEditingController _textController = TextEditingController();
  bool wait = false;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return AlertDialog(
      alignment: Alignment.center,
      surfaceTintColor: getColorAlmostBlue(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: getColorAlmostBlue(),
          width: 0.5,
        ),
      ),
      backgroundColor: customColors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: getColorAlmostBlue(),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
      content: TextField(
        style: TextStyle(
          color: customColors.label,
        ),
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.name,
        decoration: decorationTextField(
            text: 'número Candado',
            hint: widget.hint ?? '0093',
            context: context),
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
        const SizedBox(
          width: 20.0,
        ),
        if (!wait)
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateColor.resolveWith(
                  (states) => getColorAlmostBlue()),
            ),
            onPressed: () async {
              String text = _textController.text;
              if (text.isNotEmpty && text.length > 3) {
                if (widget.whoIs != 'taller' && widget.whoIs != 'manual') {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => DialogScanQr(
                      scannedNumber: text,
                      who: 'puerto',
                    ),
                  );
                } else if (widget.whoIs == 'manual') {
                  Navigator.of(context).pop();
                  widget.manual!(text);
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
                    customSnackBar(context,
                        mensaje:
                            'No se pudo encontrar el número o el número no tiene datos en el historial',
                        colorFondo: Colors.red);
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
