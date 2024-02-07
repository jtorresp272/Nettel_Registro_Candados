import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/widgets/CustomElevatedButton.dart';
import 'package:flutter_application_1/Funciones/verificar_credenciales.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import '/widgets/CustomTextFromField.dart';
//import 'package:logger/logger.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String user = '';
  String pass = '';
  String where_go = '';
  // Estado para controlar si se está realizando la solicitud HTTP
  bool cargando = false;
  @override
  Widget build(BuildContext context) {
    // obtenemos la dimension total del telefono
    final Size screenSize = MediaQuery.of(context).size;
    //var logger = Logger();
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      body: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_login.png',
                    width: screenSize.width * 0.6,
                    height: screenSize.width * 0.6,
                  ),
                  const SizedBox(
                    height: 60.0,
                  ),
                  CustomTextFormField(
                      hintText: 'Ingrese email...',
                      text: 'Usuario',
                      icon: Icons.email,
                      obscureText: false,
                      onChanged: (value) {
                        setState(() {
                          user = value;
                        });
                      }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomTextFormField(
                      hintText: 'Ingrese contraseña...',
                      text: 'Contraseña',
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          pass = value;
                        });
                      }),
                  const SizedBox(
                    height: 40.0,
                  ),
                  if (!cargando)
                    CustomElevatedButton(
                      text: 'Ingresar',
                      onPressed: () {
                        setState(() {
                          if (user == '') {
                            customSnackBar(context, 'Campo de usuario vacio',
                                Colors.deepOrange);
                          } else if (pass == '') {
                            customSnackBar(context, 'Campo de contraseña vacio',
                                Colors.deepOrange);
                          } else if (user != '' && pass != '') {
                            cargando = true;
                            validarCredenciales(user, pass).then((value) {
                              setState(() {
                                cargando = false;
                                //logger.i(value);
                                if (!value) {
                                  customSnackBar(
                                      context,
                                      'Verificar credenciales',
                                      Colors.redAccent);
                                } else {
                                  if (user == 'taller@nettelcorp.com') {
                                    where_go = '/taller';
                                  } else if (user ==
                                      'monitoreo@nettelcorp.com') {
                                    where_go = '/monitoreo';
                                  } else if (user == 'puerto@nettelcorp.com') {
                                    where_go = '/puerto';
                                  }
                                  Navigator.pushReplacementNamed(
                                    context,
                                    where_go,
                                  );
                                }
                              });
                            });
                          }
                        });
                      },
                    ),
                  const SizedBox(
                    height: 20.0,
                    width: 20.0,
                  ),
                  if (cargando)
                    Center(
                      child: SizedBox(
                        height: 60.0,
                        width: 60.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: getBackgroundColor(),
                          backgroundColor: getColorAlmostBlue(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
