import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithText.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:logger/logger.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _Historial();
}

class _Historial extends State<Historial> {
  late Map<int, List<CandadoHistorial>> datoHistorial = {};
  late String nameCandado;
  var logger = Logger();
  late String image;
  @override
  void initState() {
    super.initState();
    datoHistorial = getMapHistorial();
    nameCandado = getNameCandadoHistorial();
    _selectImage();
  }

  void _selectImage() {
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
            // Regresar a la pantalla anterior
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  image,
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width * 0.70,
                  height: MediaQuery.of(context).size.height * 0.20,
                ),
              ),
              Center(
                child: Text(
                  nameCandado,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: datoHistorial.length,
                  itemBuilder: (BuildContext context, int index) {
                    final key = datoHistorial.keys.elementAt(index);
                    final candadosHistorial = datoHistorial[key]!;
                    String fechaIngreso = '';
                    String fechaSalida = '';
                    String Lugar = '';
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2,
                          color: getColorAlmostBlue(),
                        ),
                      ),
                      child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: candadosHistorial.map((candadoHistorial) {
                            fechaIngreso =
                                candadoHistorial.fechaIngreso.toString();
                            fechaIngreso = fechaIngreso != 'null'
                                ? fechaIngreso.substring(0, 10)
                                : '';
                            fechaSalida =
                                candadoHistorial.fechaSalida.toString();
                            fechaSalida = fechaSalida != 'null'
                                ? fechaSalida.substring(0, 10)
                                : '';
                            Lugar = candadoHistorial.lugar;
                            Lugar = Lugar.isEmpty
                                ? 'Monitoreo'
                                : ('EVILM').contains(Lugar)
                                    ? 'Taller'
                                    : 'Monitoreo';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _informationBox(
                                    columna1: 'Tipo',
                                    columna2: 'Fecha',
                                    columna3: 'Estado'),
                                const Divider(),
                                _informationBox(
                                    columna1: 'Salida',
                                    columna2: fechaSalida,
                                    columna3: Lugar),
                                const Divider(),
                                _informationBox(
                                    columna1: 'Ingreso',
                                    columna2: fechaIngreso,
                                    columna3: candadoHistorial.lugar),

                                /*
                                if (fechaSalida.isNotEmpty)
                                  RowWithText(
                                      title: 'Fecha Salida',
                                      subtitle: fechaSalida),
                                if (fechaIngreso.isNotEmpty)
                                  RowWithText(
                                      title: 'Fecha Ingreso',
                                      subtitle: fechaIngreso),
                                RowWithText(title: 'Lugar', subtitle: Lugar),
                                */
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Center(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) =>
                                                    getColorAlmostBlue())),
                                    onPressed: () {
                                      // Acción al presionar el botón para más información
                                      // Puedes abrir un diálogo, navegar a otra pantalla, etc.
                                      // Por ejemplo:
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            titlePadding: const EdgeInsets.only(
                                                top: 10.0),
                                            contentPadding:
                                                const EdgeInsets.all(0.0),
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) => Colors.white),
                                            title: Column(
                                              children: [
                                                Text(
                                                  'Más Información',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: getColorAlmostBlue(),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Divider(
                                                  color: getColorAlmostBlue(),
                                                ),
                                              ],
                                            ),
                                            content: _description(
                                                candado: candadoHistorial),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Cerrar',
                                                  style: TextStyle(
                                                      color:
                                                          getColorAlmostBlue()),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Más Información',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}

Row _informationBox({
  required String columna1,
  required String columna2,
  required String columna3,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 70.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          columna1,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(
        height: 40.0,
        child: VerticalDivider(
          width: 1, // Anchura del separador vertical
          color: Colors.grey, // Color del separador vertical
        ),
      ),
      Container(
        width: 90.0,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(
          columna2,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(
        height: 40.0,
        child: VerticalDivider(
          width: 1, // Anchura del separador vertical
          color: Colors.grey, // Color del separador vertical
        ),
      ),
      Container(
        width: 90.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          columna3,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

Container _description({required CandadoHistorial candado}) {
  String estado = candado.lugar;
  final String lugar = estado.isEmpty
      ? 'Monitoreo'
      : ('EVILM').contains(estado)
          ? 'Taller'
          : 'Monitoreo';
  switch (estado) {
    case 'E':
      estado = 'Electronica Dañada';
      break;
    case 'V':
      estado = 'Mecanica Dañada';
      break;
    case 'I':
      estado = 'Ingresado';
      break;
    case 'L':
      estado = 'Candado Listo';
      break;
    case 'M':
      estado = 'Mecanica Lista';
      break;
    case 'OP':
      estado = 'Candado operativo';
      break;
    default:
      estado = '';
      break;
  }
  return Container(
    height: 400.0,
    padding: const EdgeInsets.only(left: 10.0, right: 5.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15.0,
        ),
        if (candado.razonIngreso.isNotEmpty)
          const Text(
            'Descripcion de Ingreso:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (candado.razonIngreso.isNotEmpty) Text(candado.razonIngreso),
        if (candado.razonSalida.isNotEmpty) const Divider(),
        const SizedBox(
          height: 10.0,
        ),
        if (candado.razonSalida.isNotEmpty)
          const Text(
            'Descripcion de Salida:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (candado.razonSalida.isNotEmpty) Text(candado.razonSalida),
        if (candado.responsable.isNotEmpty) const Divider(),
        if (candado.responsable.isNotEmpty)
          const Text(
            'Responsable:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (candado.responsable.isNotEmpty) Text(candado.responsable),
        const Divider(),
        const Text(
          'Lugar:',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(lugar),
        const Divider(),
        const Text(
          'Estado:',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(estado),
      ],
    ),
  );
}
