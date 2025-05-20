// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_candado.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/api/emailHandler.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomFloatingButton.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialog.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum Actions {
  qr,
  write,
  historial,
}

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
  // ignore: non_constant_identifier_names
  bool termino_ob_data = false;
/* Variables globales */
  List<Candado> _listaCandadosTaller = [];
  List<Candado> _listaFiltradaTaller = [];
  List<Candado> _listaCandadosLlegar = [];
  List<Candado> _listaFiltradaLlegar = [];
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  final TextEditingController _textControllerTaller = TextEditingController();
  final TextEditingController _textControllerLlegar = TextEditingController();

  // Variables para el navigator bar
  int currentPageIndex = 1;

  int modo = 0; // Variable para determinar el modo que el usuario desee
  bool isExpanded = false; // Variable para el floating button

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

// Busca el número del candado en cache o servidor
  void _actionWithNumber({required String numeroCandado}) {
    String scannedNumber = numeroCandado;

    // Buscar el candado en el cache
    Candado scannedCandado = obtenerDatosCandado(numeroCandado: numeroCandado);

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

      /*
      showDialog(
        context: context,
        builder: (context) =>
            CustomScanResume(candado: scannedCandado, estado: estado),
      );
      */
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CustomScanResume(candado: scannedCandado, estado: estado)));
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
  void _onFloatingAction(Actions index) {
    // Acciones para el índice 0 (Escanear)
    switch (index) {
      // Qr scanner
      case Actions.qr:
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => const CustomQrScan(),
        ))
            .then((result) {
          if (result != null) {
            _actionWithNumber(numeroCandado: result as String);
          }
        });
        break;
      // Escribir numero
      case Actions.write:
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
        break;
      // Historial
      case Actions.historial:
        showDialog(
          context: context,
          builder: ((context) => const CustomAboutDialog(
                title: 'Ingrese número candado',
                whoIs: 'taller',
              )),
        );

        break;
    }
  }

  // Funciones para las peticiones con firebase
  String? token;
  // Variable para enviar notificaciones
  Uri server = Uri(
    scheme: 'http',
    host: 'localhost',
    port: 4050,
    path: '/send-notification',
  );

  // Funcion para obtener el token de firebase
  Future<void> _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    token = await messaging.getToken();
  }

  // Funcion para enviar una notificacion
  Future<void> sendNotification() async {
    logger.w('token is: $token');
    var data = {
      'token': token,
      'title': 'Example',
      'body': 'hello',
    };
    try {
      final response = await http.post(
        server,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customSnackBar(context,
            mensaje: 'notification sent successfully ${data['message']}');
      } else {
        customSnackBar(context,
            mensaje:
                'No se pudo enviar la notificacion: ${response.statusCode}',
            colorFondo: Colors.amber);
      }
    } catch (e) {
      logger.i('Error sending notifications: $e');
      customSnackBar(context, mensaje: '$e', colorFondo: Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();

    hasEmail(context, 'candados');
    _listaCandadosTaller.clear();
    _listaFiltradaTaller.clear();
    _listaCandadosLlegar.clear();
    _listaFiltradaLlegar.clear();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    _tabExpandedStates = {
      0: {},
      1: {},
      2: {},
    };
    _initializeData();
    _getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Message data: ${message.data}');
      if (message.notification != null) {
        logger.w(
            'Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> _initializeData() async {
    await getDataGoogleSheet().then((_) {
      setState(() {
        _listaCandadosTaller = getCandadosTaller().map((candado) {
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

        _listaCandadosLlegar = getCandadosPuerto().map((candado) {
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

    _listaFiltradaTaller = List.from(_listaCandadosTaller);
    _listaFiltradaLlegar = List.from(_listaCandadosLlegar);
    termino_ob_data = true;
  }

  void filtrarListaTaller(String query) {
    setState(() {
      if (query.isEmpty) {
        _listaFiltradaTaller = List.from(_listaCandadosTaller);
      } else {
        _listaFiltradaTaller = _listaCandadosTaller
            .where((candado) => candado.numero.contains(query))
            .toList();
      }
    });
  }

  void filtrarListaLlegar(String query) {
    setState(() {
      if (query.isEmpty) {
        _listaFiltradaLlegar = List.from(_listaCandadosLlegar);
      } else {
        _listaFiltradaLlegar = _listaCandadosLlegar
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
          backgroundColor: customColors.background,
          appBar: CustomAppBar(
            mode: modo,
            area: 'Taller',
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
              ? <Widget>[
                  CustomResumen(
                    listaTaller: _listaCandadosTaller,
                    listaLlegar: _listaCandadosLlegar,
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
                            _tabExpandedStates[tabController.index]![index] =
                                state;
                            currentPageIndex = 1; // ir a la pagina de taller
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
                              if (_textControllerTaller.text.isEmpty) {
                                _searchFocusNodeTaller.requestFocus();
                              }
                            });
                          },
                        ),
                        CustomListViewBuilder(
                            whereFrom: 'Taller',
                            listaFiltrada: _listaFiltradaTaller,
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
                          whereFrom: 'Llegar',
                          listaFiltrada: _listaFiltradaLlegar,
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
                          modo = value;
                        });
                      },
                    ),
                  ),
                ][currentPageIndex]
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
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (termino_ob_data) ...[
                if (isExpanded) ...[
                  CustomFloatingButton(
                    icon: Icons.qr_code_scanner,
                    label: 'QrScanner',
                    onPressed: () => _onFloatingAction(Actions.qr),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  CustomFloatingButton(
                    icon: Icons.drive_file_rename_outline,
                    label: 'Escribir número',
                    onPressed: () => _onFloatingAction(Actions.write),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  CustomFloatingButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Historial',
                    onPressed: () => _onFloatingAction(Actions.historial),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
                FloatingActionButton(
                  heroTag: 'main',
                  tooltip: isExpanded ? 'Minimizar' : 'Maximizar',
                  //onPressed: sendNotification,
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                  backgroundColor: customColors.background,
                  elevation: 0.0,
                  //shape: CircleBorder(
                  //    side: BorderSide(color: getColorAlmostBlue())),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: getColorAlmostBlue()),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_outlined
                        : Icons.keyboard_arrow_up_outlined,
                    color: customColors.icons,
                    //size: 30, // Tamaño del icono
                  ),
                ),
              ],
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              //color: customColors.navigatorBar,
              border: Border(
                top: BorderSide(
                  color: getColorAlmostBlue(),
                  width: 1.0,
                ),
              ),
            ),
            child: NavigationBar(
              backgroundColor: customColors.navigatorBar,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: getColorAlmostBlue().withOpacity(0.8),
              selectedIndex: currentPageIndex,
              labelTextStyle:
                  WidgetStateProperty.all(TextStyle(color: customColors.label)),
              destinations: <Widget>[
                NavigationDestination(
                    icon: Icon(
                      Icons.info_outline,
                      color: customColors.icons,
                    ),
                    selectedIcon: const Icon(Icons.info),
                    label: 'Resumen'),
                NavigationDestination(
                    icon: Icon(
                      Icons.construction_outlined,
                      color: customColors.icons,
                    ),
                    selectedIcon: const Icon(Icons.construction),
                    label: 'Taller'),
                NavigationDestination(
                    icon: Icon(
                      Icons.local_shipping_outlined,
                      color: customColors.icons,
                    ),
                    selectedIcon: const Icon(Icons.local_shipping),
                    label: 'Por llegar'),
                NavigationDestination(
                    icon: Icon(
                      Icons.menu_outlined,
                      color: customColors.icons,
                    ),
                    selectedIcon: const Icon(Icons.menu),
                    label: 'Información'),
              ],
            ),
          ),
        );
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
