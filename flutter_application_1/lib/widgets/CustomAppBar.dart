import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final NotificationState? notificationState;
  final VoidCallback? reloadCallback;

  CustomAppBar({
    Key? key,
    required this.titulo,
    required this.subtitulo,
    this.notificationState,
    this.reloadCallback,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final notificationState = Provider.of<NotificationState>(context);

    return AppBar(
      actions: [
        if (widget.subtitulo != "Puerto")
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.email_outlined),
                onPressed: () {
                  setState(() {
                    // Chequea si existe una actualizacion para las datos en la base de datos
                    if (notificationState.hasNotification) {
                      if (widget.reloadCallback != null) {
                        widget
                            .reloadCallback!(); // Llamar a la funcion para actualizar los datos
                      }
                    } else {
                      customSnackBar(context,
                          'No existen actualizaciones pendientes', Colors.red);
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
      ],
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: getColorAlmostBlue()),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titulo,
            style: TextStyle(
                color: getColorAlmostBlue(), fontWeight: FontWeight.bold),
          ),
          Text(
            widget.subtitulo,
            style: TextStyle(
                color: getColorAlmostBlue(),
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
