import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomResume.dart';
import 'package:flutter_application_1/widgets/CustomScanResume.dart';
import 'package:flutter_application_1/widgets/CustomSearch.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:logger/logger.dart';

enum MenuNavigator {
  // ignore: constant_identifier_names
  ESCANER,
  // ignore: constant_identifier_names
  HISTORIAL,
}

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
  var logger = Logger();
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
          String scannedNumber = result as String;
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
      });
    } else if (_selectedIndex == MenuNavigator.HISTORIAL.index) {
      // Acciones para el índice 1 (Historial)
    }
  }

  @override
  void initState() {
    super.initState();
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
    //_getDataInCache();
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
          titulo: 'Consorcio Nettel',
          subtitulo: 'Taller',
          reloadCallback: () {
            setState(() {
              restartPage(context);
            });
            updateIconAppBar().triggerNotification(context, false);
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
                        labelColor: getColorAlmostBlue(),
                        unselectedLabelColor: Colors
                            .black45, // Color del texto de las pestañas no seleccionadas
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
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: customDrawer(nameUser: "Taller"),
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

/* funcion para resetear la pagina Taller */
void restartPage(BuildContext context) async {
  // restart datos del taller
  //Navigator.pushReplacement(context,
  //    MaterialPageRoute(builder: (BuildContext context) => const Taller()));
  final Email email = Email(
    body: 'Envio de prueba',
    subject: 'Eres gay',
    recipients: ['jtorresp272@gmail.com', 'osanes28@gmail.com'],
    isHTML: false,
  );
  await FlutterEmailSender.send(email);
}
