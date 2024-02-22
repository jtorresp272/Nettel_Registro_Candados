import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDrawer.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomScanDialog.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
import 'package:logger/logger.dart';
//import 'package:flutter_application_1/Funciones/class_dato_lista.dart';

enum MenuNavigator {
  // ignore: constant_identifier_names
  ESCANER,
  // ignore: constant_identifier_names
  HISTORIAL,
}

class Taller extends StatefulWidget {
  const Taller({Key? key}) : super(key: key);

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
  var logger = Logger();
  bool termino_ob_data = false;
  List<Candado> listaCandadosTaller = [];
  List<Candado> listaFiltradaTaller = [];
  List<Candado> listaCandadosLlegar = [];
  List<Candado> listaFiltradaLlegar = [];
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  final TextEditingController _textControllerTaller = TextEditingController();
  final TextEditingController _textControllerLlegar = TextEditingController();

  late int _selectedIndex = 0; // Definición de _selectedIndex

  late Map<int, Map<int, bool>>
      _tabExpandedStates; // Definicion de _tabExpandedStates para dejar seteado el ultimo estado de cada tapBar

// Void para las botones del bottomNavigatorBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Acciones para el índice 0 (Escanear)
    if (_selectedIndex == MenuNavigator.ESCANER.index) {
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (context) => const CustomQrScan(),
          ))
          .then((result) {
            if (result != null) {
              logger.i('Codigo QR escaneado: $result');
              String scannedNumber = result as String;
              Candado scannedCandado = listaCandadosTaller.firstWhere(
                (candado) => candado.numero == scannedNumber,
                orElse: () => Candado(numero: scannedNumber, tipo: '', razonIngreso: '', razonSalida: '', responsable: '', fechaIngreso: DateTime.now(), fechaSalida: null, lugar: '', imageTipo: '', imageDescripcion: ''), // Valor predeterminado
              );

              if (scannedCandado.numero.isNotEmpty) {
                // Candado encontrado en la lista, mostrar el dialogo con la información
                showDialog(
                  context: context,
                  builder: (context) => CustomScanDialog(candado: scannedCandado),
                );
              } else {
                // Candado no encontrado en la lista, manejar el caso aquí
              }
            }

          });
    } else if (_selectedIndex == MenuNavigator.HISTORIAL.index) {
      // Acciones para el índice 1 (Historial)
    }
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    _tabExpandedStates = {
      0: {},
      1: {},
      2: {},
    };
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getDataGoogleSheet().then((_) {
      setState(() {
        listaCandadosTaller = getCandadosTaller().map((candado) {
          return Candado(
            numero: candado.numero,
            fechaIngreso: candado.fechaIngreso,
            lugar: candado.lugar,
            imageTipo: candado.imageTipo, //getImagePath(candado.lugar),
            imageDescripcion: candado.imageDescripcion,
            razonIngreso: candado.razonIngreso,
            responsable: candado.responsable,
            razonSalida: candado.razonSalida,
            fechaSalida: candado.fechaSalida,
            tipo: candado.tipo,
          );
        }).toList();

        listaCandadosLlegar = getCandadosPuerto().map((candado) {
          return Candado(
            numero: candado.numero,
            fechaIngreso: candado.fechaIngreso,
            lugar: candado.lugar,
            imageTipo: candado.imageTipo, //getImagePath(candado.lugar),
            imageDescripcion: candado.imageDescripcion,
            razonIngreso: candado.razonIngreso,
            responsable: candado.responsable,
            razonSalida: candado.razonSalida,
            fechaSalida: candado.fechaSalida,
            tipo: candado.tipo,
          );
        }).toList();
      });
    });

    listaFiltradaTaller = List.from(listaCandadosTaller);
    listaFiltradaLlegar = List.from(listaCandadosLlegar);
    termino_ob_data = true;
  }

  void filtrarListaTaller(String query) {
    setState(() {
      if (query.isEmpty) {
        listaFiltradaTaller = List.from(listaCandadosTaller);
      } else {
        listaFiltradaTaller = listaCandadosTaller
            .where((candado) => candado.numero.contains(query))
            .toList();
      }
    });
  }

  void filtrarListaLlegar(String query) {
    setState(() {
      if (query.isEmpty) {
        listaFiltradaLlegar = List.from(listaCandadosLlegar);
      } else {
        listaFiltradaLlegar = listaCandadosLlegar
            .where((candado) => candado.numero.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titulo: 'Consorcio Nettel',
          subtitulo: 'Taller',
        ),
        drawer: const customDrawer(
          nameUser: "Taller",
        ),
        resizeToAvoidBottomInset: false,
        body: termino_ob_data ? DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                child: TabBar(
                  labelColor:
                      getColorAlmostBlue(), // Color del texto de la pestaña seleccionada
                  unselectedLabelColor: Colors
                      .black38, // Color del texto de las pestañas no seleccionadas
                  indicatorColor:
                      getColorAlmostBlue(), // Color del indicador que resalta la pestaña seleccionada
                  labelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight
                          .bold), // Estilo del texto de la pestaña seleccionada
                  unselectedLabelStyle: const TextStyle(
                      fontSize:
                          16), // Estilo del texto de las pestañas no seleccionadas
                  tabs: const [
                    Tab(
                      text: 'Resumen',
                    ),
                    Tab(
                      text: 'En Taller',
                    ),
                    Tab(
                      text: 'Por Llegar',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Página 1: "Resumen"
                    CustomResumen(
                      listaTaller: listaCandadosTaller,
                      listaLlegar: listaCandadosLlegar,
                    ),
                    // Página 2: "En Taller"
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 20.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSearchField(
                            controller: _textControllerTaller,
                            focusNode: _searchFocusNodeTaller,
                            onChanged: filtrarListaTaller,
                            onClear: () {
                              setState(() {
                                filtrarListaTaller('');
                                if (_textControllerTaller.text.isEmpty) {
                                  _searchFocusNodeTaller.requestFocus();
                                }
                              });
                            },
                          ),
                          CustomListViewBuilder(
                              where_from: 'Taller',
                              listaFiltrada: listaFiltradaTaller,
                              expandedState: _tabExpandedStates[1]!,
                              onExpandedChanged: (index) {
                                setState(() {
                                  final currentState =
                                      _tabExpandedStates[1]![index] ?? false;
                                  _tabExpandedStates[1]![index] = !currentState;
                                });
                              }),
                        ],
                      ),
                    ),
                    // Página 3: "Por Llegar"
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 20.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSearchField(
                            controller: _textControllerLlegar,
                            focusNode: _searchFocusNodeLlegar,
                            onChanged: filtrarListaLlegar,
                            onClear: () {
                              setState(() {
                                filtrarListaLlegar('');
                                if (_textControllerLlegar.text.isEmpty) {
                                  _searchFocusNodeLlegar.requestFocus();
                                }
                              });
                            },
                          ),
                          CustomListViewBuilder(
                            where_from: 'Llegar',
                            listaFiltrada: listaFiltradaLlegar,
                            expandedState: _tabExpandedStates[2]!,
                            onExpandedChanged: (index) {
                              setState(() {
                                final currentState =
                                    _tabExpandedStates[2]![index] ?? false;
                                _tabExpandedStates[2]![index] = !currentState;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) : Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              strokeWidth: 7.0,
              color: getColorAlmostBlue()
              ,
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Escanear',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_document),
              label: 'Historial',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: getColorAlmostBlue(),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ));
  }

  @override
  void dispose() {
    _textControllerTaller.dispose();
    _textControllerLlegar.dispose();
    _searchFocusNodeTaller.dispose();
    _searchFocusNodeLlegar.dispose();
    super.dispose();
  }
}
