// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/contar_datos.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';

double widthScreen = 0.0;
Map<String, int> datosTaller = {};

class CustomResumen extends StatelessWidget {
  final List<Candado> listaTaller;
  final List<Candado> listaLlegar;

  const CustomResumen({
    required this.listaTaller,
    required this.listaLlegar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    datosTaller = contarDatosTaller(listaTaller);
    //logger.i("Cantidad por llegar: $listaLlegar");
    // Lógica para obtener los datos de llegada si es necesario
    widthScreen = MediaQuery.of(context).size.width;
    // Aquí puedes usar los datos obtenidos para construir la interfaz de usuario
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(
            10.0), //EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height*0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CustomContainer(
                razon: 'Candados Operativos',
                dato: datosTaller['Candados Operativos']),
            _CustomContainer(
                razon: 'Mecanicas Listas',
                dato: datosTaller['Mecanicas Listas']),
            _CustomContainer(
                razon: 'Candados Ingresados',
                dato: datosTaller['Candados Ingresados']),
            _CustomContainer(
                razon: 'Mecanicas Dañadas',
                dato: datosTaller['Mecanicas Dañadas']),
            _CustomContainer(
                razon: 'Electronicas Dañadas',
                dato: datosTaller['Electronicas Dañadas']),
            _CustomContainer(
                razon: 'Total electronicas en taller',
                dato: datosTaller['Total electronicas en taller']),
            _CustomContainer(
                razon: 'Total candados por llegar', dato: listaLlegar.length),
          ],
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget _CustomContainer({String? razon, int? dato}) {
  Color fillContainer;
  switch (razon) {
    case 'Candados Operativos':
      fillContainer = Colors.green;
      break;
    case 'Candados Ingresados':
      fillContainer = Colors.blue;
      break;
    case 'Mecanicas Listas':
      fillContainer = Colors.yellow;
      break;
    case 'Mecanicas Dañadas':
      fillContainer = Colors.orange;
      break;
    case 'Electronicas Dañadas':
      fillContainer = Colors.red;
      break;
    case 'Total electronicas en taller':
      fillContainer = Colors.grey;
      break;
    case 'Total candados por llegar':
      fillContainer = Colors.grey;
      break;
    default:
      fillContainer = Colors.grey;
      break;
  }

  return Container(
    decoration: BoxDecoration(
        border: Border.all(
          color: getColorAlmostBlue(),
        ),
        borderRadius: BorderRadius.circular(10.0)),
    margin: const EdgeInsets.all(5.0),
    padding: const EdgeInsets.all(10.0),
    alignment: Alignment.center,
    child: Row(
      children: [
        Container(
          alignment: Alignment.center,
          width: 75, // Ajusta el ancho según tus necesidades
          height: 75, // Ajusta la altura según tus necesidades
          decoration: BoxDecoration(
            color: fillContainer, // Cambia el color según tus necesidades
            borderRadius: BorderRadius.circular(
                10.0), // Mitad del ancho o altura para bordes redondeados completos
          ),
          child: Text(
            '${(dato != null) ? dato : 0}',
            style: const TextStyle(
              fontSize: 30.0, // Tamaño de fuente del texto
              fontWeight: FontWeight.bold, // Peso de fuente en negrita
              color: Colors.white, // Color del texto
            ),
          ),
        ),
        const SizedBox(width: 16.0), // Espacio entre los dos contenedores
        // Contenedor derecho con el texto alineado a la derecha
        Expanded(
            child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  '$razon',
                  style: TextStyle(
                    fontSize: 15.0, // Tamaño de fuente del texto
                    fontWeight: FontWeight.bold, // Peso de fuente en negrita
                    color: getColorAlmostBlue(), // Color del texto
                  ),
                ))),
      ],
    ),
  );
}
