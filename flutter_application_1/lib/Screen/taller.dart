import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/class_dato_lista.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDrawer.dart';
import 'package:intl/intl.dart';

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => _TallerState();
}

class _TallerState extends State<Taller> {
  late List<Candado> listaCandadosTaller; // Lista de Candado taller
  late List<Candado> listaFiltradaTaller; // Lista de Candado taller filtrada
  late List<Candado> listaCandadosLlegar; // Lista de Candado llegar
  late List<Candado> listaFiltradaLlegar; // Lista de Candado llegar filtrada
  late FocusNode _searchFocusNodeTaller;
  late FocusNode _searchFocusNodeLlegar;
  TextEditingController _textControllerTaller = TextEditingController();
  TextEditingController _textControllerLlegar = TextEditingController();

  String image = 'assets/images/cc_plastico.png';
  @override
  void initState() {
    super.initState();
    _searchFocusNodeTaller = FocusNode();
    _searchFocusNodeLlegar = FocusNode();
    listaCandadosTaller =
        generarCandadosAleatoriosTaller(); // Genera la lista de Candado al iniciar el widget
    listaCandadosLlegar =
        generarCandadosAleatoriosLlegar(); // Genera la lista de Candado al iniciar el widget
    listaFiltradaTaller = List.from(listaCandadosTaller);
    listaFiltradaLlegar = List.from(listaCandadosLlegar);
  }

  void filtrarListaTaller(String query) {
    setState(() {
      if (query.isEmpty) {
        listaFiltradaTaller = List.from(
            listaCandadosTaller); // Restablece la lista filtrada si el campo de búsqueda está vacío
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
        listaFiltradaLlegar = List.from(
            listaCandadosLlegar); // Restablece la lista filtrada si el campo de búsqueda está vacío
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
      appBar: CustomAppBar(titulo: 'Consorcio Nettel', subtitulo: 'Taller'),
      drawer: const customDrawer(
        nameUser: "Taller",
      ),
      resizeToAvoidBottomInset:
          false, // Evita que la pantalla se ajuste cuando aparece el teclado
      body: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: getColorAlmostBlue(),
                indicatorColor: getColorAlmostBlue(),
                tabs: const [
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          child: Text('data'),
                        ),
                      ],
                    ),
                  ),

                  // Página 2: "En Taller"
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, bottom: 5.0),
                          child: TextField(
                            focusNode: _searchFocusNodeTaller,
                            controller: _textControllerTaller,
                            onChanged: filtrarListaTaller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //hintText: '0093...',
                              labelText: 'Buscar',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde del TextField
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde cuando el TextField no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde cuando el TextField está enfocado
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _textControllerTaller.clear();
                                    filtrarListaTaller('');
                                    if (_textControllerTaller.text.isEmpty) {
                                      _searchFocusNodeTaller.requestFocus();
                                    }
                                  });
                                },
                                icon: (_textControllerTaller.text.isEmpty)
                                    ? const Icon(Icons.search)
                                    : const Icon(Icons.close),
                                iconSize: 20.0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal:
                                      10.0), // Ajusta el espacio dentro del TextField
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listaFiltradaTaller.length,
                            itemBuilder: (BuildContext context, int index) {
                              Color colorContenedor = Colors.transparent;

                              switch (listaCandadosTaller[index].lugar) {
                                case 'I':
                                  colorContenedor = Colors.orange;
                                  image = 'assets/images/candado_U.png';
                                  break;
                                case 'M':
                                  colorContenedor = Colors.yellow;
                                  image = 'assets/images/candado_cable.png';
                                  break;
                                case 'L':
                                  colorContenedor = Colors.green;
                                  image = 'assets/images/candado_piston.png';
                                  break;
                                case 'V':
                                  colorContenedor = Colors.red;
                                  image = 'assets/images/cc_plastico.png';
                                  break;
                                default:
                                  colorContenedor = Colors.transparent;
                                  image = 'assets/images/cc_plastico.png';
                                  break;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
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
                                    image,
                                    fit: BoxFit.fitHeight,
                                    width: 60.0,
                                    height: 80.0,
                                  ),
                                  title: Text(
                                    listaFiltradaTaller[index].numero,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('yyyy-MM-dd').format(
                                        listaFiltradaTaller[index]
                                            .fechaIngreso), // Puedes cambiar aquí por la fecha que necesites
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Página 3: "Por Llegar"
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, bottom: 5.0),
                          child: TextField(
                            focusNode: _searchFocusNodeLlegar,
                            controller: _textControllerLlegar,
                            onChanged: filtrarListaLlegar,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              //hintText: '0093...',
                              labelText: 'Buscar',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde del TextField
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde cuando el TextField no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Color del borde cuando el TextField está enfocado
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _textControllerLlegar.clear();
                                    filtrarListaLlegar('');
                                    if (_textControllerLlegar.text.isEmpty) {
                                      _searchFocusNodeLlegar.requestFocus();
                                    }
                                  });
                                },
                                icon: (_textControllerLlegar.text.isEmpty)
                                    ? const Icon(Icons.search)
                                    : const Icon(Icons.close),
                                iconSize: 20.0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal:
                                      10.0), // Ajusta el espacio dentro del TextField
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: listaFiltradaLlegar.length,
                            itemBuilder: (BuildContext context, int index) {
                              Color colorContenedor = Colors.grey;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
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
                                  leading: Text(
                                    listaFiltradaLlegar[index].numero,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  title: Text(
                                    listaFiltradaLlegar[index]
                                        .fechaIngreso
                                        .toString(), // Puedes cambiar aquí por la fecha que necesites
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        ),
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
