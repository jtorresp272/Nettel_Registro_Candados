import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDrawer.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/Funciones/class_dato_lista.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';

class Taller extends StatefulWidget {
  const Taller({Key? key}) : super(key: key);

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
  late List<Candado> listaCandadosTaller;
  late List<Candado> listaFiltradaTaller;
  late List<Candado> listaCandadosLlegar;
  late List<Candado> listaFiltradaLlegar;
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  TextEditingController _textControllerTaller = TextEditingController();
  TextEditingController _textControllerLlegar = TextEditingController();

  late int _selectedIndex = 0; // Definición de _selectedIndex

  late Map<int, Map<int, bool>> _tabExpandedStates; // Definicion de _tabExpandedStates para dejar seteado el ultimo estado de cada tapBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Realiza las acciones correspondientes a cada índice aquí
    // Por ejemplo:
    if (_selectedIndex == 0) {
      //   // Acciones para el índice 0 (Escanear)
    } else if (_selectedIndex == 1) {
      //   // Acciones para el índice 1 (Historial)
    }
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    _tabExpandedStates = {
      0:{},
      1:{},
      2:{},
    };
    listaCandadosTaller = generarCandadosAleatoriosTaller().map((candado) {
      return Candado(
        numero: candado.numero,
        fechaIngreso: candado.fechaIngreso,
        lugar: candado.lugar,
        image: candado.image, //getImagePath(candado.lugar),
        razonIngreso: candado.razonIngreso,
        responsable: candado.responsable,
        razonSalida: candado.razonSalida,
        fechaSalida: candado.fechaSalida,
        tipo: candado.tipo,
      );
    }).toList();
    listaCandadosLlegar = generarCandadosAleatoriosLlegar().map((candado) {
      return Candado(
        numero: candado.numero,
        fechaIngreso: candado.fechaIngreso,
        lugar: candado.lugar,
        image: candado.image, //getImagePath(candado.lugar),
        razonIngreso: candado.razonIngreso,
        responsable: candado.responsable,
        razonSalida: candado.razonSalida,
        fechaSalida: candado.fechaSalida,
        tipo: candado.tipo,
      );
    }).toList();
    listaFiltradaTaller = List.from(listaCandadosTaller);
    listaFiltradaLlegar = List.from(listaCandadosLlegar);
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
        body: DefaultTabController(
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
                              onExpandedChanged: (index){
                                setState(() {
                                  final currentState = _tabExpandedStates[1]![index] ?? false;
                                  _tabExpandedStates[1]![index] = !currentState;
                                });
                              }
                              ),
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
                              onExpandedChanged: (index){
                                setState(() {
                                  final currentState = _tabExpandedStates[2]![index] ?? false;
                                  _tabExpandedStates[2]![index] = !currentState;
                                });
                              }
                              ,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
