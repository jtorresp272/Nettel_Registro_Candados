import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';

Candado obtenerDatosCandado({required String numeroCandado}) {
  // Buscar en la lista local de Taller
  Candado scannedCandado = getCandadosTaller().firstWhere(
    (e) => e.numero.contains(
      numeroCandado,
    ),
    orElse: () => Candado(
      numero: '',
      tipo: '',
      razonIngreso: '',
      razonSalida: '',
      responsable: '',
      fechaIngreso: DateTime.now(),
      fechaSalida: null,
      lugar: '',
      imageTipo: '',
      imageDescripcion: '',
    ), // Valor predeterminado
  );

  // Si no se encontró en la lista de Taller, buscar en la lista Por Llegar
  if (scannedCandado.numero != numeroCandado) {
    scannedCandado = getCandadosPuerto().firstWhere(
      (e) => e.numero.contains(
        numeroCandado,
      ),
      orElse: () => Candado(
        numero: '',
        tipo: '',
        razonIngreso: '',
        razonSalida: '',
        responsable: '',
        fechaIngreso: DateTime.now(),
        fechaSalida: null,
        lugar: '',
        imageTipo: '',
        imageDescripcion: '',
      ), // Valor predeterminado
    );
  }

  return scannedCandado;
}
