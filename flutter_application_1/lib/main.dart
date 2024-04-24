import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:flutter_application_1/Screen/historial.dart';
import 'package:flutter_application_1/Screen/monitoreo.dart';
import 'package:flutter_application_1/Screen/taller.dart';
import 'package:flutter_application_1/Screen/puerto.dart';
import 'package:flutter_application_1/Screen/login.dart';
import 'package:flutter_application_1/Screen/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/monitoreo': (context) => const Monitoreo(),
          '/taller': (context) => const Taller(),
          '/puerto': (context) => const Puerto(),
          '/historial': (context) => const Historial(),
          '/login': (context) => const LogIn(),
          '/splash': (context) => const Splash(),
        },
      ),
    );
  }
}
