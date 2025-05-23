// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomDialog.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

//import 'package:flutter_application_1/Funciones/class_dato_lista.dart';
class CustomListViewBuilder extends StatefulWidget {
  final String whereFrom;
  final String? user;
  final List<Candado> listaFiltrada;
  final Map<int, bool> expandedState;
  final ValueChanged<int>? onExpandedChanged;

  const CustomListViewBuilder({
    super.key,
    required this.whereFrom,
    this.user,
    required this.listaFiltrada,
    required this.expandedState,
    this.onExpandedChanged,
  });

  @override
  State<CustomListViewBuilder> createState() => _CustomListViewBuilderState();
}

class _CustomListViewBuilderState extends State<CustomListViewBuilder> {
  @override
  Widget build(BuildContext context) {
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // Obtener el usuario que vera el customListView
    final user = widget.user ?? 'taller';
    Map<String, List<Candado>> candadosPorLugar = {};
    for (var candado in widget.listaFiltrada) {
      candadosPorLugar.putIfAbsent(candado.lugar, () => []);
      candadosPorLugar[candado.lugar]!.add(candado);
    }

    List<String> lugares = widget.whereFrom == "Taller"
        ? ['L', 'M', 'I', 'V', 'E']
        : [
            'NAPORTEC',
            'DPW',
            'CUENCA',
            'QUITO',
            'TPG',
            'CONTECON',
            'MANTA',
            'OTRO'
          ];
    return Expanded(
      child: ListView(
        children: lugares.asMap().entries.map((entry) {
          final lugar = entry.value;

          if (candadosPorLugar.containsKey(lugar) &&
              candadosPorLugar[lugar]!.isNotEmpty) {
            late final String titulo;

            if (widget.whereFrom == "Taller") {
              switch (lugar) {
                case 'I':
                  titulo = 'Ingresados';
                  break;
                case 'M':
                  titulo = 'Mecánicas Listas';
                  break;
                case 'L':
                  titulo = 'Operativos';
                  break;
                case 'V':
                  titulo = 'Mecánicas Dañadas';
                  break;
                case 'E':
                  titulo = 'Electrónicas Dañadas';
                  break;
                default:
                  titulo = 'Otros';
                  break;
              }
            } else if (widget.whereFrom == 'Llegar') {
              titulo = lugar;
            }

            final columnasDeCandados =
                agruparEnColumnas(candadosPorLugar[lugar]!, 3);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titulo de la sección
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '$titulo (${candadosPorLugar[lugar]!.length})',
                    style: TextStyle(
                      color: customColors.label,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: columnasDeCandados.length,
                    itemBuilder: (BuildContext context, int colIndex) {
                      final columna = columnasDeCandados[colIndex];
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: columna.map((candadoPress) {
                            return GestureDetector(
                              onTap: () {
                                _showCandadoDialog(context, candadoPress,
                                    widget.whereFrom, user);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      candadoPress.imageTipo,
                                      fit: BoxFit.contain,
                                      height: 75.0,
                                      width: 75.0,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candadoPress.numero,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: customColors.label,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('yyyy-MM-dd').format(
                                              candadoPress.fechaIngreso),
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: customColors.label,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            (titulo == 'Mecánicas Listas' ||
                                                    titulo == 'Operativos')
                                                ? candadoPress.razonSalida
                                                : candadoPress.razonIngreso,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: customColors.label,
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5.0),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                if (titulo != 'Electrónicas Dañadas')
                  Divider(
                    color: customColors.icons,
                    height: 1.0,
                  ),
                if (titulo != 'Electrónicas Dañadas')
                  const SizedBox(height: 20.0),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }).toList(),
      ),
    );
  }

  void _showCandadoDialog(
      BuildContext context, Candado candado, String where, String? user) {
    final user0 = user ?? 'taller';
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CustomCandadoDialog(candado: candado, where: where, user: user0),
        ));
  }
}

List<List<Candado>> agruparEnColumnas(
    List<Candado> lista, int cantidadPorColumna) {
  List<List<Candado>> columnas = [];
  for (int i = 0; i < lista.length; i += cantidadPorColumna) {
    int fin = (i + cantidadPorColumna < lista.length)
        ? i + cantidadPorColumna
        : lista.length;
    columnas.add(lista.sublist(i, fin));
  }
  return columnas;
}
