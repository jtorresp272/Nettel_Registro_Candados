import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();

// Función para escribir en la base de datos, ya se solo en la hoja registro o tambien en la del historial
Future<bool> modificarRegistro(
    String accion, String num, List<String> valores) async {
  const baseUrl =
      'https://script.google.com/macros/s/AKfycbzmePQJ3BkTkJ2SZrUbV0RSbS4gXp3fn9UFKVHSALFwx10aHMw20pnYB4doHKNoYxTtxg/exec';
      
  // Construir la URL con los parámetros proporcionados
  bool state;
  // Combinar los componentes de la URL
  Uri url = Uri.parse(
      '$baseUrl?accion=$accion&num=$num&valores=${valores.join(',')}');
  try {
    // Realizar la solicitud HTTP GET
    final response = await http.get(url);
    // Verificar si la respuesta es exitosa
    if (response.statusCode == 200) {
      // Verificar el contenido de la respuesta
      if (response.body == '{"mensaje":"Filas modificadas exitosamente."}') {
        logger.i('Filas modificadas exitosamente.');
        state = true;
      } else if (response.body ==
          '{"mensaje":"Fila modificada y agregada correctamente."}') {
        logger.i('Fila agregada y modificada exitosamente.');
        state = true;
      } else {
        logger.i('Error en la respuesta: ${response.body}');
        state = false;
      }
    } else {
      logger.i('Error en la solicitud: ${response.statusCode}');
      state = false;
    }
  } catch (e) {
    logger.i('Error al realizar la solicitud: $e');
    state = false;
  }

  return state;
}
//ejemplo de como pasarle informacion a al request
//?accion=agregarRegistroHistorial&num=0093&valores=0093,CC5,esto,es,una,prueba,de,datos