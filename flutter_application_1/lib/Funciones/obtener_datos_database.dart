/* URL para obtener datos de la base de datos */
// https://script.google.com/macros/s/AKfycbwwLA26uBvHLJBzdZ_oJAvbwyx21mEZm7U153PcnTQz8YGzl5JYpZTsAVs43-LmA2yB-w/exec

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Candado {
  final String numero;
  final String tipo;
  final String razonIngreso;
  final String razonSalida;
  final String responsable;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final String lugar;
  final String imageTipo; // Campo para la ruta de la imagen
  final String imageDescripcion;

  Candado({
    required this.numero,
    required this.tipo,
    required this.razonIngreso,
    required this.razonSalida,
    required this.responsable,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.lugar,
    required this.imageTipo, // Incluir el campo de imagen
    required this.imageDescripcion,
  });

  @override
  String toString() {
    return 'Candado{numero: $numero, tipo: $tipo, razonIngreso: $razonIngreso, razonSalida: $razonSalida, responsable: $responsable, fechaIngreso: $fechaIngreso, fechaSalida: $fechaSalida, lugar: $lugar, imageTipo: $imageTipo, imageDescripcion: $imageDescripcion}';
  }
}

String URL =
    "https://script.google.com/macros/s/AKfycbwwLA26uBvHLJBzdZ_oJAvbwyx21mEZm7U153PcnTQz8YGzl5JYpZTsAVs43-LmA2yB-w/exec?accion=ob_data";

final List<Candado> listaCandadosTaller = [];
final List<Candado> listaCandadosPuerto = [];

var logger = Logger();

Future getDataGoogleSheet() async {
  final response = await http.get(Uri.parse(URL));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    for (var item in jsonData) {
      if (['L', 'M', 'I', 'V'].contains(item['lugar'])) {
        DateTime? fechaIngreso = parseDateString(item['Fecha Ingreso']);
        DateTime? fechaSalida = parseDateString(item['Fecha Salida']);
        final Candado candadoTaller = Candado(
          numero: item['Numero'],
          tipo: item['Tipo'],
          razonIngreso: item['Descripcion Ingreso'],
          razonSalida: item['Descripcion Salida'],
          responsable: item['Responsable'],
          fechaIngreso: fechaIngreso!,
          fechaSalida: fechaSalida,
          lugar: item['lugar'],
          imageDescripcion: item['Imagen'],
          imageTipo: getImagePath(
              item['Tipo']), // Obtener la ruta de la imagen según el tipo
        );

        listaCandadosTaller.add(candadoTaller);
      } else if ([
        'DPW',
        'NAPORTEC',
        'OTRO',
        'QUITO',
        'CUENCA',
        'MANTA',
        'TPG',
        'CONTECON'
      ].contains(item['lugar'])) {
        DateTime? fechaIngreso = parseDateString(item['Fecha Ingreso']);
        DateTime? fechaSalida = parseDateString(item['Fecha Salida']);
        final Candado candadoPuerto = Candado(
          numero: item['Numero'],
          tipo: item['Tipo'],
          razonIngreso: item['Descripcion Ingreso'],
          razonSalida: item['Descripcion Salida'],
          responsable: item['Responsable'],
          fechaIngreso: fechaIngreso!,
          fechaSalida: fechaSalida,
          lugar: item['lugar'],
          imageDescripcion: item['Imagen'],
          imageTipo: getImagePath(
              item['Tipo']), // Obtener la ruta de la imagen según el tipo
        );
        listaCandadosPuerto.add(candadoPuerto);
      }
    }
  } else {
    throw Exception('Error al cargar los datos desde Google Sheets');
  }
}

List<Candado> getCandadosTaller() {
  return listaCandadosTaller;
}

List<Candado> getCandadosPuerto() {
  return listaCandadosPuerto;
}

String getImagePath(String tipo) {
  switch (tipo) {
    case 'Tipo_U':
      return 'assets/images/candado_U.png';
    case 'Tipo_Cable':
      return 'assets/images/candado_cable.png';
    case 'Tipo_Piston':
      return 'assets/images/candado_piston.png';
    case 'CC_Plastico':
      return 'assets/images/cc_plastico.png';
    case 'CC_5':
      return 'assets/images/CC_5.png';
    default:
      return 'assets/images/CC_5.png';
  }
}

DateTime? parseDateString(String dateString) {
  // Si la cadena de fecha está vacía, retorna null
  if (dateString.isEmpty) {
    return null;
  }

  // Intenta analizar la fecha en diferentes formatos
  try {
    // Intenta analizar la fecha en formato "dd/MM/yyyy"
    return DateTime.parse(dateString);
  } catch (e) {
    try {
      // Si falla, intenta analizar la fecha en formato ISO8601
      return DateTime.parse(dateString);
    } catch (e) {
      // Si no se puede analizar la fecha, retorna null
      return null;
    }
  }
}
