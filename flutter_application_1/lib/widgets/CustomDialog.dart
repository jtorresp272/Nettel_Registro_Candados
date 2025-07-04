// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/notification_state.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
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
  late Animation<Offset> _animation;
  // Lugares que estan en taller
  final String lugares = 'EVILM';
  // Colores para el fondo dependiendo del lugar
  Map<String, Color> color = {
    'E': Colors.purple,
    'V': Colors.red,
    'I': Colors.blueAccent,
    'L': Colors.green,
    'M': const Color.fromARGB(255, 214, 197, 43)
  };
  Map<String, String> getNameOfType = {
    'E': "Electronica Dañada",
    'V': "Mecanica Dañada",
    'I': "Candado Ingresado",
    'L': "Candado Listo",
    'M': "Mecanica Lista",
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
    // animacion de ingreso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    // obtener el usario que esta usando el customdialog
    final String user = widget.user ?? 'taller';

//scale: _animation, // Aplicar escala según la animación

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: customColors.background,
      appBar: AppBar(
        backgroundColor: customColors.background,
        leading: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: color[widget.candado.lugar],
            //color: customColors.icons,
            onPressed: () {
              _animationController.reverse().then((_) {
                Navigator.of(context)
                    .pop(); // Cerrar el diálogo al finalizar la animación de salida
              });
            },
            icon: const Icon(
              Icons.keyboard_arrow_left_outlined,
              size: 30,
            ),
          ),
        ),
        title: Center(
          child: SizedBox(
            child: Text(
              getNameOfType[widget.candado.lugar]!,
              style: TextStyle(
                //color: customColors.label,
                color: color[widget.candado.lugar],
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          if (user == 'monitoreo')
            const SizedBox(
              width: 40.0,
            ),
          if (lugares.contains(widget.candado.lugar) && user != 'monitoreo')
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isDamage ? Colors.red : customColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  color: isDamage ? Colors.white : Colors.black,
                  icon: const Icon(Icons.error_outline_sharp),
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
      body: SlideTransition(
        position: _animation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Encabezado
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 100,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Image.asset(
                                  widget.candado.imageTipo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Candado ${widget.candado.numero}',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: customColors.label,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(widget.candado.fechaIngreso),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: customColors.label,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 30.0),

                        // CONTENT
                        Column(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                  context: context,
                                  //color: customColors.label,
                                ),
                                style: TextStyle(
                                  color: customColors.label,
                                ),
                              ),
                            // Descripción de entrada
                            if (!isDamage)
                              TextFormField(
                                maxLines: null,
                                style: TextStyle(
                                  color: customColors.label,
                                ),
                                readOnly: !isEditable_1,
                                autofocus: !isEditable_1,
                                controller: _descripcionIngresoController,
                                decoration:
                                    (lugares.contains(widget.candado.lugar) &&
                                            user != 'monitoreo')
                                        ? decorationTextFieldwithAction(
                                            text: 'Descripción de ingreso',
                                            isEnabled: isEditable_1,
                                            context: context,
                                            onPressed: () {
                                              setState(() {
                                                isEditable_1 = !isEditable_1;
                                              });
                                            },
                                          )
                                        : decorationTextField(
                                            text: 'Descripción de ingreso',
                                            context: context),
                              ),
                            if (!['I', 'V', 'E'].contains(widget.candado.lugar))
                              const SizedBox(
                                height: 20.0,
                              ),

                            if (!isDamage &&
                                !['I', 'V', 'E'].contains(widget.candado.lugar))
                              // Descripción de salida
                              if (lugares.contains(widget.candado.lugar))
                                TextFormField(
                                  maxLines: null,
                                  style: TextStyle(
                                    color: customColors.label,
                                  ),
                                  readOnly: !isEditable_2,
                                  controller: _descripcionSalidaController,
                                  decoration: user != 'monitoreo'
                                      ? decorationTextFieldwithAction(
                                          text: 'Descripción de salida',
                                          isEnabled: isEditable_2,
                                          context: context,
                                          onPressed: () {
                                            setState(() {
                                              isEditable_2 = !isEditable_2;
                                            });
                                          },
                                        )
                                      : decorationTextField(
                                          text: 'Descripción de salida',
                                          context: context),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ACTIONS
            if (lugares.contains(widget.candado.lugar) && user != 'monitoreo')
              if (!waiting)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //elevation:
                        //    5, // Ajusta el valor según el efecto de sombra deseado
                        // Otros estilos como colores, márgenes, etc.
                        foregroundColor: Colors.transparent,
                        backgroundColor: getColorAlmostBlue(),
                        //shadowColor: getColorAlmostBlue(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),

                        minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            MediaQuery.of(context).size.height * 0.06),
                        maximumSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            MediaQuery.of(context).size.height * 0.1),
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
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
