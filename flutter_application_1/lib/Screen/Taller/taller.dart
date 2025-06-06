// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/Screen/Taller/CustomFloatingButton.dart';
import 'package:flutter_application_1/Screen/Taller/CustomNavigatorBar.dart';
import 'package:flutter_application_1/Screen/funciones/candado_action_handle.dart';
import 'package:flutter_application_1/Screen/funciones/floating_action_handle.dart';
import 'package:flutter_application_1/api/emailHandler.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
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
  List<Candado> _listaCandadosTaller = [];
  List<Candado> _listaFiltradaTaller = [];
  List<Candado> _listaCandadosLlegar = [];
  List<Candado> _listaFiltradaLlegar = [];
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  final TextEditingController _textControllerTaller = TextEditingController();
  final TextEditingController _textControllerLlegar = TextEditingController();

  // Variables para el navigator bar
  int currentPageIndex = 0;

  int modo = 0; // Variable para determinar el modo que el usuario desee
  bool isExpanded = false; // Variable para el floating button

  late Map<int, Map<int, bool>>
      _tabExpandedStates; // Definicion de _tabExpandedStates para dejar seteado el ultimo estado de cada tapBar
  // Funciones para las peticiones con firebase
  String? token;

  // Funcion para obtener el token de firebase
  Future<void> _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    token = await messaging.getToken();
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

    return Scaffold(
      backgroundColor: customColors.background,
      resizeToAvoidBottomInset: false,
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
      body: termino_ob_data
          ? <Widget>[
              // Página 1: "En Taller"
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
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
              // Página 2: "Por Llegar"
              Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
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
      floatingActionButton: CustomFloatingActionButtons(
        terminoObData: termino_ob_data,
        isExpanded: isExpanded,
        toggleExpand: () => setState(() => isExpanded = !isExpanded),
        onFloatingAction: (action) {
          FloatingActionHandler.handle(
            context: context,
            action: action,
            onNumberReceived: (numero) {
              CandadoActions.handle(
                context: context,
                numeroCandado: numero,
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
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
