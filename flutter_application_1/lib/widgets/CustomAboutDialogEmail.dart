import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/api/emailHandler.dart';

class CustomAboutDialogEmail extends StatefulWidget {
  final String datos;
  //final String whoIs;
  final VoidCallback? callback;

  const CustomAboutDialogEmail({
    super.key,
    required this.datos,
    //required this.whoIs,
    this.callback,
  });

  @override
  State<CustomAboutDialogEmail> createState() => _CustomAboutDialogEmailState();
}

class _CustomAboutDialogEmailState extends State<CustomAboutDialogEmail> {
  @override
  Widget build(BuildContext context) {
    final String datos = widget.datos;
    bool isPressed = false;

    return AlertDialog(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Text(
        'Dispositivos a enviar',
        style: TextStyle(
          color: getColorAlmostBlue(),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              child: Text(
                datos,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: getColorAlmostBlue(), fontSize: 15.0),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              if (!isPressed)
                Container(
                  alignment: Alignment.center,
                  height: 35.0,
                  width: 70.0,
                  decoration: BoxDecoration(
                    color: getColorAlmostBlue(),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: GestureDetector(
                    onTap: widget.callback,
                    child: const Text(
                      'Enviar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isPressed)
                Container(
                  alignment: Alignment.center,
                  height: 35.0,
                  width: 70.0,
                  child: const CircularProgressIndicator(),
                )
            ],
          ),
        ],
      ),
    );
  }
}
