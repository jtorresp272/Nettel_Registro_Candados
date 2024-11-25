// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomDialog.dart';
import '../Funciones/get_color.dart';
import 'package:intl/intl.dart';

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
          final index = entry.key;
          final lugar = entry.value;
          if (candadosPorLugar.containsKey(lugar) &&
              candadosPorLugar[lugar]!.isNotEmpty) {
            Color colorContenedor = Colors.grey;
            late final String titulo;
            if (widget.whereFrom == "Taller") {
              switch (lugar) {
                case 'I':
                  colorContenedor = Colors.blueAccent;
                  titulo = 'Candados Ingresados';
                  break;
                case 'M':
                  colorContenedor = Colors.yellow;
                  titulo = 'Mecanicas Listas';
                  break;
                case 'L':
                  colorContenedor = Colors.green;
                  titulo = 'Candados Operativos';
                  break;
                case 'V':
                  colorContenedor = Colors.orange;
                  titulo = 'Mecanicas Dañadas';
                  break;
                case 'E':
                  colorContenedor = Colors.red;
                  titulo = 'Electronicas Dañadas';
                  break;
                default:
                  colorContenedor = Colors.grey;
                  titulo = 'Candados Ingresados';
                  break;
              }
            } else if (widget.whereFrom == 'Llegar') {
              colorContenedor = Colors.grey;
              titulo = lugar;
            }

            final isExpanded = widget.expandedState[index] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isExpanded ? colorContenedor : getColorAlmostBlue(),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          widget.onExpandedChanged?.call(index);
                        },
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    ],
                  ),
                ),
                isExpanded ? const SizedBox() : const SizedBox(height: 8.0),
                isExpanded
                    ? Container(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        margin: const EdgeInsets.only(bottom: 10.0),
                        height: 140.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: candadosPorLugar[lugar]!.length,
                          itemBuilder: (BuildContext context, int index) {
                            Candado candadoPress = candadosPorLugar[lugar]![
                                index]; // Accede al candado específico en esta posición
                            return GestureDetector(
                              onTap: () {
                                _showCandadoDialog(context, candadoPress,
                                    widget.whereFrom, user);
                              },
                              child: Container(
                                width: 120.0,
                                margin: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, bottom: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  /*
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                          colorContenedor
                                        ]),
                                        */
                                  border: Border.all(
                                    color: colorContenedor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      candadosPorLugar[lugar]![index].imageTipo,
                                      fit: BoxFit.contain,
                                      height: 70.0,
                                    ),
                                    Text(
                                      candadosPorLugar[lugar]![index].numero,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(
                                        candadosPorLugar[lugar]![index]
                                            .fechaIngreso,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
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
    showDialog(
      context: context,
      builder: (context) =>
          CustomCandadoDialog(candado: candado, where: where, user: user0),
    );
  }
}
