import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/notification_state.dart';
import 'package:flutter_application_1/Screen/ble/bleConexion.dart';
import 'package:flutter_application_1/Screen/historial.dart';
import 'package:flutter_application_1/Screen/monitoreo.dart';
import 'package:flutter_application_1/Screen/taller.dart';
import 'package:flutter_application_1/Screen/puerto.dart';
import 'package:flutter_application_1/Screen/login.dart';
import 'package:flutter_application_1/Screen/splash.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  //await dotenv.load(fileName: ".env");
  // Implement firebase notifications
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotificationState()),
        ChangeNotifierProvider(create: (context) => BleProvider()..startScan()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        //supportedLocales: const [Locale('en','es')],
        initialRoute: '/splash',
        routes: {
          '/monitoreo': (context) => const Monitoreo(),
          '/taller': (context) => const Taller(),
          '/puerto': (context) => const Puerto(),
          '/map': (context) => const MapPage(),
          '/historial': (context) => const Historial(),
          '/bleConexion': (context) => const bleConexion(),
          '/login': (context) => const LogIn(),
          '/splash': (context) => const Splash(),
        },
      ),
    );
  }
}
