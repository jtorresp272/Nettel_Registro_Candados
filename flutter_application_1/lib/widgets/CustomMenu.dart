// ignore_for_file: file_names, camel_case_types, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';

bool hasEmail = false;

class customDrawer extends StatefulWidget {
  final String nameUser;
  final VoidCallback? reloadCallback;
  const customDrawer({super.key, required this.nameUser, this.reloadCallback});

  @override
  State<customDrawer> createState() => _customDrawerState();
}

class _customDrawerState extends State<customDrawer> {
  @override
  Widget build(BuildContext context) {
    List<String> users = ['taller', 'monitoreo', 'puerto'];
    List<String> contras = ['taller9876', 'monitoreo45678', 'puerto12345'];
    String user = widget.nameUser == "Taller"
        ? users[0]
        : widget.nameUser == "Monitoreo"
            ? users[1]
            : widget.nameUser == "Puerto"
                ? users[2]
                : "ejemplo";
    String contra = widget.nameUser == "Taller"
        ? contras[0]
        : widget.nameUser == "Monitoreo"
            ? contras[1]
            : widget.nameUser == "Puerto"
                ? contras[2]
                : "***";
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        width: screenSize.width * 0.75,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(widget.nameUser == 'Puerto')
              const SizedBox(
                height: 20.0,
              ),
            Container(
              height: screenSize.height * 0.1,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      color: getBackgroundColor(),
                      width: 2.0,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, // Ancho del círculo
                          height: 40, // Altura del círculo
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Forma circular
                            color: Colors.black, // Color de fondo del círculo
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              width: 75.0,
                              height: 75.0,
                              'assets/images/logo_login.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          widget.nameUser,
                          style: TextStyle(
                            color: getColorAlmostBlue(),
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 40.0,
                    ),
                    Container(
                      width: 30, // Ancho del círculo
                      height: 30, // Altura del círculo
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Forma circular
                        color:
                            Colors.grey.shade400, // Color de fondo del círculo
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: const Text('Usuario'),
                                      titleTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      subtitle: Text('$user@nettelcorp.com'),
                                      textColor: getColorAlmostBlue(),
                                      iconColor: getColorAlmostBlue(),
                                      onTap: () {
                                        // Acción para la opción 1
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.password),
                                      title: const Text('Contraseña'),
                                      titleTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      subtitle: Text(contra),
                                      textColor: getColorAlmostBlue(),
                                      iconColor: getColorAlmostBlue(),
                                      onTap: () {
                                        // Acción para la opción 1
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(
              height: 10.0,
            ),
            if(widget.nameUser != 'Puerto')
            ListTile(
              leading: const Icon(
                Icons.email,
                color: Color.fromARGB(255, 68, 91, 164),
              ),
              title: const Text(
                'Enviar correo',
                style: TextStyle(
                  color: Color.fromARGB(255, 68, 91, 164),
                ),
              ),
              onTap: () {
                // Implementa lo que quieres hacer al seleccionar la opción 2
                setState(() {
                  // Chequea si existe una actualizacion para las datos en la base de datos
                  if (widget.reloadCallback != null) {
                    widget
                        .reloadCallback!(); // Llamar a la funcion para actualizar los datos
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Color.fromARGB(255, 68, 91, 164),
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Color.fromARGB(255, 68, 91, 164),
                ),
              ),
              onTap: () async {
                  await _hasEmail(context);
                  if(!hasEmail)
                  {
                    // Eliminar los datos guardados en memoria del login
                    await _deleteData();
                    Navigator.pushReplacementNamed(
                      context,
                      "/login",
                    );
                  }else{
                    customSnackBar(context, 'No puede cerrar sesion si tiene un correo por enviar', Colors.red);
                  }   
                
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.outbound,
                color: Color.fromARGB(255, 68, 91, 164),
              ),
              title: const Text(
                'Salir',
                style: TextStyle(
                  color: Color.fromARGB(255, 68, 91, 164),
                ),
              ),
              onTap: () {
                // Implementa lo que quieres hacer al seleccionar la opción 4
                exit(0); // sale de la aplicacion
              },
            ),
          ],
        ));
  }
}

/* Funcion para borrar los datos guardados en memoria */
Future<void> _deleteData() async {
  Note modelDelete = const Note(
    id: 1,
    title: 'login',
    description: '',
  );
  await DatabaseHelper.deleteNote(modelDelete, modelDelete.id);
}


/* Check si existe informacion por enviar en correo  */
Future<void> _hasEmail(context) async {
  final List<Note>? notes = await DatabaseHelper.getAllNote(2);
  if (notes != null && notes.isNotEmpty) {
    try {
      final Note note = notes.firstWhere((note) => note.title == 'candados');
      hasEmail = true;
    } catch (_) {
      hasEmail = false;
    }
  } else {
    hasEmail = false;
  }
}
