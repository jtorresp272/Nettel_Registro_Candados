// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/Funciones/verificar_credenciales.dart';
import 'package:flutter_application_1/api/emailHandler.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialog.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';

class Monitoreo extends StatefulWidget {
  const Monitoreo({super.key});

  @override
  State<Monitoreo> createState() => _MonitoreoState();
}

class _MonitoreoState extends State<Monitoreo>
    with SingleTickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  bool termino_ob_data = false;
  /* Variables globales */
  List<Candado> listaCandadosTaller = [];
  List<Candado> listaFiltradaTaller = [];
  List<Candado> listaCandadosLlegar = [];
  List<Candado> listaFiltradaLlegar = [];
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  final TextEditingController _textControllerTaller = TextEditingController();
  final TextEditingController _textControllerLlegar = TextEditingController();
  late int _selectedIndex = 0; // Definición de _selectedIndex

  late TabController _tabController;
  int _currentTabIndex = 0; // Variable para indicar la pestaña actual

  late Map<int, Map<int, bool>>
      _tabExpandedStates; // Definicion de _tabExpandedStates para dejar seteado el ultimo estado de cada tapBar

  void _actionWithNumber({required String numeroCandado}) {
    String scannedNumber = numeroCandado;
    // Buscar en la lista local de Taller
    Candado scannedCandado = listaCandadosTaller.firstWhere(
      (e) => e.numero == scannedNumber,
      orElse: () => Candado(
          numero: '',
          tipo: '',
          razonIngreso: '',
          razonSalida: '',
          responsable: '',
          fechaIngreso: DateTime.now(),
          fechaSalida: null,
          lugar: '',
          imageTipo: '',
          imageDescripcion: ''), // Valor predeterminado
    );
    // Candado encontrado en la lista local, mostrar el diálogo con la información
    if (scannedCandado.numero == scannedNumber) {
      if (scannedCandado.lugar == 'L') {
        showDialog(
          context: context,
          builder: (context) => CustomScanResume(
            candado: scannedCandado,
            estado: EstadoCandados.listos,
            whereGo: 'monitoreo',
          ),
        );
      } else {
        customSnackBar(context,
            mensaje: 'El candado no esta listo', colorFondo: Colors.red);
      }
    } else
    // Candado no encontrado en la lista local
    {
      customSnackBar(context,
          mensaje: 'El candado no esta en taller', colorFondo: Colors.red);
    }
  }

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
          _actionWithNumber(numeroCandado: result as String);
        }
      });
    } else if (_selectedIndex == MenuNavigator.MANUAL.index) {
      // Acciones para el índice 1 (Historial)
      showDialog(
        context: context,
        builder: (context) => CustomAboutDialog(
          title: 'Ingrese número',
          whoIs: 'manual',
          manual: (value) {
            _actionWithNumber(numeroCandado: value);
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    hasEmail(context, 'candados');
    listaCandadosTaller.clear();
    listaFiltradaTaller.clear();
    listaCandadosLlegar.clear();
    listaFiltradaLlegar.clear();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    _tabExpandedStates = {
      0: {},
      1: {},
      2: {},
    };
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index; // Actualizar la pestaña actual
      });
    });
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        mode: 0,
        titulo: 'Consorcio Nettel',
        subtitulo: 'Monitoreo',
        reloadCallback: () {
          setState(() {
            watchDataBeforeSend(
              context,
              whoIs: 'Monitoreo',
            );
          });
        },
      ),
      resizeToAvoidBottomInset: false,
      body: termino_ob_data
          ? DefaultTabController(
              initialIndex: 1,
              length: 4,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      dividerColor: Colors.white,
                      controller: _tabController,
                      labelColor: getColorAlmostBlue(),
                      unselectedLabelColor:
                          getUnSelectedIcon(), // Color del texto de las pestañas no seleccionadas
                      indicatorColor:
                          getColorAlmostBlue(), // Color del indicador que resalta la pestaña seleccionada
                      labelStyle: const TextStyle(
                        fontSize: 18,
                      ), // Estilo del texto de la pestaña seleccionada
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                      ), // Estilo del texto de las pestañas no seleccionadas
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.info),
                        ),
                        Tab(
                          icon: Icon(Icons.construction),
                        ),
                        Tab(
                          icon: Icon(Icons.local_shipping),
                        ),
                        Tab(icon: Icon(Icons.menu)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
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
                                  whereFrom: 'Taller',
                                  user: 'monitoreo',
                                  listaFiltrada: listaFiltradaTaller,
                                  expandedState: _tabExpandedStates[1]!,
                                  onExpandedChanged: (index) {
                                    setState(() {
                                      final currentState =
                                          _tabExpandedStates[1]![index] ??
                                              false;
                                      _tabExpandedStates[1]![index] =
                                          !currentState;
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
                                whereFrom: 'Llegar',
                                listaFiltrada: listaFiltradaLlegar,
                                expandedState: _tabExpandedStates[2]!,
                                onExpandedChanged: (index) {
                                  setState(() {
                                    final currentState =
                                        _tabExpandedStates[2]![index] ?? false;
                                    _tabExpandedStates[2]![index] =
                                        !currentState;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        // Usuario
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: customDrawer(
                            nameUser: "Monitoreo",
                            reloadCallback: () {
                              setState(() {
                                watchDataBeforeSend(
                                  context,
                                  whoIs: 'Monitoreo',
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 7.0,
                  color: getColorAlmostBlue(),
                ),
              ),
            ),
      bottomNavigationBar: (_currentTabIndex != 0 && _currentTabIndex != 3)
          ? BottomNavigationBar(
              backgroundColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Escanear',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.drive_file_rename_outline),
                  label: 'Ingresar',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: getColorAlmostBlue(),
              unselectedItemColor: Colors.grey,
              unselectedLabelStyle: const TextStyle(
                color: Colors.grey,
              ),
              showUnselectedLabels: true,
              onTap: _onItemTapped,
            )
          : null,
    );
  }

  @override
  void dispose() {
    _textControllerTaller.dispose();
    _textControllerLlegar.dispose();
    _searchFocusNodeTaller.dispose();
    _searchFocusNodeLlegar.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
