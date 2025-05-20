// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/notification_state.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String area;
  final int mode;
  final NotificationState? notificationState;
  final VoidCallback? reloadCallback;

  const CustomAppBar({
    super.key,
    required this.area,
    required this.mode,
    this.notificationState,
    this.reloadCallback,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final notificationState = Provider.of<NotificationState>(context);
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: customColors.background,
      iconTheme: IconThemeData(color: customColors.icons),
      actions: [
        if (widget.area != "Puerto")
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              setState(() {
                // Actualizar la pagina de Taller
                Navigator.pushNamedAndRemoveUntil(
                    context, '/bleConexion', (route) => false);
              });
            },
          ),
        if (widget.area != "Puerto")
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.email_outlined),
                onPressed: () {
                  setState(() {
                    // Chequea si existe una actualizacion para las datos en la base de datos
                    if (widget.reloadCallback != null) {
                      widget
                          .reloadCallback!(); // Llamar a la funcion para actualizar los datos
                    }
                  }); // Acción al presionar el icono de notificaciones
                },
              ),
              if (notificationState.hasNotification)
                Positioned(
                  right: 12,
                  top: 10,
                  child: Container(
                    height: 10.0,
                    width: 10.0,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        if (widget.area != "Puerto")
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                String page =
                    widget.area == 'Monitoreo' ? '/monitoreo' : '/taller';
                // Actualizar la pagina de Taller
                Navigator.pushNamedAndRemoveUntil(
                    context, page, (route) => false);
              });
            },
          ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*
          Image.asset(
            'assets/images/logo_login.png',
            height: 40,
          ),
          const SizedBox(width: 10),
          */
          Text(
            widget.area,
            style: TextStyle(
              color: customColors.appBarTitle,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
