// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final int mode;
  final NotificationState? notificationState;
  final VoidCallback? reloadCallback;

  CustomAppBar({
    super.key,
    required this.titulo,
    required this.subtitulo,
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
      backgroundColor:
          widget.mode == 0 ? customColors.customOne! : customColors.customTwo!,
      iconTheme: IconThemeData(
          color: widget.mode == 0
              ? customColors.customTwo!
              : customColors.customOne!),
      actions: [
        if (widget.subtitulo != "Puerto")
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
        if (widget.subtitulo != "Puerto")
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              setState(() {
                String page =
                    widget.subtitulo == 'Monitoreo' ? '/monitoreo' : '/taller';
                // Actualizar la pagina de Taller
                Navigator.pushNamedAndRemoveUntil(
                    context, page, (route) => false);
              });
            },
          ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titulo,
            style: TextStyle(
                color: widget.mode == 0
                    ? customColors.customTwo!
                    : customColors.customOne!,
                fontWeight: FontWeight.bold),
          ),
          Text(
            widget.subtitulo,
            style: TextStyle(
                color: widget.mode == 0
                    ? customColors.customTwo!
                    : customColors.customOne!,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
