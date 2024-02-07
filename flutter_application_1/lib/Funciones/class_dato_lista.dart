import 'dart:math';

class Candado {
  final String numero;
  final String razonIngreso;
  final String razonSalida;
  final String responsable;
  final DateTime fechaIngreso;
  final DateTime fechaSalida;
  final String lugar;

  Candado({
    required this.numero,
    required this.razonIngreso,
    required this.razonSalida,
    required this.responsable,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.lugar,
  });
}

List<Candado> generarCandadosAleatoriosTaller() {
  List<String> lugares = ['I', 'M', 'L', 'V'];
  List<String> responsables = [
    'Joshue',
    'Jordy',
    'Oliver',
    'Oswaldo',
    'Fabian'
  ];
  Random random = Random();

  List<Candado> listaCandadosTaller = [];

  for (int i = 0; i < 50; i++) {
    String numeroCandado =
        (93 + random.nextInt(85638 - 93 + 1)).toString().padLeft(4, '0');
    String razonIngreso = 'Razon de ingreso ${random.nextInt(100)}';
    String razonSalida = 'Razon de salida ${random.nextInt(100)}';
    String responsable = responsables[random.nextInt(responsables.length)];
    DateTime fechaIngreso = DateTime(2023 + random.nextInt(2),
        random.nextInt(12) + 1, random.nextInt(28) + 1);
    DateTime fechaSalida = DateTime(2023 + random.nextInt(2),
        random.nextInt(12) + 1, random.nextInt(28) + 1);
    String lugar = lugares[random.nextInt(lugares.length)];

    Candado nuevoCandadoTaller = Candado(
      numero: numeroCandado,
      razonIngreso: razonIngreso,
      razonSalida: razonSalida,
      responsable: responsable,
      fechaIngreso: fechaIngreso,
      fechaSalida: fechaSalida,
      lugar: lugar,
    );

    listaCandadosTaller.add(nuevoCandadoTaller);
  }

  return listaCandadosTaller;
}

List<Candado> generarCandadosAleatoriosLlegar() {
  List<String> lugares = [
    'NAPORTEC',
    'DPW',
    'CUENCA',
    'QUITO',
    'TPG',
    'INARPI',
    'MANTA'
  ];
  List<String> responsables = [
    'Joshue',
    'Jordy',
    'Oliver',
    'Oswaldo',
    'Fabian'
  ];
  Random random = Random();

  List<Candado> listaCandadosLlegar = [];

  for (int i = 0; i < 30; i++) {
    String numeroCandado =
        (93 + random.nextInt(85638 - 93 + 1)).toString().padLeft(4, '0');
    String razonIngreso = 'Razon de ingreso ${random.nextInt(100)}';
    String razonSalida = 'Razon de salida ${random.nextInt(100)}';
    String responsable = responsables[random.nextInt(responsables.length)];
    DateTime fechaIngreso = DateTime(2023 + random.nextInt(2),
        random.nextInt(12) + 1, random.nextInt(28) + 1);
    DateTime fechaSalida = DateTime(2023 + random.nextInt(2),
        random.nextInt(12) + 1, random.nextInt(28) + 1);
    String lugar = lugares[random.nextInt(lugares.length)];

    Candado nuevoCandadoLlegar = Candado(
      numero: numeroCandado,
      razonIngreso: razonIngreso,
      razonSalida: razonSalida,
      responsable: responsable,
      fechaIngreso: fechaIngreso,
      fechaSalida: fechaSalida,
      lugar: lugar,
    );

    listaCandadosLlegar.add(nuevoCandadoLlegar);
  }

  return listaCandadosLlegar;
}
