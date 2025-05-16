// ignore_for_file: file_names, camel_case_types, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/servicios/apiForDataBase.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

class customDrawer extends StatefulWidget {
  final String nameUser;
  final VoidCallback? reloadCallback;
  final Function(int)? mode;
  const customDrawer({
    super.key,
    required this.nameUser,
    this.reloadCallback,
    this.mode,
  });

  @override
  State<customDrawer> createState() => _customDrawerState();
}

int mode = 0;

class _customDrawerState extends State<customDrawer> {
  void _handleContainerPressed(int modo) {
    if (widget.mode != null) {
      widget.mode!(modo);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

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
        width: screenSize.width,
        color: customColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.nameUser == 'Puerto')
              const SizedBox(
                height: 20.0,
              ),
            Container(
              height: screenSize.height * 0.1,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      color: getColorAlmostBlue(),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Forma circular
                            color: customColors
                                .background, // Color de fondo del círculo
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información',
                              style: TextStyle(
                                color: customColors.label,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              'cuenta',
                              style: TextStyle(
                                color: customColors.label,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
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
                          color: customColors.background,
                          border: Border.all(color: getColorAlmostBlue())),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: customColors.background,
                                    border:
                                        Border.all(color: getColorAlmostBlue()),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 100, // Ancho del círculo
                                      height: 100, // Altura del círculo
                                      decoration: BoxDecoration(
                                        shape:
                                            BoxShape.circle, // Forma circular
                                        border: Border.all(
                                          color: getColorAlmostBlue(),
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/logo_login.png',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    /*
                                    ListTile(
                                      title: const Text('Joshue Arturo'),
                                      subtitle: const Text('Cargo: Supervisor'),
                                      titleTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      textColor: getColorAlmostBlue(),
                                    ),
                                    */
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: const Text('Usuario'),
                                      titleTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      subtitle: Text('$user@nettelcorp.com'),
                                      textColor: customColors.label,
                                      iconColor: customColors.icons,
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
                                      textColor: customColors.label,
                                      iconColor: customColors.icons,
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
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: customColors.icons,
                        ),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(
              height: 10.0,
            ),
            if (widget.nameUser != 'Puerto')
              //Enviar correo
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: customColors.icons,
                ),
                title: Text(
                  'Enviar correo',
                  style: TextStyle(
                    color: customColors.label,
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
            //Cerrar sesión
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: customColors.icons,
              ),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: customColors.label,
                ),
              ),
              onTap: () async {
                if (widget.nameUser != 'Puerto') {
                  bool hasEmail = await _hasEmail(context);
                  if (!hasEmail) {
                    // Eliminar los datos guardados en memoria del login
                    /*
                    await deleteData(id: 1, title: 'login');
                    Navigator.pushReplacementNamed(
                      context,
                      "/login",
                    );
                    */
                    areYouSure(context);
                  } else {
                    customSnackBar(context,
                        mensaje:
                            'No puede cerrar sesion si tiene un correo por enviar',
                        colorFondo: Colors.red);
                  }
                } else {
                  // Preguntar si esta seguro de cerrar sesión
                  areYouSure(context);
                }
              },
            ),
            /*
            // Modo
            ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: getColorAlmostBlue(),
              ),
              title: Text(
                'Tema Oscuro',
                style: TextStyle(
                  color: getColorAlmostBlue(),
                ),
              ),
              trailing: ToggleSwitch(
                  initialLabelIndex: mode,
                  totalSwitches: 2,
                  fontSize: 12.0,
                  minHeight: 18.0,
                  minWidth: 40.0,
                  activeBgColor: [getColorAlmostBlue()],
                  inactiveBgColor: Colors.grey.shade400,
                  labels: const ['On', 'Off'],
                  onToggle: (index) {
                    setState(() {
                      _handleContainerPressed(index!);
                      mode = index;
                    });
                  }),
            ),
            */
            // Salir de la aplicacion
            ListTile(
              leading: Icon(
                Icons.outbound,
                color: customColors.icons,
              ),
              title: Text(
                'Salir',
                style: TextStyle(
                  color: customColors.label,
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

/* Check si existe informacion por enviar en correo  */
Future<bool> _hasEmail(context) async {
  final List<Note>? notes = await DatabaseHelper.getAllNote(2);
  if (notes != null && notes.isNotEmpty) {
    try {
      final Note note = notes.firstWhere((note) => note.title == 'candados');
      return true;
    } catch (_) {
      return false;
    }
  } else {
    return false;
  }
}

void areYouSure(context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Seguro quieres cerrar sesión?',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'No',
            style: TextStyle(color: getColorAlmostBlue()),
          ),
        ),
        TextButton(
          onPressed: () async {
            // Eliminar los datos guardados en memoria del login
            await deleteData(id: 1, title: 'login');
            Navigator.pushReplacementNamed(
              context,
              "/login",
            );
          },
          child: Text(
            'Si',
            style: TextStyle(color: getColorAlmostBlue()),
          ),
        ),
      ],
    ),
  );
}
