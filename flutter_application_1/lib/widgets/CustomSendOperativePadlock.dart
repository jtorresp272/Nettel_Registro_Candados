import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/api/emailHandler.dart';
import 'package:flutter_application_1/widgets/CustomDialog.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:intl/intl.dart';

class SendOperativePadlock extends StatefulWidget {
  final List<Candado> candados;

  const SendOperativePadlock({required this.candados, super.key});

  @override
  State<SendOperativePadlock> createState() => _SendOperativePadlockState();
}

class _SendOperativePadlockState extends State<SendOperativePadlock> {
  late List<bool> seleccionados;
  // Lista para almacenar los candados seleccionados
  List<String> numerosSeleccionados = [];
  // Candados que se guardaran en la base de datos
  List<String> candadosPorEnviar = [];
  // Formatear los datos como texto plano
  String datosFormateados = '';
  // Valores nuevos a enviar al servidor si el correo se envio correctamente
  Map<int, List<String>> valoresNuevos = {};
  // Formatear la fecha
  final DateFormat formatter = DateFormat('dd-MM-yy');
  bool isButtonPress = false;

  @override
  void initState() {
    super.initState();
    seleccionados = List<bool>.filled(widget.candados.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> numerocandados =
        widget.candados.map((c) => c.numero).toList();
    final List<String> tipo = widget.candados.map((c) => c.tipo).toList();
    final List<String> image = widget.candados.map((c) => c.imageTipo).toList();
    final List<String> descripcionIngreso =
        widget.candados.map((c) => c.razonIngreso).toList();
    final List<String> descripcionSalida =
        widget.candados.map((c) => c.razonSalida).toList();
    final List<String> responsable =
        widget.candados.map((c) => c.responsable).toList();
    final List<DateTime> fechaIngreso =
        widget.candados.map((c) => c.fechaIngreso).toList();

    final customColors = Theme.of(context).extension<CustomColors>()!;

    return AlertDialog(
      scrollable: true,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: getColorAlmostBlue(),
          width: 0.5,
        ),
      ),
      backgroundColor: customColors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enviar candados operativos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: getColorAlmostBlue(),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 6,
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Altura máxima
          minWidth: MediaQuery.of(context).size.width * 0.4,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: numerocandados.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  // Obtener los datos de la base de datos del correo
                  String datosMemoria = await getDataDB();

                  setState(() {
                    seleccionados[index] = !seleccionados[index];
                    candadosPorEnviar.clear(); // Reiniciar candados por enviar
                    datosFormateados = ''; // Reiniciar datos formateados
                    numerosSeleccionados
                        .clear(); // Reiniciar numeros seleccionados
                    valoresNuevos = {}; // Reiniciar valores nuevos
                    // check si hay datos en memoria
                    // Limpiar la lista para seleccionar los que estas con el check
                    //candadosEnviar.clear();

                    // recorre cada numero de la lista candados
                    for (int i = 0; i < widget.candados.length; i++) {
                      if (seleccionados[i]) {
                        if (datosMemoria.isNotEmpty) {
                          candadosPorEnviar.add(
                              '$datosMemoria,${numerocandados[i]} - ${descripcionSalida[i]} - Retirar de Taller');
                        } else {
                          candadosPorEnviar.add(
                              '${numerocandados[i]} - ${descripcionSalida[i]} - Retirar de Taller');
                        }
                        // Agregar el numero del candado a la lista de numeros seleccionados
                        numerosSeleccionados.add(numerocandados[i]);
                        // Formatear los datos para enviar por correo
                        datosFormateados +=
                            '${numerocandados[i]} - ${descripcionSalida[i]}\n';
                        // Agregar los valores nuevos a enviar al servidor

                        valoresNuevos[i] = [
                          numerocandados[i],
                          tipo[i],
                          descripcionIngreso[i],
                          descripcionSalida[i],
                          responsable[i],
                          formatter.format(fechaIngreso[i]),
                          DateFormat('dd-MM-yy').format(DateTime.now()),
                          'OP',
                        ];
                      }
                    }
                  });
                },
                child: ListTile(
                  leading: Image.asset(
                    image[index],
                    fit: BoxFit.contain,
                    height: 75.0,
                    width: 75.0,
                  ),
                  title: Text(
                    numerocandados[index],
                    style: TextStyle(
                        color: customColors.label, fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: CircleAvatar(
                      backgroundColor: seleccionados[index]
                          ? getColorAlmostBlue()
                          : Colors.white,
                      child: seleccionados[index]
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }),
      ),
      actions: [
        !isButtonPress
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColorAlmostBlue(),
                ),
                onPressed: () async {
                  if (datosFormateados.isEmpty && valoresNuevos.isEmpty) {
                    customSnackBar(
                      context,
                      mensaje: 'No hay candados por enviar',
                      colorFondo: Colors.red,
                      colorText: Colors.white,
                    );
                    setState(() {
                      isButtonPress = false;
                      Navigator.pop(context);
                    });
                    return;
                  }
                  setState(() {
                    isButtonPress = true;
                  });

                  Note modelCandado = Note(
                    id: 2,
                    title: 'candados',
                    description: candadosPorEnviar.toString(),
                  );
                  log(candadosPorEnviar.toString());
                  // Actualizar el estado del icono de email de la aplicacion
                  // ignore: use_build_context_synchronously
                  updateIconAppBar().triggerNotification(context, true);
                  // Guardar informacion en base de datos
                  await DatabaseHelper.addNote(modelCandado, modelCandado.id);
                  // Limpiar la variable de candados por enviar
                  candadosPorEnviar.clear();

                  // Actualizar los datos en el servidor
                  for (int key in valoresNuevos.keys) {
                    //log('ID ${numerosSeleccionados[key]}: ${valoresNuevos[key]}');
                    await modificarRegistro(
                        'agregarRegistroHistorial',
                        numerosSeleccionados[key].toString(),
                        valoresNuevos[key]!);
                  }
                  setState(() {
                    isButtonPress = false;

                    Navigator.of(context).pop();
                    // Actualizar la pagina
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/monitoreo', (route) => false);
                  });

                  //log(valoresNuevos.toString());
                },
                child: const Text(
                  'Enviar',
                  style: TextStyle(color: Colors.white),
                ))
            : const CircularProgressIndicator(),
      ],
    );
  }
}
