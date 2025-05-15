// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/notification_state.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:intl/intl.dart';
//import 'package:provider/provider.dart';

// Espera que termine la confirmación luego de presionar el boton guardar cambios
bool waiting = false;

class CustomCandadoDialog extends StatefulWidget {
  final Candado candado;
  final String where;
  final String? user;
  const CustomCandadoDialog({
    super.key,
    required this.candado,
    required this.where,
    this.user,
  });

  @override
  _CustomCandadoDialogState createState() => _CustomCandadoDialogState();
}

class _CustomCandadoDialogState extends State<CustomCandadoDialog>
    with SingleTickerProviderStateMixin {
  // controlares para los textfromfield
  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;
  late TextEditingController _descripcionDanadaController;
  // Variables para animación del alertDialog
  late AnimationController _animationController;
  late Animation<double> _animation;
  // Lugares que estan en taller
  final String lugares = 'EVILM';
  // Colores para el fondo dependiendo del lugar
  Map<String, Color> color = {
    'E': Colors.red,
    'V': Colors.orange,
    'I': Colors.blueAccent,
    'L': Colors.green,
    'M': Colors.yellow
  };
  Map<String, String> getNameOfType = {
    'E': "Electronicas Dañadas",
    'V': "Mecanicas Dañadas",
    'I': "Candados Ingresados",
    'L': "Candados Listos",
    'M': "Mecanicas Listas",
  };
  /* Variables globales */
  bool isEditable_1 = false; // Editar el campo Descripcion ingreso
  bool isEditable_2 = false; // Editar el campo Descripcion Salida
  late bool isDamage; // Candado presenta alguna parte dañada
  late bool isMecDamage; // mecanica dañada
  late bool isElectDamage; // Electronica dañada
  final NotificationState notify = NotificationState();

  @override
  void initState() {
    super.initState();
    /* Revisa si estan dañadas en mecanica o electronica */
    isMecDamage = widget.candado.lugar == 'V';
    isElectDamage = widget.candado.lugar == 'E';
    isDamage = ['V', 'E'].contains(widget.candado.lugar);
    _descripcionIngresoController =
        TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController =
        TextEditingController(text: widget.candado.razonSalida);
    _descripcionDanadaController =
        TextEditingController(text: widget.candado.razonIngreso);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duración de la animación
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward(); // Iniciar la animación al abrir el diálogo
  }

  @override
  Widget build(BuildContext context) {
    // obtener el usario que esta usando el customdialog
    final String user = widget.user ?? 'taller';

    return ScaleTransition(
      scale: _animation, // Aplicar escala según la animación
      child: AlertDialog(
        titlePadding: const EdgeInsets.all(0.0),
        scrollable: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          //side: BorderSide(color: color[widget.candado.lugar] ?? Colors.grey),
        ),
        // Encabezado (Imagen - Numero - Fecha)
        title: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        color: Colors.black,
                        onPressed: () {
                          _animationController.reverse().then((_) {
                            Navigator.of(context)
                                .pop(); // Cerrar el diálogo al finalizar la animación de salida
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Text(
                        getNameOfType[widget.candado.lugar]!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user == 'monitoreo')
                      const SizedBox(
                        width: 40.0,
                      ),
                    if (lugares.contains(widget.candado.lugar) &&
                        user != 'monitoreo')
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: isDamage ? Colors.red : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconButton(
                            color: isDamage ? Colors.white : Colors.black,
                            icon: const Icon(Icons.edit_document),
                            onPressed: () {
                              setState(
                                () {
                                  isDamage = !isDamage;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Center(
                child: Image.asset(
                  widget.candado.imageTipo,
                  fit: (widget.candado.tipo == 'CC_5' ||
                          widget.candado.tipo == 'CC_4')
                      ? BoxFit.cover
                      : BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.58,
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  widget.candado.numero,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Center(
                child: Text(
                  DateFormat('yyyy-MM-dd').format(widget.candado.fechaIngreso),
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
        content: ConstrainedBox(
          // Dimensiones maximas y minimas
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.1,
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isDamage && user != 'monitoreo')
                const Text(
                  'Tipo de daño:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13.0,
                  ),
                ),
              // Check para saber si se daño la electronica o la mecanica
              if (isDamage && user != 'monitoreo')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customCheckBox(
                      name: "Mecánico",
                      onPressed: (value) {
                        setState(() {
                          isMecDamage = !isMecDamage;
                        });
                      },
                      isPressed: isMecDamage,
                    ),
                    customCheckBox(
                      name: "Electronico",
                      onPressed: (value) {
                        setState(() {
                          isElectDamage = !isElectDamage;
                        });
                      },
                      isPressed: isElectDamage,
                    ),
                  ],
                ),
              if (isDamage && user != 'monitoreo')
                const SizedBox(
                  height: 20.0,
                ),
              // TextFromField Candado dañado
              if (isDamage)
                TextFormField(
                  maxLines: null,
                  controller: _descripcionDanadaController,
                  decoration: decorationTextField(
                    text: 'Descripción de daño',
                    color: Colors.red,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              if (!isDamage)
                // Descripción de entrada
                TextFormField(
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  readOnly: !isEditable_1,
                  autofocus: !isEditable_1,
                  controller: _descripcionIngresoController,
                  decoration: (lugares.contains(widget.candado.lugar) &&
                          user != 'monitoreo')
                      ? decorationTextFieldwithAction(
                          text: 'Descripción de ingreso',
                          isEnabled: isEditable_1,
                          onPressed: () {
                            setState(() {
                              isEditable_1 = !isEditable_1;
                            });
                          },
                        )
                      : decorationTextField(text: 'Descripción de ingreso'),
                ),
              if (!['I', 'V', 'E'].contains(widget.candado.lugar))
                const SizedBox(
                  height: 20.0,
                ),

              if (!isDamage && !['I', 'V', 'E'].contains(widget.candado.lugar))
                // Descripción de salida
                if (lugares.contains(widget.candado.lugar))
                  TextFormField(
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    readOnly: !isEditable_2,
                    controller: _descripcionSalidaController,
                    decoration: user != 'monitoreo'
                        ? decorationTextFieldwithAction(
                            text: 'Descripción de salida',
                            isEnabled: isEditable_2,
                            onPressed: () {
                              setState(() {
                                isEditable_2 = !isEditable_2;
                              });
                            },
                          )
                        : decorationTextField(text: 'Descripción de salida'),
                  ),
            ],
          ),
        ),
        actions: [
          if (lugares.contains(widget.candado.lugar) && user != 'monitoreo')
            if (!waiting)
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith(
                        (states) => getColorAlmostBlue()),
                  ),
                  onPressed: () async {
                    setState(() {
                      waiting = true;
                    });
                    // Guardar cambios realizados
                    await _saveChanges();

                    setState(() {
                      waiting = false;
                    });
                  },
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          if (waiting)
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: getBackgroundColor(),
                backgroundColor: getColorAlmostBlue(),
              ),
            ),
        ],
      ),
    );
  }

// Función para enviar los cambios a la base de datos (es async porque espera confirmacion de la base de datos)
  Future<void> _saveChanges() async {
    final String newDescripcionIngreso =
        _descripcionIngresoController.text.replaceAll(',', '/');
    final String newDescripcionSalida =
        _descripcionSalidaController.text.replaceAll(',', '/');
    final String newDescripcionDanada =
        _descripcionDanadaController.text.replaceAll(',', '/');
    List<String> valoresNuevos;
    String lugar = widget.candado.lugar;
    // Aquí puedes guardar los cambios o hacer lo que necesites con las descripciones editadas
    if (isDamage) {
      // Ningun check seleccionado
      if (!isElectDamage && !isMecDamage) {
        customSnackBar(
          context,
          mensaje: 'No se selecciono el tipo de daño',
          colorFondo: Colors.red,
        );
        return;
      }
      // Mecanica Dañada
      else if (!isElectDamage && isMecDamage) {
        lugar = 'V';
      }
      // Electronica Dañada
      else if (isElectDamage && !isMecDamage) {
        lugar = 'E';
      }
      // Electronica Dañada
      else {
        lugar = 'E';
      }
      // Agregar el lugar en la lista para actualizar el candado
      valoresNuevos = [
        newDescripcionDanada,
        '',
        '',
        DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),
        '',
        lugar
      ];
    } else {
      switch (widget.candado.lugar) {
        case 'V':
          lugar = 'I';
          break;
        case 'E':
          lugar = 'I';
          break;
        case 'I':
        case 'L':
        case 'M':
        default:
          lugar = widget.candado.lugar;
          break;
      }
      valoresNuevos = [
        newDescripcionIngreso,
        newDescripcionSalida,
        widget.candado.responsable,
        DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),
        (widget.candado.fechaSalida != null)
            ? DateFormat('dd-MM-yyyy').format(widget.candado.fechaSalida!)
            : '',
        lugar
      ];
    }

    String snackMessage = '';
    Color snackColor = Colors.red;
    // Enviar a la funcion modificar valores
    bool checkModification = await modificarRegistro(
        'modificarRegistroHistorial', widget.candado.numero, valoresNuevos);
    if (checkModification) {
      //updateIconAppBar().triggerNotification(context, true);
      // Cerrar el CustomDialog
      _animationController.reverse().then((_) {
        Navigator.of(context)
            .pop(); // Cerrar el diálogo al finalizar la animación de salida
      });
      snackMessage = 'Actualización realizada existosamente :D';
      snackColor = Colors.green;
    } else {
      snackMessage = 'No se pudo enviar correctamente la actualización';
      snackColor = Colors.red;
    }
    // mensaje para retroalimentar al usuario que la operacion fue exitosa o no
    customSnackBar(context, mensaje: snackMessage, colorFondo: snackColor);
    if (snackColor == Colors.red) return;
    // Actualizar la pagina de Taller
    Navigator.pushNamedAndRemoveUntil(context, '/taller', (route) => false);
  }

  @override
  void dispose() {
    _descripcionIngresoController.dispose();
    _descripcionSalidaController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

/*
String getNameOfType(String place)
{
  
  return "";
}
*/
