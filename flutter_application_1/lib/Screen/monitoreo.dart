import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/CustomAppBar.dart';
import 'package:flutter_application_1/widgets/CustomDrawer.dart';

class Monitoreo extends StatefulWidget {
  const Monitoreo({super.key});

  @override
  State<Monitoreo> createState() => _MonitoreoState();
}

class _MonitoreoState extends State<Monitoreo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titulo: 'Consorcio Nettel', subtitulo: 'Monitoreo'),
      drawer: const customDrawer(
        nameUser: "Monitoreo",
      ),
      body: const SafeArea(child: Text('Monitoreo')),
    );
  }
}
