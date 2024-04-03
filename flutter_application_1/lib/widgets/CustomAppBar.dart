import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final NotificationState? notificationState;

  CustomAppBar({Key? key,required this.titulo, required this.subtitulo, this.notificationState,}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool showNotification = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        if(widget.subtitulo != "Puerto")
        Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.update),
                onPressed: () {
                  setState(() {
                    showNotification = !showNotification;
                    if(widget.notificationState != null)
                    {
                      widget.notificationState!.updateNotification(showNotification);
                    }
                    
                  });// Acción al presionar el icono de notificaciones
                },
              ),
              if(widget.notificationState != null)
                if (widget.notificationState!.hasNotification)
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
            style: TextStyle(color: getColorAlmostBlue(),fontWeight: FontWeight.bold),
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
