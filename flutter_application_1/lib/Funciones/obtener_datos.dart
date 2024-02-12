// En el directorio otro_directorio/funciones.dart

import 'package:flutter_application_1/Funciones/class_dato_lista.dart';

Map<String, int> obtenerDatosTaller(List<Candado> listaTaller) {
  // Lógica para procesar la lista de taller y obtener los datos requeridos
  // Devuelve un mapa con los datos procesados
  int candadosOperativos = 0;
  int mecanicasListas = 0;
  int candadosIngresados = 0;
  int mecanicasDanadas = 0;
  int totalCandados = 0;
  // Iterar sobre la lista de candados del taller y contar los elementos de cada tipo
  for (var candado in listaTaller) {
    switch (candado.lugar) {
      case 'L':
        candadosOperativos++;
        break;
      case 'M':
        mecanicasListas++;
        break;
      case 'I':
        candadosIngresados++;
        break;
      case 'V':
        mecanicasDanadas++;
        break;
      default:
        break;
    }
  }

  totalCandados = candadosOperativos+candadosIngresados+mecanicasListas+mecanicasDanadas;
  // Retornar un mapa con los datos contados
  return {
    'Candados Operativos': candadosOperativos,
    'Mecanicas Listas': mecanicasListas,
    'Candados Ingresados': candadosIngresados,
    'Mecanicas Dañadas': mecanicasDanadas,
    'Total mecanicas en taller': totalCandados,
  };
}
