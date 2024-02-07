import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

Future<bool> validarCredenciales(String usuario, String pass) async {
  var logger = Logger();
  bool credencialesValidas = false;

  // URL para obtener datos del usuario dependiendo si es correcto el usuario o no
  String url =
      'https://script.google.com/macros/s/AKfycbybcacTddMlmtWAJVsAGLjTihjXVq4bgVtoJkUC0gXRb7YEjUDSH7HV0B0F2GUAt7tmTw/exec';

  try {
    var response =
        await http.get(Uri.parse('$url?accion=cuenta&user=$usuario'));

    if (response.statusCode == 200) {
      // Parsear la respuesta JSON
      var jsonResponse = json.decode(response.body);

      // Manejar la respuesta del servidor
      if (jsonResponse.containsKey('error')) {
        // Hubo un error al procesar la solicitud
        logger.i('Error: ${jsonResponse['error']}');
      } else {
        // Los datos son válidos, puedes proceder
        logger.i('Datos válidos: $jsonResponse');

        final String jsonResponsePass = jsonResponse['Contraseña'];
        if (pass == jsonResponsePass) {
          credencialesValidas = true;
        }
      }
    } else {
      // La solicitud no fue exitosa
      logger.i('Error: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Manejar cualquier excepción que ocurra durante la solicitud
    logger.i('Error: $e');
  }
  return credencialesValidas;
}
