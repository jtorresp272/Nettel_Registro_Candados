import 'dart:math';

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

List<Candado> generarCandadosAleatoriosTaller() {
  List<String> lugares = ['I', 'M', 'L', 'V'];
  List<String> responsables = [
    'Joshue',
    'Jordy',
    'Oliver',
    'Oswaldo',
    'Fabian'
  ];
  List<String> tipos = [
    'CC_Plastico',
    'Tipo_U',
    'Tipo_Cable',
    'Tipo_Piston',
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
    String tipo = tipos[random.nextInt(tipos.length)];
    String image = getImagePath(tipo); // Obtener la ruta de la imagen
    
    Candado nuevoCandadoTaller = Candado(
      numero: numeroCandado,
      razonIngreso: razonIngreso,
      razonSalida: razonSalida,
      responsable: responsable,
      fechaIngreso: fechaIngreso,
      fechaSalida: fechaSalida,
      lugar: lugar,
      tipo: tipo,
      image: image, // Asignar la ruta de la imagen
    );

    listaCandadosTaller.add(nuevoCandadoTaller);
  }

  return listaCandadosTaller;
}

List<Candado> generarCandadosAleatoriosLlegar() {
  List<String> lugares = [
    'Naportec',
    'DPW',
    'Cuenca',
    'Quito',
    'TPG',
    'Inarpi',
    'Manta'
  ];
  List<String> responsables = [
    'Joshue',
    'Jordy',
    'Oliver',
    'Oswaldo',
    'Fabian'
  ];
    List<String> tipos = [
    'CC_Plastico',
    'Tipo_U',
    'Tipo_Cable',
    'Tipo_Piston',
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
    String tipo = tipos[random.nextInt(tipos.length)];
    String image = getImagePath(tipo); // Obtener la ruta de la imagen

    Candado nuevoCandadoLlegar = Candado(
      numero: numeroCandado,
      razonIngreso: razonIngreso,
      razonSalida: razonSalida,
      responsable: responsable,
      fechaIngreso: fechaIngreso,
      fechaSalida: fechaSalida,
      lugar: lugar,
      tipo: tipo,
      image: image, // Asignar la ruta de la imagen
    );

    listaCandadosLlegar.add(nuevoCandadoLlegar);
  }

  return listaCandadosLlegar;
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
