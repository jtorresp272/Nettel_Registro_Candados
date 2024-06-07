import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:logger/logger.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _Historial();
}

class _Historial extends State<Historial> {
  late Map<String, List<String>> datoHistorial = {};
  List<String> ingreso = [];
  List<String> salida = [];
  late String nameCandado;
  var logger = Logger();
  late String image;
  int auxId = 0;

  @override
  void initState() {
    super.initState();
    _separateData(getMapHistorial());
    logger.e(getMapHistorial());
    logger.e(datoHistorial);
    nameCandado = getNameCandadoHistorial();
    _selectImage(getMapHistorial());
  }

  void _separateData(Map<int, List<CandadoHistorial>> dato) {
    dato.forEach((id, valores) {
      for (var valores in valores) {
        String fechaIngreso = valores.fechaIngreso != null
            ? valores.fechaIngreso.toString().split(' ')[0]
            : '';
        String fechaSalida = valores.fechaSalida != null
            ? valores.fechaSalida.toString().split(' ')[0]
            : '';
        auxId++;

        if (valores.razonIngreso.isNotEmpty) {
          if (valores.razonSalida.isEmpty) {
            ingreso.add(
                '$auxId,${valores.razonIngreso},$fechaIngreso,${valores.lugar}');
          } else {
            ingreso.add('$auxId,${valores.razonIngreso},$fechaIngreso');
          }
          datoHistorial.addAll({'Ingreso': ingreso});
        }
        if (valores.razonSalida.isNotEmpty) {
          salida.add(
              '$auxId,${valores.razonSalida},$fechaSalida,${valores.lugar}');
          datoHistorial.addAll({'Salida': salida});
        }
      }
    });
  }

  void _selectImage(Map<int, List<CandadoHistorial>> datoHistorial) {
    // Verificar si el mapa contiene la clave 1 (primer ID)
    if (datoHistorial.containsKey(1)) {
      // Obtener la lista de CandadoHistorial asociada al ID 1
      final candadosHistorial = datoHistorial[1]!;

      // Verificar si la lista no está vacía
      if (candadosHistorial.isNotEmpty) {
        // Obtener el primer elemento de la lista (el CandadoHistorial asociado al ID 1)
        final primerCandado = candadosHistorial.first;
        // Obtener el valor del campo "Tipo" del primer CandadoHistorial
        String tipoPrimerCandado = primerCandado.tipo;
        switch (tipoPrimerCandado) {
          case 'Tipo_U':
            image = 'assets/images/candado_U.png';
            break;
          case 'Tipo_Cable':
            image = 'assets/images/candado_cable.png';
            break;
          case 'Tipo_Piston':
            image = 'assets/images/candado_piston.png';
            break;
          case 'CC_Plastico':
          case 'Plastico Naranja':
            image = 'assets/images/cc_plastico.png';
            break;
          case 'CC_5':
            image = 'assets/images/CC_5.png';
            break;
          default:
            image = 'assets/images/CC_5.png';
            break;
        }
      } else {
        image = 'assets/images/CC_5.png';
      }
    } else {
      image = 'assets/images/CC_5.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: getColorAlmostBlue(),
        title: const Text(
          'Historial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Image.asset(
              image,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.8,
              height: 200.0,
            ),
            Text(
              nameCandado,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 20.0,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Tipo',
                      textAlign: TextAlign.center,
                    )),
                    DataColumn(
                        label: Text(
                      'Fecha',
                      textAlign: TextAlign.center,
                    )),
                    DataColumn(
                        label: Text(
                      'Estado',
                      textAlign: TextAlign.center,
                    )),
                    DataColumn(
                        label: Text(
                      'Información',
                      textAlign: TextAlign.center,
                    )),
                  ],
                  rows: _buildRows(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    List<String> ingreso = datoHistorial['Ingreso'] ?? [];
    List<String> salida = datoHistorial['Salida'] ?? [];
    int maxIterations =
        ingreso.length > salida.length ? ingreso.length : salida.length;

    for (int i = 0; i < maxIterations; i++) {
      String ingresoData = i < ingreso.length ? ingreso[i] : '';
      String salidaData = i < salida.length ? salida[i] : '';

      List<String> ingresoValues = ingresoData.split(',');
      List<String> salidaValues = salidaData.split(',');

      rows.add(
        DataRow(
          cells: [
            const DataCell(
              Text(
                'Ingreso',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            DataCell(
              Text(
                ingresoValues.length > 2 ? ingresoValues[2] : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ), // Fecha
            DataCell(Text(
              ingresoValues.length > 3 ? ingresoValues[3] : '-',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
              ),
            )), // Estado
            DataCell(
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColorAlmostBlue(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _showMoreInfo(context, ingresoData);
                      });
                },
                child: const Text(
                  'Ver más',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ), // Acción (puedes ajustar este valor según tu lógica)
          ],
        ),
      );

      if (salidaData.isNotEmpty) {
        rows.add(
          DataRow(
            cells: [
              const DataCell(Text(
                'Salida',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )),
              DataCell(Text(
                salidaValues.length > 2 ? salidaValues[2] : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                ),
              )), // Fecha
              DataCell(
                Text(
                  salidaValues.length > 3 ? salidaValues[3] : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ), // Estado
              DataCell(
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColorAlmostBlue(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _showMoreInfo(context, salidaData);
                        });
                  },
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ), // Acción (puedes ajustar este valor según tu lógica)
            ],
          ),
        );
      }
    }

    return rows;
  }
}

AlertDialog _showMoreInfo(context, String info) {
  // Aquí puedes implementar la lógica para mostrar más información según el tipo de dato que recibas
  // Por ejemplo, puedes abrir un diálogo o una nueva pantalla con los detalles de la información recibida.
  logger.i('Mostrar más información: $info');
  List<String> data = info.split(',');
  return AlertDialog(
    contentPadding: const EdgeInsets.all(20.0),
    title: const Text(
      'Información Detallada',
      textAlign: TextAlign.center,
    ),
    titleTextStyle: TextStyle(
      color: getColorAlmostBlue(),
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    content: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Descripcion:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(data[1]),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              'Fecha:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(data[2]),
            if (data.length > 3)
              const SizedBox(
                height: 20.0,
              ),
            if (data.length > 3)
              const Text(
                'Estado:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (data.length > 3)
              const SizedBox(
                height: 5.0,
              ),
            if (data.length > 3) Text(data[3]),
          ]),
    ),
    actions: [
      ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
              (states) => getColorAlmostBlue(),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cerrar',
            style: TextStyle(color: Colors.white),
          ))
    ],
  );
}
