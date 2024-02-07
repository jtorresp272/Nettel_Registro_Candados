import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/monitoreo.dart';
import 'package:flutter_application_1/Screen/taller.dart';
import 'package:flutter_application_1/Screen/puerto.dart';
import 'package:flutter_application_1/Screen/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/monitoreo': (context) => Monitoreo(),
        '/taller': (context) => Taller(),
        '/puerto': (context) => Puerto(),
        '/login': (context) => LogIn(),
      },
    );
  }
}
