import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});
  @override
  State<Historial> createState() => _Historial();
}

class _Historial extends State<Historial> {
  late Map<int, List<CandadoHistorial>> datoHistorial = {};

  @override
  void initState(){
    super.initState();
    datoHistorial = getMapHistorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial',
          style: TextStyle(
            color: getColorAlmostBlue(),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Regresar a la pantalla anterior
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: getColorAlmostBlue(),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.center,
        child: Text(datoHistorial.toString()),
      ),
    );
  }
}
