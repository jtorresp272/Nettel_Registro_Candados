// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithButton.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Funciones/generales/obtener_datos_database.dart';
import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../Screen/enums.dart';

// Espera que termine la confirmación luego de presionar el boton guardar cambios
bool waitingSendEmail = false;
String datosMemoria = '';
late int candadosIngresados;
List<String> candadosPorEnviar = [];

class CustomScanResume extends StatefulWidget {
  final Candado candado;
  final EstadoCandados estado;
  final Note? note;
  final String? whereGo;
  const CustomScanResume({
    super.key,
    required this.candado,
    required this.estado,
    this.note,
    this.whereGo,
  });

  @override
  // ignore: library_private_types_in_public_api
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

  List<bool> buttonOnPressedResponsable = [false, false, false, false, false];
  List<String> name = ['Joshue', 'Oliver', 'Fabian', 'Oswaldo', 'Jordy'];
  List<String> puertos = [
    'DPW   ',
    'NAPORTEC',
    'TPG    ',
    'CONTECON',
    'QUITO',
    'CUENCA',
    'MANTA',
    'OTRO'
  ];
  List<bool> buttonOnPressedPuerto = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
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

  Map<String, String> getNameOfType = {
    'E': "Electronica Dañada",
    'V': "Mecanica Dañada",
    'I': "Candado Ingresado",
    'L': "Candado Listo",
    'M': "Mecanica Lista",
    'OP': 'Nuevo Candado',
    '': "Nuevo Candado",
  };

