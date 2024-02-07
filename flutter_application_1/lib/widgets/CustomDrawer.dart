import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class customDrawer extends StatefulWidget {
  final String nameUser;
  const customDrawer({super.key, required this.nameUser});

  @override
  State<customDrawer> createState() => _customDrawerState();
}

class _customDrawerState extends State<customDrawer> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    var logger = Logger();
    return Drawer(
        width: screenSize.width * 0.75,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 68, 91, 164),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 85.0,
                    height: 85.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_login.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.nameUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Color.fromARGB(255, 68, 91, 164),
              ),
              title: const Text(
                'Usuario',
                style: TextStyle(
                  color: Color.fromARGB(255, 68, 91, 164),
                ),
              ),
              onTap: () {
                // Implementa lo que quieres hacer al seleccionar la opción 1
                logger.i("tap 1");
              },
            ),
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
                logger.i("tap 2");
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
              onTap: () {
                // Implementa lo que quieres hacer al seleccionar la opción 3
                logger.i("tap 3");

                Navigator.pushReplacementNamed(
                  context,
                  "/login",
                );
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
                logger.i("tap 4");
              },
            ),
          ],
        ));
  }
}
