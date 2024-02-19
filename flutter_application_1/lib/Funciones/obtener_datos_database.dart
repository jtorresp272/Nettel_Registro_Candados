/* URL para obtener datos de la base de datos */
// https://script.google.com/macros/s/AKfycbwwLA26uBvHLJBzdZ_oJAvbwyx21mEZm7U153PcnTQz8YGzl5JYpZTsAVs43-LmA2yB-w/exec

import 'dart:convert';
import 'package:http/http.dart' as http;

String URL =
    "https://script.google.com/macros/s/AKfycbwwLA26uBvHLJBzdZ_oJAvbwyx21mEZm7U153PcnTQz8YGzl5JYpZTsAVs43-LmA2yB-w/exec?accion=ob_data";

class Candado {
  final String numero;
  final String tipo;
  final String razonIngreso;
  final String razonSalida;
  final String responsable;
  final DateTime fechaIngreso;
  final DateTime fechaSalida;
  final String lugar;
  final String image; // Campo para la ruta de la imagen

  Candado({
    required this.numero,
    required this.tipo,
    required this.razonIngreso,
    required this.razonSalida,
    required this.responsable,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.lugar,
    required this.image, // Incluir el campo de imagen
  });
}

Future<List<Candado>> obtenerDatosDesdeGoogleSheet() async {
  final response = await http.get(Uri.parse(URL));

  if (response.statusCode == 200) {
    final List<Candado> listaCandados = [];
    final jsonData = json.decode(response.body);

    for (var item in jsonData['items']) {
      final Candado candado = Candado(
        numero: item['Numero'],
        tipo: item['Tipo'],
        razonIngreso: item['Descripcion Ingreso'],
        razonSalida: item['Descripcion Salida'],
        responsable: item['Responsable'],
        fechaIngreso: DateTime.parse(item['Fecha Ingreso']),
        fechaSalida: DateTime.parse(item['Fecha Salida']),
        lugar: item['Lugar'],
        image: getImagePath(
            item['Tipo']), // Obtener la ruta de la imagen según el tipo
      );

      listaCandados.add(candado);
    }

    return listaCandados;
  } else {
    throw Exception('Error al cargar los datos desde Google Sheets');
  }
}

List<Candado> filtrarCandadosPorLugar(List<Candado> candados, String lugar) {
  return candados.where((candado) => candado.lugar == lugar).toList();
}

List<Candado> filtrarCandadosPorOtrosNombres(
    List<Candado> candados, String nombre) {
  return candados.where((candado) => candado.lugar == nombre).toList();
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
    default:
      return 'assets/images/cc_plastico.png';
  }
}