  @override
  void initState() {
    super.initState();
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
        buttonOnPressedResponsable[
            name.indexWhere((name) => name.contains(responsable))] = true;
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
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: customColors.background,
      appBar: AppBar(
        backgroundColor: customColors.background,
        title: Center(
          child: SizedBox(
            child: Text(
              getNameOfType[widget.candado.lugar]!,
              style: TextStyle(
                color: customColors.label,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            _animationController.reverse().then((_) {
              Navigator.of(context).pop();
            });
          },
          icon: Icon(
            Icons.arrow_back,
            color: customColors.icons,
          ),
        ),
        actions: [
          if (widget.whereGo != 'puerto')
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isDamage ? Colors.red : customColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.error_outline_sharp,
                    color: isDamage ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isDamage = !isDamage;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
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
                  flex: 1,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    physics: const NeverScrollableScrollPhysics(),
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                // Body
                Expanded(
                  flex: 4,
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
                          style: TextStyle(
                            color: customColors.label,
                          ),
                          controller: _descripcionDanadoController,
                          decoration: decorationTextField(
                              text: 'Descripción de daño',
                              color: Colors.red,
                              context: context),
                        ),
                      if (!isDamage &&
                          !['V', 'E'].contains(widget.candado.lugar))
                        TextFormField(
                          //readOnly: widget.whereGo == 'monitoreo',
                          maxLines: null,
                          style: TextStyle(
                            color: customColors.label,
                          ),
                          controller: _descripcionIngresoController,
                          decoration: decorationTextField(
                              text: 'Descripción de ingreso', context: context),
                        ),
                      if (widget.whereGo == 'puerto')
                        const SizedBox(
                          height: 10.0,
                        ),
                      if (widget.whereGo == 'puerto')
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
                                      'Puerto:',
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
                                        name: [puertos[0], puertos[1]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 0
                                                          ? !buttonOnPressedPuerto[
                                                              0]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 1
                                                          ? !buttonOnPressedPuerto[
                                                              1]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedPuerto[0],
                                          buttonOnPressedPuerto[1]
                                        ],
                                      ),
                                      RowWithButton(
                                        name: [puertos[2], puertos[3]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 2
                                                          ? !buttonOnPressedPuerto[
                                                              2]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 3
                                                          ? !buttonOnPressedPuerto[
                                                              3]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedPuerto[2],
                                          buttonOnPressedPuerto[3]
                                        ],
                                      ),
                                      RowWithButton(
                                        name: [puertos[4], puertos[5]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 4
                                                          ? !buttonOnPressedPuerto[
                                                              4]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 5
                                                          ? !buttonOnPressedPuerto[
                                                              5]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedPuerto[4],
                                          buttonOnPressedPuerto[5]
                                        ],
                                      ),
                                      RowWithButton(
                                        name: [puertos[6], puertos[7]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 6
                                                          ? !buttonOnPressedPuerto[
                                                              6]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedPuerto =
                                                  List.generate(
                                                      buttonOnPressedPuerto
                                                          .length,
                                                      (index) => index == 7
                                                          ? !buttonOnPressedPuerto[
                                                              7]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedPuerto[6],
                                          buttonOnPressedPuerto[7]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.estado != EstadoCandados.porIngresar &&
                          !isDamage)
                        const SizedBox(
                          height: 10.0,
                        ),
                      if (widget.estado != EstadoCandados.porIngresar &&
                          !isDamage)
                        TextFormField(
                          readOnly: widget.whereGo == 'monitoreo',
                          maxLines: null,
                          style: TextStyle(
                            color: customColors.label,
                          ),
                          controller: _descripcionSalidaController,
                          decoration: decorationTextField(
                              text: 'Descripción de salida', context: context),
                        ),
                      if (widget.estado != EstadoCandados.porIngresar &&
                          !isDamage &&
                          widget.whereGo != 'monitoreo')
                        const SizedBox(
                          height: 10.0,
                        ),
                      // Responsables
                      if (widget.estado != EstadoCandados.porIngresar &&
                          !isDamage &&
                          widget.whereGo != 'monitoreo')
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: customColors.label!,
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
                                    color: customColors
                                        .background, // Color del fondo del texto
                                    child: Text(
                                      'Responsable:',
                                      style: TextStyle(
                                        color: customColors.label,
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
                                              buttonOnPressedResponsable =
                                                  List.generate(
                                                      buttonOnPressedResponsable
                                                          .length,
                                                      (index) => index == 0
                                                          ? !buttonOnPressedResponsable[
                                                              0]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedResponsable =
                                                  List.generate(
                                                      buttonOnPressedResponsable
                                                          .length,
                                                      (index) => index == 1
                                                          ? !buttonOnPressedResponsable[
                                                              1]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedResponsable[0],
                                          buttonOnPressedResponsable[1]
                                        ],
                                      ),
                                      RowWithButton(
                                        name: [name[2], name[3]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedResponsable =
                                                  List.generate(
                                                      buttonOnPressedResponsable
                                                          .length,
                                                      (index) => index == 2
                                                          ? !buttonOnPressedResponsable[
                                                              2]
                                                          : false);
                                            });
                                          },
                                          () {
                                            setState(() {
                                              buttonOnPressedResponsable =
                                                  List.generate(
                                                      buttonOnPressedResponsable
                                                          .length,
                                                      (index) => index == 3
                                                          ? !buttonOnPressedResponsable[
                                                              3]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedResponsable[2],
                                          buttonOnPressedResponsable[3]
                                        ],
                                      ),
                                      RowWithButton(
                                        name: [name[4]],
                                        onPressed: [
                                          () {
                                            setState(() {
                                              buttonOnPressedResponsable =
                                                  List.generate(
                                                      buttonOnPressedResponsable
                                                          .length,
                                                      (index) => index == 4
                                                          ? !buttonOnPressedResponsable[
                                                              4]
                                                          : false);
                                            });
                                          },
                                        ],
                                        isPressed: [
                                          buttonOnPressedResponsable[4]
                                        ],
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
                  child: !waitingSendEmail
                      ? Container(
                          alignment: Alignment.center,
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
                                waitingSendEmail = true;
                              });
                              // Acción del botón
                              if (widget.whereGo != 'puerto') {
                                if (buttonOnPressedResponsable.contains(true) ||
                                    widget.estado ==
                                        EstadoCandados.porIngresar ||
                                    isDamage) {
                                  await _saveChanges();
                                  setState(() {
                                    waitingSendEmail = false;
                                  });
                                } else {
                                  customSnackBar(context,
                                      mensaje: 'Seleccione un responsable',
                                      colorFondo: Colors.red);
                                  setState(() {
                                    waitingSendEmail = false;
                                  });
                                }
                              } else {
                                if (buttonOnPressedPuerto.contains(true)) {
                                  await _saveChanges();
                                  setState(() {
                                    waitingSendEmail = false;
                                  });
                                } else {
                                  customSnackBar(context,
                                      mensaje: 'Seleccione un puerto',
                                      colorFondo: Colors.red);
                                  setState(() {
                                    waitingSendEmail = false;
                                  });
                                }
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
        customSnackBar(context,
            mensaje: 'No se selecciono el tipo de daño',
            colorFondo: Colors.red);
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
      if (widget.whereGo == 'monitoreo') {
        switch (widget.estado) {
          case EstadoCandados.porIngresar:
            // Proximo estado
            fechaIngreso = DateFormat('dd-MM-yy').format(DateTime.now());
            fechaSalida = '';
            responsable = '';
            if (widget.whereGo == 'puerto') {
              lugar = puertos[buttonOnPressedPuerto.indexWhere((e) => e)];
              accion = 'modificarRegistro';
            } else {
              lugar = 'I';
              accion = 'agregarRegistroHistorial';
            }
            break;
          case EstadoCandados.listos:
          default:
            lugar = 'OP';
            fechaSalida = DateFormat('dd-MM-yy').format(DateTime.now());
            break;
        }
      } else {
        switch (widget.estado) {
          case EstadoCandados.ingresado:
            newDescripcionSalida =
                '$newDescripcionSalida / ${name[buttonOnPressedResponsable.indexWhere((e) => e)]}';
            // Proximo estado
            lugar = 'M';
            fechaSalida = '';
            break;
          case EstadoCandados.porIngresar:
            // Proximo estado
            fechaIngreso = DateFormat('dd-MM-yy').format(DateTime.now());
            fechaSalida = '';
            responsable = '';
            if (widget.whereGo == 'puerto') {
              lugar = puertos[buttonOnPressedPuerto.indexWhere((e) => e)];
              accion = 'modificarRegistro';
            } else {
              lugar = 'I';
              accion = 'agregarRegistroHistorial';
            }
            break;
          case EstadoCandados.mantenimiento:
          case EstadoCandados.danados:
            responsable = name[buttonOnPressedResponsable.indexWhere((e) => e)];
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
      }

      // Dependiendo de la accion  a realizar se realizan las modificaciones
      if (accion != 'agregarRegistroHistorial') {
        if (isDamage) {
          valoresNuevos = [
            newDescripcionDanado,
            newDescripcionSalida,
            responsable,
            fechaIngreso,
            fechaSalida,
            lugar
          ];
        } else {
          valoresNuevos = [
            newDescripcionIngreso,
            newDescripcionSalida,
            responsable,
            fechaIngreso,
            fechaSalida,
            lugar
          ];
        }
      } else {
        if (isDamage) {
          valoresNuevos = [
            widget.candado.numero,
            widget.candado.tipo,
            newDescripcionDanado,
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
    }

    String snackMessage = '';
    Color snackColor = Colors.red;
    // Enviar a la funcion modificar valores
    bool checkModification =
        await modificarRegistro(accion, widget.candado.numero, valoresNuevos);
    if (checkModification) {
      // Si el candado es por ingresar se debe guardar en la base de datos para luego solicitar la informacion puesta en correo
      if (widget.whereGo != 'puerto') {
        if (widget.estado == EstadoCandados.porIngresar ||
            widget.whereGo == 'monitoreo') {
          // ignore: use_build_context_synchronously
          updateIconAppBar().triggerNotification(context, true);
          // check si hay datos en memoria
          datosMemoria = await getDataDB();
          // crear estructura para los candados en el cache
          if (datosMemoria.isNotEmpty) {
            if (widget.whereGo == 'monitoreo') {
              if (widget.estado == EstadoCandados.porIngresar) {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionIngreso - Ingresar a Taller');
              } else if (isDamage) {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionDanado - Ingresar a Taller');
              } else {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionSalida - Retirar de Taller');
              }
            } else {
              candadosPorEnviar.add(
                  '$datosMemoria,${widget.candado.numero} - $newDescripcionIngreso');
            }
          } else {
            if (widget.whereGo == 'monitoreo') {
              if (widget.estado == EstadoCandados.porIngresar) {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionIngreso - Ingresar a Taller');
              } else if (isDamage) {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionDanado - Ingresar a Taller');
              } else {
                candadosPorEnviar.add(
                    '$datosMemoria,${widget.candado.numero} - $newDescripcionSalida - Retirar de Taller');
              }
            } else {
              candadosPorEnviar
                  .add('${widget.candado.numero} - $newDescripcionIngreso');
            }
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
          // Limpiar la variable de candados por enviar
          candadosPorEnviar.clear();
        }
      }
      // Cerrar el CustomDialog
      _animationController.reverse().then((_) {
        Navigator.of(context)
            .pop(); // Cerrar el diálogo al finalizar la animación de salida
      });
      snackMessage = 'Datos guardados existosamente';
      snackColor = Colors.green;
    } else {
      snackMessage = 'No se pudo enviar correctamente los datos';
      snackColor = Colors.red;
    }
    // mensaje para retroalimentar al usuario que la operacion fue exitosa o no
    // ignore: use_build_context_synchronously
    customSnackBar(context, mensaje: snackMessage, colorFondo: snackColor);
    if (snackColor == Colors.red) return;
    String page = '/${widget.whereGo ?? 'taller'}';
    // Actualizar la pagina
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, page, (route) => false);
  }

  @override
  void dispose() {
    _descripcionIngresoController.dispose();
    _descripcionSalidaController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
