// candado_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_candado.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Screen/enums.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';

class CandadoActions {
  static void handle({
    required BuildContext context,
    required String numeroCandado,
    String whoIs = 'taller',
  }) {
    String scannedNumber = numeroCandado;

    // Buscar el candado en el cache
    Candado scannedCandado = obtenerDatosCandado(numeroCandado: numeroCandado);

    if (scannedCandado.numero == scannedNumber) {
      EstadoCandados estado;
      switch (scannedCandado.lugar) {
        case 'I':
          estado = EstadoCandados.ingresado;
          break;
        case 'M':
          estado = EstadoCandados.mantenimiento;
          break;
        case 'V':
        case 'E':
          estado = EstadoCandados.danados;
          break;
        case 'L':
          estado = EstadoCandados.listos;
          break;
        default:
          estado = EstadoCandados.porIngresar;
          break;
      }

      if (whoIs == 'taller') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomScanResume(candado: scannedCandado, estado: estado),
          ),
        );
      } else if (whoIs == 'monitoreo') {
        if (scannedCandado.lugar != 'L') {
          customSnackBar(
            context,
            mensaje: 'Candado no se encuentra listo',
            colorFondo: Colors.red,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomScanResume(
                whereGo: whoIs, candado: scannedCandado, estado: estado),
          ),
        );
      }
    } else {
      /*
      if (whoIs == 'monitoreo') {
        customSnackBar(context,
            mensaje: 'Candado no se encuentra en taller',
            colorFondo: Colors.red);
        return;
      }
      */
      showDialog(
        context: context,
        builder: (context) =>
            DialogScanQr(who: 'monitoreo', scannedNumber: scannedNumber),
      );
    }
  }
}
