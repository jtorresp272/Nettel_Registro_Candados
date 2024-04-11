import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomDialog.dart';
import '../Funciones/get_color.dart';
import 'package:intl/intl.dart';

//import 'package:flutter_application_1/Funciones/class_dato_lista.dart';
class CustomListViewBuilder extends StatefulWidget {
  final String whereFrom;
  final List<Candado> listaFiltrada;
  final Map<int, bool> expandedState;
  final ValueChanged<int>? onExpandedChanged;

  const CustomListViewBuilder({
    super.key,
    required this.whereFrom,
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
                  colorContenedor = Colors.orange;
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
                  colorContenedor = Colors.blueAccent;
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
                    color: getColorAlmostBlue(),
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
                          isExpanded ? Icons.remove : Icons.add,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                isExpanded
                    ? SizedBox(
                        height: 140.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: candadosPorLugar[lugar]!.length,
                          itemBuilder: (BuildContext context, int index) {
                            Candado candadoPress = candadosPorLugar[lugar]![
                                index]; // Accede al candado específico en esta posición
                            return GestureDetector(
                              onTap: () {
                                _showCandadoDialog(
                                    context, candadoPress, widget.whereFrom);
                              },
                              child: Container(
                                width: 120.0,
                                margin: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, bottom: 8.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                          colorContenedor
                                        ]),
                                    border: Border.all(
                                      color: colorContenedor,
                                    )),
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
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(
                                        candadosPorLugar[lugar]![index]
                                            .fechaIngreso,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14.0,
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

  void _showCandadoDialog(BuildContext context, Candado candado, String where) {
    showDialog(
      context: context,
      builder: (context) => CustomCandadoDialog(candado: candado, where: where),
    );
  }
}
