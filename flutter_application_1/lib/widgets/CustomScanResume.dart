import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithButton.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/Screen/taller.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

enum EstadoCandados {
  ingresado,
  porIngresar,
  mantenimiento,
  listos,
  danados,
}

// Espera que termine la confirmación luego de presionar el boton guardar cambios
bool waiting = false;
String datosMemoria = '';
late int candadosIngresados;
String _description = '';
List<String> candadosPorEnviar = [];

class CustomScanResume extends StatefulWidget {
  final Candado candado;
  final EstadoCandados estado;
  final Note? note;
  final int? candadosEnCache;

  const CustomScanResume(
      {Key? key,
      required this.candado,
      required this.estado,
      this.note,
      this.candadosEnCache})
      : super(key: key);

  @override
  _CustomScanResumeState createState() => _CustomScanResumeState();
}

class _CustomScanResumeState extends State<CustomScanResume>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;
  late TextEditingController _descripcionDanadoController;
  bool candadoEnLista = false;
  bool isDamage = false;
  bool isMecDamage = false;
  bool isElectDamage = false;
  late String imagen;
  String responsable = '';
  String fechaIngreso = '';
  String fechaSalida = '';

  List<bool> buttonOnPressed = [false, false, false, false, false];
  List<String> name = ['Joshue', 'Oliver', 'Fabian', 'Oswaldo', 'Jordy'];
  Map<String, List<Color>> color = {
    'V': [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.orange.shade200,
      Colors.orange.shade300
    ],
    'M': [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.yellow.shade200,
      Colors.yellow.shade300
    ],
    'L': [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.green.shade200,
      Colors.green.shade300
    ],
    'I': [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.blue.shade200,
      Colors.blue.shade300
    ],
    'E': [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.red.shade200,
      Colors.red.shade300
    ],
  };

  @override
  void initState() {
    super.initState();
    candadosIngresados = widget.candadosEnCache ?? 0;
    candadoEnLista = (widget.candado.tipo == '') ? false : true;
    if (candadoEnLista) {
      imagen = widget.candado.imageTipo;
    } else if ((widget.candado.tipo.contains('Plastico'))) {
      imagen = 'assets/images/cc_plastico.png';
    } else if (widget.candado.numero.contains('N01')) {
      imagen = 'assets/images/candado_cable.png';
    } else if (widget.candado.numero.contains('N02')) {
      imagen = 'assets/images/candado_U.png';
    } else if (widget.candado.numero.contains('N03')) {
      imagen = 'assets/images/candado_piston.png';
    } else if (widget.candado.tipo.contains('CC_4') ||
        widget.candado.tipo.contains('CC_5')) {
      imagen = 'assets/images/CC_5.png';
    } else {
      imagen = 'assets/images/CC_5.png';
    }
    // Text controller de los textfromfield
    _descripcionIngresoController =
        TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController =
        TextEditingController(text: widget.candado.razonSalida);
    _descripcionDanadoController =
        TextEditingController(text: widget.candado.razonIngreso);
    // Check si la variable debe empezar en true o en false
    isDamage = ['V', 'E'].contains(widget.candado.lugar);
    isMecDamage = widget.candado.lugar.contains('V');
    isElectDamage = widget.candado.lugar.contains('E');
    fechaIngreso = DateFormat('dd-MM-yy').format(widget.candado.fechaIngreso);
    fechaSalida = widget.candado.fechaSalida != null
        ? DateFormat('dd-MM-yy').format(widget.candado.fechaSalida!)
        : '';
    // Check si existe un responsable
    responsable = widget.candado.responsable;
    if (responsable.isNotEmpty) {
      // Chequeo si el responsable esta en la lista sino no hace nada
      if (name.indexWhere((name) => name.contains(responsable)) != -1) {
        buttonOnPressed[name.indexWhere((name) => name.contains(responsable))] =
            true;
      }
    }
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
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: color[widget.candado.lugar] ??
              [
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.grey.shade400,
                Colors.grey.shade400
              ],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                _animationController.reverse().then((_) {
                  Navigator.of(context).pop();
                });
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isDamage
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isDamage = !isDamage;
                  });
                },
                icon: Icon(
                  Icons.error_outline_sharp,
                  color: isDamage ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors
            .transparent, // Para que el fondo del Scaffold sea transparente
        body: Align(
          alignment: Alignment.bottomLeft,
          child: SlideTransition(
            position: _animation,
            child: Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Tamaño completo de la pantalla
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Titulo
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Image.asset(
                            imagen,
                            fit: (imagen.contains('CC_4') ||
                                    imagen.contains('CC_5'))
                                ? BoxFit.cover
                                : BoxFit.contain,
                            height: 125.0,
                            width: 230.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Center(
                          child: Text(
                            widget.candado.numero,
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                          DateFormat('yyyy-MM-dd')
                              .format(widget.candado.fechaIngreso),
                          style: const TextStyle(fontSize: 20.0),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // Body
                  Expanded(
                    flex: 3,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 0.0),
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        if (isDamage)
                          const Text(
                            'Tipo de daño:',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.0,
                            ),
                          ),
                        // Check para saber si se daño la electronica o la mecanica
                        if (isDamage)
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
                        if (isDamage)
                          const SizedBox(
                            height: 10.0,
                          ),
                        if (isDamage)
                          TextFormField(
                            maxLines: null,
                            controller: _descripcionDanadoController,
                            decoration: decorationTextField(
                                text: 'Descripción de daño', color: Colors.red),
                          ),
                        if (!isDamage &&
                            !['V', 'E'].contains(widget.candado.lugar))
                          TextFormField(
                            maxLines: null,
                            controller: _descripcionIngresoController,
                            decoration: decorationTextField(
                                text: 'Descripción de ingreso'),
                          ),
                        if (widget.estado != EstadoCandados.porIngresar &&
                            !isDamage)
                          const SizedBox(
                            height: 10.0,
                          ),
                        if (widget.estado != EstadoCandados.porIngresar &&
                            !isDamage)
                          TextFormField(
                            maxLines: null,
                            controller: _descripcionSalidaController,
                            decoration: decorationTextField(
                                text: 'Descripción de salida'),
                          ),
                        if (widget.estado != EstadoCandados.porIngresar &&
                            !isDamage)
                          const SizedBox(
                            height: 10.0,
                          ),
                        // Responsables
                        if (widget.estado != EstadoCandados.porIngresar &&
                            !isDamage)
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: getColorAlmostBlue(),
                                )),
                            child: Center(
                              child: Stack(
                                children: [
                                  Positioned(
                                    top:
                                        -5.0, // Ajusta la posición vertical del texto
                                    left:
                                        4.0, // Ajusta la posición horizontal del texto
                                    child: Container(
                                      color: Colors
                                          .white, // Color del fondo del texto
                                      child: Text(
                                        'Responsable:',
                                        style: TextStyle(
                                          color: getColorAlmostBlue(),
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, left: 10.0, right: 10.0),
                                    child: Column(
                                      children: [
                                        RowWithButton(
                                          name: [name[0], name[1]],
                                          onPressed: [
                                            () {
                                              setState(() {
                                                buttonOnPressed = List.generate(
                                                    buttonOnPressed.length,
                                                    (index) => index == 0
                                                        ? !buttonOnPressed[0]
                                                        : false);
                                              });
                                            },
                                            () {
                                              setState(() {
                                                buttonOnPressed = List.generate(
                                                    buttonOnPressed.length,
                                                    (index) => index == 1
                                                        ? !buttonOnPressed[1]
                                                        : false);
                                              });
                                            },
                                          ],
                                          isPressed: [
                                            buttonOnPressed[0],
                                            buttonOnPressed[1]
                                          ],
                                        ),
                                        RowWithButton(
                                          name: [name[2], name[3]],
                                          onPressed: [
                                            () {
                                              setState(() {
                                                buttonOnPressed = List.generate(
                                                    buttonOnPressed.length,
                                                    (index) => index == 2
                                                        ? !buttonOnPressed[2]
                                                        : false);
                                              });
                                            },
                                            () {
                                              setState(() {
                                                buttonOnPressed = List.generate(
                                                    buttonOnPressed.length,
                                                    (index) => index == 3
                                                        ? !buttonOnPressed[3]
                                                        : false);
                                              });
                                            },
                                          ],
                                          isPressed: [
                                            buttonOnPressed[2],
                                            buttonOnPressed[3]
                                          ],
                                        ),
                                        RowWithButton(
                                          name: [name[4]],
                                          onPressed: [
                                            () {
                                              setState(() {
                                                buttonOnPressed = List.generate(
                                                    buttonOnPressed.length,
                                                    (index) => index == 4
                                                        ? !buttonOnPressed[4]
                                                        : false);
                                              });
                                            },
                                          ],
                                          isPressed: [buttonOnPressed[4]],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Boton
                  Expanded(
                    child: !waiting
                        ? Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation:
                                    5, // Ajusta el valor según el efecto de sombra deseado
                                // Otros estilos como colores, márgenes, etc.
                                foregroundColor: Colors.transparent,
                                backgroundColor: getColorAlmostBlue(),
                                shadowColor: getColorAlmostBlue(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.7,
                                    MediaQuery.of(context).size.height * 0.06),
                                maximumSize: Size(
                                    MediaQuery.of(context).size.width * 0.8,
                                    MediaQuery.of(context).size.height * 0.1),
                              ),
                              onPressed: () async {
                                // Acción del botón
                                if (buttonOnPressed.contains(true) ||
                                    widget.estado ==
                                        EstadoCandados.porIngresar ||
                                    isDamage) {
                                  setState(() {
                                    waiting = true;
                                  });
                                  await _saveChanges();
                                  setState(() {
                                    waiting = false;
                                  });
                                } else {
                                  customSnackBar(
                                      context,
                                      'Se debe escoger un responsable',
                                      Colors.red);
                                }
                              },
                              child: Text(
                                widget.estado != EstadoCandados.porIngresar
                                    ? "Guardar y actualizar"
                                    : "Ingresar y actualizar",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: getBackgroundColor(),
                              backgroundColor: getColorAlmostBlue(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    var logger = Logger();
    final String newDescripcionIngreso =
        _descripcionIngresoController.text.replaceAll(',', '/');
    String newDescripcionSalida =
        _descripcionSalidaController.text.replaceAll(',', '/');
    final String newDescripcionDanado =
        _descripcionDanadoController.text.replaceAll(',', '/');
    List<String> valoresNuevos = [];
    String lugar = widget.candado.lugar;
    String accion =
        'modificarRegistroHistorial'; // por defecto modificara los valores en las celdas
    // Aquí puedes guardar los cambios o hacer lo que necesites con las descripciones editadas
    if (isDamage) {
      // Ningun check seleccionado
      if (!isElectDamage && !isMecDamage) {
        customSnackBar(context, 'No se selecciono el tipo de daño', Colors.red);
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
        newDescripcionDanado,
        '',
        '',
        DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),
        '',
        lugar
      ];
    }
    /* Actualizar o Ingresar Valores a la base de datos */
    else {
      switch (widget.estado) {
        case EstadoCandados.ingresado:
          newDescripcionSalida =
              '$newDescripcionSalida / ${name[buttonOnPressed.indexWhere((e) => e)]}';
          // Proximo estado
          lugar = 'M';
          fechaSalida = '';
          break;
        case EstadoCandados.porIngresar:
          // Proximo estado
          fechaIngreso = DateFormat('dd-MM-yy').format(DateTime.now());
          fechaSalida = '';
          responsable = '';
          lugar = 'I';
          accion = 'agregarRegistroHistorial';
          break;
        case EstadoCandados.mantenimiento:
        case EstadoCandados.danados:
          responsable = name[buttonOnPressed.indexWhere((e) => e)];
          fechaSalida = DateFormat('dd-MM-yy').format(DateTime.now());
          // Proximo estado
          lugar = 'L';
          break;
        case EstadoCandados.listos:
          // Proximo estado
          lugar = 'M';
          fechaSalida = '';
          break;
        default:
          // Proximo estado
          lugar = 'I';
          fechaSalida = '';
          break;
      }
      // Dependiendo de la accion  a realizar se realizan las modificaciones
      if (accion == 'modificarRegistroHistorial') {
        valoresNuevos = [
          newDescripcionIngreso,
          newDescripcionSalida,
          responsable,
          fechaIngreso,
          fechaSalida,
          lugar
        ];
      } else {
        valoresNuevos = [
          widget.candado.numero,
          widget.candado.tipo,
          newDescripcionIngreso,
          newDescripcionSalida,
          responsable,
          fechaIngreso,
          fechaSalida,
          lugar
        ];
      }
    }

    String snackMessage = '';
    Color snackColor = Colors.red;
    // Enviar a la funcion modificar valores
    bool checkModification =
        await modificarRegistro(accion, widget.candado.numero, valoresNuevos);
    if (checkModification) {
      // Si el candado es por ingresar se debe guardar en la base de datos para luego solicitar la informacion puesta en correo
      if (widget.estado == EstadoCandados.porIngresar) {
        updateIconAppBar().triggerNotification(context, true);
        // check si hay datos en memoria
        await _getDataDB();
        // crear estructura para los candados en el cache
        if (datosMemoria.isNotEmpty) {
          candadosPorEnviar.add(
              '$datosMemoria,${widget.candado.numero} - $newDescripcionIngreso');
        } else {
          candadosPorEnviar
              .add('${widget.candado.numero} - $newDescripcionIngreso');
        }
        logger.i(candadosPorEnviar);
        Note modelCandado = Note(
          id: 2,
          title: 'candados',
          description: candadosPorEnviar.toString(),
        );

        // Guardar informacion
        if (widget.note == null) {
          await DatabaseHelper.addNote(modelCandado, modelCandado.id);
        } else {
          await DatabaseHelper.updateNote(modelCandado, modelCandado.id);
        }
        candadosPorEnviar.clear();
      }
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
    customSnackBar(context, snackMessage, snackColor);
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

/* Obtiene informacion de la base de datos */
Future<void> _getDataDB() async {
  final List<Note>? notes = await DatabaseHelper.getAllNote(2);
  if (notes != null && notes.isNotEmpty) {
    try {
      final Note note = notes.firstWhere((note) => note.title == 'candados');
      String texto = note.description;
      datosMemoria = texto.substring(1, texto.length - 1);
    } on StateError catch (_) {
      datosMemoria =
          ''; // Si notes es nulo o está vacío, establece la descripción como '0'
    }
  } else {
    datosMemoria =
        ''; // Si notes es nulo o está vacío, establece la descripción como '0'
  }
}
