// ignore_for_file: use_build_context_synchronously

/* funcion para resetear la pagina Taller */
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/api/google_auth_api.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialogEmail.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

/* Seleccionar los correos donde se debe enviar el correo */
List<String> selectReceiver(String whereIam) {
  Map<String, List<String>> emails = {
    'Taller': [
      'jtorresp272@gmail.com',
      'electronica@nettelcorp.com',
      'pedidos@nettelcorp.com'
    ],
    'Monitoreo': [
      'jtorresp272@gmail.com',
      'electronica@nettelcorp.com',
      'joperaciones@nettelcorp.com',
      'pedidos@nettelcorp.com',
      'rastreo@nettelcorp.com',
      'joseparraga1@outlook.es'
    ],
  };

  return emails[whereIam] ??
      ['electronica@nettelcorp.com', 'pedidos@nettelcorp.com'];
}

/* Chequea si existe un correo para realizar el envio y si no te indica que vuelvas a intentarlo */
Future<bool> checkAndSendEmail(BuildContext context,
    {required String datosFormateados, required String whereSend}) async {
  // registrar el correo de google
  final user = await GoogleAuthApi.signIn();
  if (user == null) {
    await GoogleAuthApi.signOut();
    customSnackBar(context,
        mensaje: 'Intenta otra vez',
        colorFondo: Colors.red,
        colorText: Colors.white);
    return false;
  }

  final email = user.email;
  final auth = await user.authentication;
  final token = auth.accessToken!;

  final smtpServer = gmailSaslXoauth2(email, token);
  final message = Message()
    ..from = Address(email, 'Consorcio Nettel')
    ..recipients = selectReceiver(whereSend)
    ..subject =
        'Listado de candados para ${whereSend == 'Taller' ? 'ingresar a taller' : 'ingresar / retirar de taller'}'
    ..text = datosFormateados;

  try {
    await send(message, smtpServer);
    await deleteData(id: 2, title: 'candados');
    customSnackBar(
      context,
      mensaje: 'Correo enviado existosamente',
      colorText: Colors.white,
    );
    return true;
  } on MailerException catch (e) {
    // Ocurrió un error al enviar el correo
    customSnackBar(
      context,
      mensaje: 'Error al abrir la aplicacion de correos: $e',
      colorFondo: Colors.red,
    );
    return false;
  }
}

Future<void> watchDataBeforeSend(BuildContext context,
    {required String whoIs}) async {
  // Inicia chequeo en la base de datos
  String description = '';
  List<String> datosEnviar = [];
  description = await getDataCandados('candados');
  if (description.isNotEmpty) {
    datosEnviar = description.split(',');
  }

  if (datosEnviar.isEmpty) {
    customSnackBar(
      context,
      mensaje: 'No hay candados por enviar',
      colorFondo: Colors.red,
      colorText: Colors.white,
    );
    return;
  }
  // Formatear los datos como texto plano
  String datosFormateados = '';
  for (int i = 0; i < datosEnviar.length; i++) {
    datosFormateados += '${datosEnviar[i]}\n';
  }

  showDialog(
    context: context,
    builder: (context) => CustomAboutDialogEmail(
      datos: datosFormateados,
      callback: () async {
        bool isSend = await checkAndSendEmail(
          context,
          datosFormateados: datosFormateados,
          whereSend: whoIs,
        );
        if (isSend) {
          updateIconAppBar().triggerNotification(context, false);
          Navigator.of(context).pop();
        }
      },
    ),
  );
}
