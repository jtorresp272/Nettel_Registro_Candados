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

class CandadoHistorial {
  final int id;
  final String tipo;
  final String razonIngreso;
  final String razonSalida;
  final String responsable;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final String lugar;

  CandadoHistorial({
    required this.id,
    required this.tipo,
    required this.razonIngreso,
    required this.razonSalida,
    required this.responsable,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.lugar,
  });

  @override
  String toString() {
    return 'id: $id, tipo: $tipo, razonIngreso: $razonIngreso, razonSalida: $razonSalida, responsable: $responsable, fechaIngreso: $fechaIngreso, fechaSalida: $fechaSalida, lugar: $lugar';
  }
}

final List<Candado> listaCandadosTaller = [];
final List<Candado> listaCandadosPuerto = [];
Map<int, List<CandadoHistorial>> mapCandadoHistorial = {};

var logger = Logger();
// Obtener información de un candado en especifico
Future<Candado?> getDatoCandado(String numeroCandado) async {
  const urlBuscar =
      "https://script.google.com/macros/s/AKfycbxojXb67pxCBQCDoGkZuHpsYVqSH4U9JIVlPP4bKHQ37kMlimMUSPRJ_rKjDhGmKkBpGg/exec?accion=buscar&string=";
  final response = await http.get(Uri.parse(urlBuscar + numeroCandado));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData != null && jsonData.isNotEmpty) {
      final item =
          jsonData; // Suponemos que la API devuelve solo un candado con ese número
      DateTime? fechaIngreso = _parseDateString(item['Fecha Ingreso']);
      DateTime? fechaSalida = _parseDateString(item['Fecha Salida']);
      fechaIngreso ??= DateTime.now();
      return Candado(
        numero: item['Numero'],
        tipo: item['Tipo'],
        razonIngreso: item['Descripcion Ingreso'],
        razonSalida: item['Descripcion Salida'],
        responsable: item['Responsable'],
        fechaIngreso: fechaIngreso,
        fechaSalida: fechaSalida,
        lugar: item['lugar'],
        imageDescripcion: item['Imagen'],
        imageTipo: getImagePath(
            item['Tipo']), // Obtener la ruta de la imagen según el tipo
      );
    }
  } else {
    throw Exception(
        'Error al cargar los datos del candado $numeroCandado desde Google Sheets');
  }
  return null; // En caso de no encontrar ningún candado con ese número
}

/* Obtiene informacion del historial y guarda toda la informacion en una variable
 * Retornar un true si el dato se obtuvo 
*/
Future<bool> getDataHistorial({required String numero}) async {
  String url =
      "https://script.google.com/macros/s/AKfycbzzivR2HvtB4SnxEMD_XBzS4LQ_MKg5enddPab4fAu4t_86RQIgCBCUpZ3VI3z8O-1qSw/exec?numero=";

  final response = await http.get(Uri.parse(url + numero));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData != null && jsonData.isNotEmpty) {
      for (var data in jsonData) {
        int id = data["ID"];
        String tipo = data["Tipo"];
        String razonIngreso = data["Descripcion Ingreso"];
        String razonSalida = data["Descripcion Salida"];
        String responsable = data["Responsable"];
        DateTime fechaIngreso = DateTime.parse(data["Fecha Ingreso"]);
        DateTime? fechaSalida = _parseDateString(data['Fecha Salida']);
        String lugar = data["lugar"];
        
        CandadoHistorial candado = CandadoHistorial(
          id: id,
          tipo: tipo,
          razonIngreso: razonIngreso,
          razonSalida: razonSalida,
          responsable: responsable,
          fechaIngreso: fechaIngreso,
          fechaSalida: fechaSalida,
          lugar: lugar,
        );

        if (!mapCandadoHistorial.containsKey(id)) {
          mapCandadoHistorial[id] = [];
        }
        mapCandadoHistorial[id]!.add(candado);
      }
    }
  } else {
    return false;
  }
  return true;
}

/* Retorna los datos almacenados previamente en la funcion getDataHistorial */
Map<int, List<CandadoHistorial>> getMapHistorial() {
  return mapCandadoHistorial;
}

// Retorna todo el listado de la tabla del registro de candados
Future getDataGoogleSheet() async {
  // ignore: non_constant_identifier_names
  String URL =
      "https://script.google.com/macros/s/AKfycbz3nqGJSEI8snxYQtMZkPD1tjFsUmeoCq9kaQizTHOL4IFI9timwnkAtpRZjRf-LFB4LQ/exec?accion=ob_data";
  // Borrar toda la información de los candados
  listaCandadosTaller.clear();
  listaCandadosPuerto.clear();
  final response = await http.get(Uri.parse(URL));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    for (var item in jsonData) {
      if (['L', 'M', 'I', 'V', 'E'].contains(item['lugar'])) {
        DateTime? fechaIngreso = _parseDateString(item['Fecha Ingreso']);
        DateTime? fechaSalida = _parseDateString(item['Fecha Salida']);
        fechaIngreso ??= DateTime.now();
        final Candado candadoTaller = Candado(
          numero: item['Numero'],
          tipo: item['Tipo'],
          razonIngreso: item['Descripcion Ingreso'],
          razonSalida: item['Descripcion Salida'],
          responsable: item['Responsable'],
          fechaIngreso: fechaIngreso,
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
        DateTime? fechaIngreso = _parseDateString(item['Fecha Ingreso']);
        DateTime? fechaSalida = _parseDateString(item['Fecha Salida']);
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

// Retorna un listado de los candados en taller
List<Candado> getCandadosTaller() {
  return listaCandadosTaller;
}

// Retorna un listado de los candados en el puerto
List<Candado> getCandadosPuerto() {
  return listaCandadosPuerto;
}

// Retorna una imagen asignada segun el tipo de candado
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

// Si no existe nada en el campo de fecha retorna un vacio y no  crea conflictos por el formato fecha
DateTime? _parseDateString(String dateString) {
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
