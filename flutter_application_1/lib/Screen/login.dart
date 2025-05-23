import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/widgets/CustomElevatedButton.dart';
import 'package:flutter_application_1/Funciones/generales/verificar_credenciales.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import '/widgets/CustomTextFromField.dart';

class LogIn extends StatefulWidget {
  final Note? note;
  const LogIn({super.key, this.note});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String user = '';
  String pass = '';
  String whereGo = '';
  int saveDatabase = 0;

  // Estado para controlar si se está realizando la solicitud HTTP
  bool cargando = false;
  @override
  void initState() {
    super.initState();
  }

  @override
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
                          customSnackBar(context,
                              mensaje: 'Campo de usuario vacio',
                              colorFondo: Colors.deepOrange);
                          return;
                        } else if (pass.isEmpty) {
                          customSnackBar(context,
                              mensaje: 'Campo de contraseña vacio',
                              colorFondo: Colors.deepOrange);
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
                          // ignore: use_build_context_synchronously
                          customSnackBar(context,
                              mensaje: 'Verificar credenciales',
                              colorFondo: Colors.redAccent);
                          return;
                        } else {
                          if (user == 'taller@nettelcorp.com') {
                            saveDatabase = 1;
                            whereGo = '/taller';
                          } else if (user == 'monitoreo@nettelcorp.com') {
                            saveDatabase = 2;
                            whereGo = '/monitoreo';
                          } else if (user == 'puerto@nettelcorp.com') {
                            saveDatabase = 3;
                            whereGo = '/puerto';
                          }
                        }

                        // Guardar informacion en la base de datos
                        Note model = Note(
                          id: 1,
                          title: 'login',
                          description: saveDatabase,
                        );

                        if (widget.note == null) {
                          await DatabaseHelper.addNote(model, model.id);
                        } else {
                          await DatabaseHelper.updateNote(model, model.id);
                        }

                        // Redirigir a la pagina correspondiente
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, whereGo);
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
