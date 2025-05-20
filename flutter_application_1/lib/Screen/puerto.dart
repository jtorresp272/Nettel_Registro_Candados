// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/notification_state.dart';
import 'package:flutter_application_1/widgets/CustomDialogScanQr.dart';
import 'package:flutter_application_1/widgets/CustomElevatedButton.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:flutter_application_1/widgets/CustomAboutDialog.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:logger/logger.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomMenu.dart';

class Puerto extends StatefulWidget {
  const Puerto({super.key});

  @override
  State<Puerto> createState() => _PuertoState();
}

class _PuertoState extends State<Puerto> {
  var logger = Logger();
  final notify = NotificationState();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

// Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;
// Variable para determinar el modo que el usuario desee
    int modo = 0;
    // Variables para el TabBar

    const List<Tab> _myTabs = <Tab>[
      Tab(
        icon: Icon(Icons.info),
      ),
      Tab(
        icon: Icon(Icons.menu),
      ),
    ];

    return DefaultTabController(
      initialIndex: 0,
      length: _myTabs.length,
      child: Builder(builder: (BuildContext context) {
        //final TabController tabController = DefaultTabController.of(context);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            mode: modo,
            area: 'Puerto',
          ),
          drawer: const customDrawer(
            nameUser: "Puerto",
          ),
          body: Column(
            children: [
              Container(
                /*
                color: modo == 0
                    ? customColors.customOne!
                    : customColors.customTwo!,
                    */
                color: Colors.white,
                child: TabBar(
                  /*
                  dividerColor: modo == 0
                      ? customColors.customTwo!
                      : customColors.customOne!,
                  labelColor: modo == 0
                      ? customColors.customTwo!
                      : customColors.customOne!,
                  unselectedLabelColor: modo == 0
                      ? customColors.customThree
                      : Colors
                          .black54, // Color del texto de las pestañas no seleccionadas
                  indicatorColor: modo == 0
                      ? customColors.customTwo!
                      : customColors.customOne!,
                      */
                  dividerColor: Colors.white,
                  labelColor: getColorAlmostBlue(),
                  indicatorColor: getColorAlmostBlue(),
                  unselectedLabelColor: getUnSelectedIcon(),
                  // Color del indicador que resalta la pestaña seleccionada
                  labelStyle: const TextStyle(
                    fontSize: 18,
                  ), // Estilo del texto de la pestaña seleccionada
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                  ), // Estilo del texto de las pestañas no seleccionadas
                  tabs: _myTabs,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Escanear candado
                    Padding(
                      padding: const EdgeInsets.all(
                        20.0,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Alineacion verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Alineacion horizontalmente
                          children: [
                            Text(
                              'Reporte de candados',
                              style: TextStyle(
                                color: getColorAlmostBlue(),
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Image.asset(
                              'assets/images/qr-code.png',
                              width: screenWidth * 0.6,
                              height: screenHeight * 0.3,
                              fit: BoxFit.contain,
                              color: getColorAlmostBlue(),
                            ),
                            Text(
                              'Antes de escanear limpiar el codigo QR del candado',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: getColorAlmostBlue(),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            CustomElevatedButton(
                              text: 'Escanear',
                              onPressed: () {
                                logger.i('press');
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => const CustomQrScan(),
                                ))
                                    .then((result) {
                                  if (result != null) {
                                    String scannedNumber = result as String;
                                    showDialog(
                                      context: context,
                                      builder: (context) => DialogScanQr(
                                        scannedNumber: scannedNumber,
                                        who: 'puerto',
                                      ),
                                    );
                                    logger.i('Codigo QR escaneado: $result');
                                  }
                                });
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'o',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: getColorAlmostBlue(),
                                fontSize: 20.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const CustomAboutDialog(
                                      title: 'Ingrese número'),
                                );
                              },
                              child: Text(
                                'Ingresar manualmente',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: getColorAlmostBlue(),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Informacion cuenta
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: customDrawer(
                        nameUser: "Puerto",
                        mode: (value) {
                          setState(() {
                            modo = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
