import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();

// Función para escribir en la base de datos, ya se solo en la hoja registro o tambien en la del historial
Future<void> modificarRegistro(String accion, String num, List<String> valores) async {
  // Construir la URL con los parámetros proporcionados
  const baseUrl = 'https://script.google.com/macros/s/AKfycbx6r1dQVpVLTWOmoskl8qpLh9nedxvCvXWU-Gbv8UX9pHeDoy8CBynYPprtyDbxQ02BZg/exec';
  
  // Combinar los componentes de la URL
  Uri url = Uri.parse('$baseUrl?accion=$accion&num=$num&valores=${valores.join(',')}');
  logger.i(url);

  try {
    // Realizar la solicitud HTTP GET
    final response = await http.get(url);
    // Verificar si la respuesta es exitosa
    if (response.statusCode == 200) {
      // Verificar el contenido de la respuesta
      if (response.body == '{"mensaje":"Filas modificadas exitosamente."}') {
        logger.i('Filas modificadas exitosamente.');
      } else {
        logger.i('Error en la respuesta: ${response.body}');
      }
    } else {
      logger.i('Error en la solicitud: ${response.statusCode}');
    }
  } catch (e) {
    logger.i('Error al realizar la solicitud: $e');
  }
}