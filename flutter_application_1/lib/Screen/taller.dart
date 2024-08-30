// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/Funciones/verificar_credenciales.dart';
import 'package:flutter_application_1/api/emailHandler.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialog.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
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
  // Variable para determinar el modo que el usuario desee
  int modo = 0;

  // Variables para el TabBar

  final int _selectedIndexTab = 1;
  static const List<Tab> myTabs = <Tab>[
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
  ];

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

    // Si no se encontró en la lista de Taller, buscar en la lista Por Llegar
    if (scannedCandado.numero != scannedNumber) {
      scannedCandado = listaCandadosLlegar.firstWhere(
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
    }

    if (scannedCandado.numero == scannedNumber) {
      // Candado encontrado en la lista local, mostrar el diálogo con la información
      EstadoCandados estado;
      switch (scannedCandado.lugar) {
        case 'I':
          estado = EstadoCandados.ingresado;
          break;
        case 'M':
          estado = EstadoCandados.mantenimiento;
          break;
        case 'V':
        case 'E':
          estado = EstadoCandados.danados;
          break;
        case 'L':
          estado = EstadoCandados.listos;
          break;
        default:
          estado = EstadoCandados.porIngresar;
          break;
      }

      showDialog(
        context: context,
        builder: (context) =>
            CustomScanResume(candado: scannedCandado, estado: estado),
      );
    } else
    // Candado no encontrado en la lista local, obtener datos de la API
    {
      showDialog(
        context: context,
        builder: (context) => DialogScanQr(scannedNumber: scannedNumber),
      );
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
    } else if (_selectedIndex == MenuNavigator.HISTORIAL.index) {
      // Acciones para el índice 1 (Historial)
      showDialog(
        context: context,
        builder: ((context) => const CustomAboutDialog(
              title: 'Ingrese número candado',
              whoIs: 'taller',
            )),
      );
    } else if (_selectedIndex == MenuNavigator.BLUETOOTH.index) {
      Navigator.of(context).pushNamed('/bleConexion');
      //Navigator.popAndPushNamed(context, '/bleConexion');
    } else if (_selectedIndex == MenuNavigator.MAPS.index) {
      Navigator.of(context).pushNamed('/map');
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
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return DefaultTabController(
      initialIndex: _selectedIndexTab,
      length: myTabs.length,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        // Funcion para ocultar la lista de los candados
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            if (tabController.index == 0) {
              setState(() {
                _tabExpandedStates[1]![0] = false;
                _tabExpandedStates[1]![1] = false;
                _tabExpandedStates[1]![2] = false;
                _tabExpandedStates[1]![3] = false;
                _tabExpandedStates[1]![4] = false;
              });
            }
          }
        });

        return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              mode: modo,
              titulo: 'Consorcio Nettel',
              subtitulo: 'Taller',
              reloadCallback: () {
                setState(() {
                  watchDataBeforeSend(
                    context,
                    whoIs: 'Taller',
                  );
                });
              },
            ),
            resizeToAvoidBottomInset: false,
            body: termino_ob_data
                ? Column(
                    children: [
                      Container(
                        color: modo == 0
                            ? customColors.customOne!
                            : customColors.customTwo!,
                        child: TabBar(
                          dividerColor: modo == 0
                              ? customColors.customTwo!
                              : customColors.customOne!,
                          labelColor: modo == 0
                              ? customColors.customTwo!
                              : customColors.customOne!,
                          unselectedLabelColor: modo == 0
                              ? customColors.customThree
                              : Colors
                                  .black54, // Color del texto de las pestañas no seleccionadas
                          indicatorColor: modo == 0
                              ? customColors.customTwo!
                              : customColors.customOne!,
                          // Color del indicador que resalta la pestaña seleccionada
                          labelStyle: const TextStyle(
                            fontSize: 18,
                          ), // Estilo del texto de la pestaña seleccionada
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                          ), // Estilo del texto de las pestañas no seleccionadas
                          tabs: myTabs,
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          //controller: _tabController,
                          children: [
                            // Página 1: "Resumen"
                            CustomResumen(
                              listaTaller: listaCandadosTaller,
                              listaLlegar: listaCandadosLlegar,
                              gotoBar: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    int index = 0;
                                    bool state = true;
                                    logger.i(value);

                                    if (value != 'Total candados por llegar') {
                                      switch (value) {
                                        case 'Candados Operativos':
                                          index = 0;
                                          break;
                                        case 'Mecanicas Listas':
                                          index = 1;
                                          break;
                                        case 'Candados Ingresados':
                                          index = 2;
                                          break;
                                        case 'Mecanicas Dañadas':
                                          index = 3;
                                          break;
                                        case 'Electronicas Dañadas':
                                          index = 4;
                                          break;
                                        default:
                                          state = false;
                                          break;
                                      }
                                      tabController.index = 1;
                                      _tabExpandedStates[tabController.index]![
                                          index] = state;
                                    } else {
                                      tabController.index = 2;
                                    }
                                  }
                                });
                              },
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
                                        if (_textControllerTaller
                                            .text.isEmpty) {
                                          _searchFocusNodeTaller.requestFocus();
                                        }
                                      });
                                    },
                                  ),
                                  CustomListViewBuilder(
                                      whereFrom: 'Taller',
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
                                        if (_textControllerLlegar
                                            .text.isEmpty) {
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
                                            _tabExpandedStates[2]![index] ??
                                                false;
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
                                nameUser: "Taller",
                                reloadCallback: () {
                                  setState(() {
                                    watchDataBeforeSend(
                                      context,
                                      whoIs: 'Taller',
                                    );
                                  });
                                },
                                mode: (value) {
                                  setState(() {
                                    //logger.i(value);
                                    modo = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            bottomNavigationBar: BottomNavigationBar(
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
                BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.bluetooth),
                  label: 'Conectar',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: Icon(Icons.map_outlined),
                  label: 'Mapa',
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
            ));
      }),
    );
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
