import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:intl/intl.dart';
import '../Funciones/class_dato_lista.dart';

class CustomListViewBuilder extends StatefulWidget {
  final String where_from;
  final List<Candado> listaFiltrada;

  const CustomListViewBuilder({
    required this.where_from,
    required this.listaFiltrada,
  });

  @override
  _CustomListViewBuilderState createState() => _CustomListViewBuilderState();
}

class _CustomListViewBuilderState extends State<CustomListViewBuilder> {
  Set<int> _expandedGroups = {};
  bool _tap = true;
  @override
  Widget build(BuildContext context) {
    Map<String, List<Candado>> candadosPorLugar = {};

    for (var candado in widget.listaFiltrada) {
      if (!candadosPorLugar.containsKey(candado.lugar)) {
        candadosPorLugar[candado.lugar] = [];
      }
      candadosPorLugar[candado.lugar]!.add(candado);
    }

    List<String> lugares = [];
    if (widget.where_from == "Taller") {
      lugares = ['L', 'M', 'I', 'V'];
    } else if (widget.where_from == "Llegar") {
      lugares = [
        'Naportec',
        'DPW',
        'Cuenca',
        'Quito',
        'TPG',
        'Inarpi',
        'Manta'
      ];
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lugares.map((lugar) {
            if (candadosPorLugar.containsKey(lugar) &&
                candadosPorLugar[lugar]!.isNotEmpty) {
              Color colorContenedor = Colors.grey;
              late final String titulo;
              if (widget.where_from == "Taller") {
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
                    colorContenedor = Colors.red;
                    titulo = 'Mecanicas Dañadas';
                    break;
                  default:
                    colorContenedor = Colors.grey;
                    titulo = 'Candados Ingresados';
                    break;
                }
              } else if (widget.where_from == 'Llegar') {
                colorContenedor = Colors.grey;
                titulo = lugar;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 8.0, bottom: 8.0),
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
                              setState(() {
                                if (_expandedGroups
                                    .contains(lugares.indexOf(lugar))) {
                                  _expandedGroups
                                      .remove(lugares.indexOf(lugar));
                                } else {
                                  _expandedGroups.add(lugares.indexOf(lugar));
                                }
                                _tap = !_tap;
                              });
                            },
                            child: Icon(
                              _tap ? Icons.add : Icons.remove,
                              color: Colors.white,
                              size: 25.0,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _expandedGroups.contains(lugares.indexOf(lugar))
                      ? Container(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          height:
                              140.0, // Altura fija para las listas de candados
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: candadosPorLugar[lugar]!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                width: 120.0, // Anchura fija para cada candado
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: colorContenedor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      candadosPorLugar[lugar]![index].image,
                                      fit: BoxFit.contain,
                                      //width: 50.0,
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
                                              .fechaIngreso),
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : SizedBox(), // Si no está expandido, no mostrar el ListView.builder
                ],
              );
            } else {
              return SizedBox
                  .shrink(); // No mostrar la fila si no hay candados en este lugar
            }
          }).toList(),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:intl/intl.dart';
import '../Funciones/class_dato_lista.dart';

class CustomListViewBuilder extends StatelessWidget {
  final String where_from;
  final List<Candado> listaFiltrada;

  const CustomListViewBuilder({
    required this.where_from,
    required this.listaFiltrada,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: ListView.builder(
        itemCount: listaFiltrada.length,
        itemBuilder: (BuildContext context, int index) {
          Color colorContenedor = Colors.grey;
          if(where_from == 'Taller'){
            switch (listaFiltrada[index].lugar) {
            case 'I':
              colorContenedor = Colors.orange;
              break;
            case 'M':
              colorContenedor = Colors.yellow;
              break;
            case 'L':
              colorContenedor = Colors.green;
              break;
            case 'V':
              colorContenedor = Colors.red;
              break;
            default:
              colorContenedor = Colors.grey;
              break;
            }
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: colorContenedor,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              trailing: IconButton(
                onPressed: () {
                  print('item $index');
                },
                icon: const Icon(Icons.expand_more),
              ),
              leading: Image.asset(
                listaFiltrada[index].image,
                fit: BoxFit.contain,
                width: 60.0,
                height: 80.0,
              ),
              title: Text(
                listaFiltrada[index].numero,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(
                DateFormat('yyyy-MM-dd').format(listaFiltrada[index].fechaIngreso),
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    ); 
  }
}*/