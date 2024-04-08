import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/clases/data_model.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/widgets/CustomElevatedButton.dart';
import 'package:flutter_application_1/Funciones/verificar_credenciales.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import '/widgets/CustomTextFromField.dart';
//import 'package:logger/logger.dart';

class LogIn extends StatefulWidget {
  final Note? note;
  LogIn({Key? key, this.note}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String user = '';
  String pass = '';
  String where_go = '';
  int save_database = 0;

  // Estado para controlar si se está realizando la solicitud HTTP
  bool cargando = false;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    // obtenemos la dimension total del telefono
    final Size screenSize = MediaQuery.of(context).size;
    //var logger = Logger();
    return Scaffold(
      backgroundColor: Colors.white,
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
                      onPressed: () async {
                        //setState((){
                        if (user.isEmpty) {
                          customSnackBar(context, 'Campo de usuario vacio',
                              Colors.deepOrange);
                          return;
                        } else if (pass.isEmpty) {
                          customSnackBar(context, 'Campo de contraseña vacio',
                              Colors.deepOrange);
                          return;
                        }

                        setState(() {
                          cargando = true;
                        });

                        bool isValidCredentials =
                            await validarCredenciales(user, pass);

                        setState(() {
                          cargando = false;
                        });

                        if (!isValidCredentials) {
                          customSnackBar(context, 'Verificar credenciales',
                              Colors.redAccent);
                          return;
                        } else {
                          if (user == 'taller@nettelcorp.com') {
                            save_database = 1;
                            where_go = '/taller';
                          } else if (user == 'monitoreo@nettelcorp.com') {
                            save_database = 2;
                            where_go = '/monitoreo';
                          } else if (user == 'puerto@nettelcorp.com') {
                            save_database = 3;
                            where_go = '/puerto';
                          }
                        }

                        // Guardar informacion en la base de datos
                        Note model = Note(
                          id: 1,
                          title: 'login',
                          description: save_database,
                        );

                        if (widget.note == null) {
                          await DatabaseHelper.addNote(model);
                        } else {
                          await DatabaseHelper.updateNote(model);
                        }

                        // Redirigir a la pagina correspondiente
                        Navigator.pushReplacementNamed(context, where_go);
                        /*
                          else if (user != '' && pass != '') {
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
                                    save_database = 1;
                                    where_go = '/taller';
                                  } else if (user ==
                                      'monitoreo@nettelcorp.com') {
                                    save_database = 2;
                                    where_go = '/monitoreo';
                                  } else if (user == 'puerto@nettelcorp.com') {
                                    save_database = 3;
                                    where_go = '/puerto';
                                  }
                                  final Note model = Note(
                                      id: 1,
                                      title: 'login',
                                      description: save_database.toString());
                                  if (widget.note == null) {
                                    await DatabaseHelper.addNote(model);
                                  } else {
                                    await DatabaseHelper.updateNote(model);
                                  }
                                  Navigator.pushReplacementNamed(
                                    context,
                                    where_go,
                                  );
                                }
                              });
                            });
                          }*/
                        //});
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
