import 'package:flutter/material.dart';
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
      backgroundColor: const Color.fromARGB(255, 68, 91, 164),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titulo,
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            widget.subtitulo,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
