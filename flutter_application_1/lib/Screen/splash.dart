import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';

class Splash extends StatefulWidget {
  Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late int _description;
  late Timer _timer;
  String page = '/login';

  @override
  void initState() {
    super.initState();
    // Inicia chequeo en la base de datos
    _initData();
    // Inicia un timer de 2 segundos
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(
          page); // Reemplaza '/pagina_uno' con la ruta de tu página
    });
  }

  @override
  void dispose() {
    // Cancelar el temporizador al salir de la pantalla
    _timer.cancel();
    super.dispose();
  }

/* Funcion para realizar las acciones de decisión de que pagina se dirige */
  Future<void> _initData() async {
    await _getDataFromDB();
    _checkData();
  }

  /* Obtiene informacion de la base de datos */
  Future<void> _getDataFromDB() async {
    final List<Note>? notes = await DatabaseHelper.getAllNote();
    if (notes != null && notes.isNotEmpty) {
      final Note note = notes.firstWhere((note) => note.title == 'login');
      _description = note.description;
    } else {
      _description =
          0; // Si notes es nulo o está vacío, establece la descripción como '0'
    }
  }

  /* Procesa la informacion obtenida de la base de datos */
  void _checkData() {
    switch (_description) {
      case 0:
        page = '/login';
        break;
      case 1:
        page = '/taller';
        break;
      case 2:
        page = '/monitoreo';
        break;
      case 3:
        page = '/puerto';
        break;
      default:
        page = '/login';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Image.asset('assets/images/logo_login.png')),
      ),
    );
  }
}
