import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDrawer.dart';
import 'package:flutter_application_1/widgets/CustomListViewBuilder.dart';
import 'package:flutter_application_1/Funciones/class_dato_lista.dart';
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

  @override
  void initState() {
    super.initState();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    listaCandadosTaller = generarCandadosAleatoriosTaller().map((candado) {
      return Candado(
        numero: candado.numero,
        fechaIngreso: candado.fechaIngreso,
        lugar: candado.lugar,
        image: candado.image,//getImagePath(candado.lugar),
        razonIngreso: candado.razonIngreso,
        responsable: candado.responsable,
        razonSalida: candado.razonSalida,
        fechaSalida: candado.fechaSalida,
      );
    }).toList();
    listaCandadosLlegar = generarCandadosAleatoriosLlegar().map((candado) {
      return Candado(
        numero: candado.numero,
        fechaIngreso: candado.fechaIngreso,
        lugar: candado.lugar,
        image: candado.image,//getImagePath(candado.lugar),
        razonIngreso: candado.razonIngreso,
        responsable: candado.responsable,
        razonSalida: candado.razonSalida,
        fechaSalida: candado.fechaSalida,
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
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.blue,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(
                    text: 'Resumen',
                  ),
                  Tab(
                    text: 'En Taller',
                  ),
                  Tab(text: 'Por Llegar'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Página 1: "Resumen"
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text('data'),
                      ],
                    ),
                  ),

                  // Página 2: "En Taller"
                  Padding(
                    padding: const EdgeInsets.all(20.0),
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
                        CustomListViewBuilder(where_from: 'Taller',listaFiltrada: listaFiltradaTaller),
                      ],
                    ),
                  ),
                  // Página 3: "Por Llegar"
                  Padding(
                    padding: const EdgeInsets.all(20.0),
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
                        CustomListViewBuilder(where_from: 'Llegar',listaFiltrada: listaFiltradaLlegar),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
/*
List<Candado> generarCandadosAleatoriosTaller() {
  return List.generate(
    10,
    (index) => Candado(
      numero: '00${index + 1}',
      fechaIngreso: DateTime.now(),
      lugar: index % 4 == 0 ? 'I' : index % 4 == 1 ? 'M' : index % 4 == 2 ? 'L' : 'V',
      image: '', razonIngreso: '',razonSalida: '',responsable: '', fechaSalida: DateTime.now(),
    ),
  );
}

List<Candado> generarCandadosAleatoriosLlegar() {
  return List.generate(
    10,
    (index) => Candado(
      numero: '00${index + 1}',
      fechaIngreso: DateTime.now(),
      lugar: index % 4 == 0 ? 'I' : index % 4 == 1 ? 'M' : index % 4 == 2 ? 'L' : 'V',
      image: '', razonIngreso: '',razonSalida: '',responsable: '', fechaSalida: DateTime.now(),
    ),
  );
}
*/