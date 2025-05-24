// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Screen/enums.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';

class DialogScanQr extends StatelessWidget {
  final String scannedNumber;
  final String? who;

  const DialogScanQr({super.key, required this.scannedNumber, this.who});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Candado?>(
      future: getDatoCandado(scannedNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(20.0),
              height: 200.0, // Ajusta la altura deseada para el diálogo
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height:
                        60.0, // Ajusta la altura deseada para el CircularProgressIndicator
                    width:
                        60.0, // Ajusta el ancho deseado para el CircularProgressIndicator
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          getColorAlmostBlue()), // Color personalizado para el CircularProgressIndicator
                      strokeWidth:
                          5.0, // Grosor personalizado para el CircularProgressIndicator
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Buscando candado en el servidor...',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Ocurrió un error al buscar el candado, verifique que el número ingresado en el correcto'), //snapshot.error
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: getColorAlmostBlue(),
                  ),
                ),
              ),
            ],
          );
        } else {
          final Candado? scannedCandado = snapshot.data;
          if (scannedCandado != null) {
            return CustomScanResume(
              candado: scannedCandado,
              estado: EstadoCandados.porIngresar,
              whereGo: who ?? 'taller',
            );
          } else {
            return AlertDialog(
              title: const Text('Candado no encontrado'),
              content: const Text(
                  'No se encontraron datos para el candado escaneado.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
        }
      },
    );
  }
}
