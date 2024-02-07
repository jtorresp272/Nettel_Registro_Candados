import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/widgets/CustomElevatedButton.dart';
import 'package:flutter_application_1/widgets/CustomQrScan.dart';
import 'package:logger/logger.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomDrawer.dart';

class Puerto extends StatefulWidget {
  const Puerto({super.key});

  @override
  State<Puerto> createState() => _PuertoState();
}

class _PuertoState extends State<Puerto> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(titulo: 'Consorcio Nettel', subtitulo: 'Puerto'),
      drawer: const customDrawer(
        nameUser: "Puerto",
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          20.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Alineacion verticalmente
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineacion horizontalmente
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
                      logger.i('Codigo QR escaneado: $result');
                    }
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
