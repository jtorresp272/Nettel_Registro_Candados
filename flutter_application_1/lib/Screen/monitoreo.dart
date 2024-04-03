import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomMenu.dart';

class Monitoreo extends StatefulWidget {
  const Monitoreo({super.key});

  @override
  State<Monitoreo> createState() => _MonitoreoState();
}

class _MonitoreoState extends State<Monitoreo> {
  final notify = NotificationState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titulo: 'Consorcio Nettel', subtitulo: 'Monitoreo',notificationState: notify,),
      drawer: const customDrawer(
        nameUser: "Monitoreo",
      ),
      body: const SafeArea(child: Text('Monitoreo')),
    );
  }
}
