import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:intl/intl.dart';

class CustomCandadoDialog extends StatefulWidget {
  final Candado candado;

  const CustomCandadoDialog({Key? key, required this.candado})
      : super(key: key);

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
    'V': Colors.blueAccent,
    'I': Colors.orange,
    'L': Colors.green,
    'M': Colors.yellow
  };
  // Variables globales
  bool isEditable_1 = false;
  bool isEditable_2 = false;
  bool isDamage = false;
  late bool isMecDamage;
  late bool isElectDamage;

  @override
  void initState() {
    super.initState();
    isMecDamage = widget.candado.lugar == 'V' ? true : false;
    isElectDamage = widget.candado.lugar == 'E' ? true : false;
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
    return ScaleTransition(
      scale: _animation, // Aplicar escala según la animación
      child: AlertDialog(
        titlePadding: const EdgeInsets.all(0.0),
        scrollable: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(15.0),
        // Encabezado (Imagen - Numero - Fecha)
        title: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,
                Colors.white,
                color[widget.candado.lugar] ?? Colors.grey
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
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
                        size: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: isDamage
                          ? Colors.red.withOpacity(0.5)
                          : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        color: isMecDamage ? Colors.white : Colors.black,
                        icon: const Icon(Icons.error_outline_sharp),
                        onPressed: () {
                          setState(() {
                            isDamage = !isDamage;
                          });
                        },
                      ),
                    ),
                  )
                ],
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
                  ),
                ),
              ),
              Center(
                child: Text(
                  DateFormat('yyyy-MM-dd').format(widget.candado.fechaIngreso),
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 120,
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDamage)
                TextFormField(
                  maxLines: null,
                  controller: _descripcionDanadaController,
                  decoration: decorationTextField(
                      text: 'Descripción de daño', color: Colors.red),
                ),
              const SizedBox(
                height: 20.0,
              ),
              if (!isDamage)
                // Descripción de entrada
                TextFormField(
                  maxLines: null,
                  readOnly: !isEditable_1,
                  autofocus: !isEditable_1,
                  controller: _descripcionIngresoController,
                  decoration: decorationTextFieldwithAction(
                    text: 'Descripción de ingreso',
                    isEnabled: isEditable_1,
                    onPressed: () {
                      setState(() {
                        isEditable_1 = !isEditable_1;
                      });
                    },
                  ),
                ),
              if (!isDamage)
                const SizedBox(
                  height: 20.0,
                ),
              if (!isDamage)
                // Descripción de salida
                if (lugares.contains(widget.candado.lugar))
                  TextFormField(
                    maxLines: null,
                    readOnly: !isEditable_2,
                    controller: _descripcionSalidaController,
                    decoration: decorationTextFieldwithAction(
                      text: 'Descripción de salida',
                      isEnabled: isEditable_2,
                      onPressed: () {
                        setState(() {
                          isEditable_2 = !isEditable_2;
                        });
                      },
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          if (lugares.contains(widget.candado.lugar))
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => getColorAlmostBlue()),
                ),
                onPressed: () {
                  _saveChanges();
                },
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final String newDescripcionIngreso = _descripcionIngresoController.text;
    final String newDescripcionSalida = _descripcionSalidaController.text;
    final String newDescripcionDanada = _descripcionDanadaController.text;
    // Aquí puedes guardar los cambios o hacer lo que necesites con las descripciones editadas
    // Por ahora, solo cerraremos el diálogo
    _animationController.reverse().then((_) {
      Navigator.of(context)
          .pop(); // Cerrar el diálogo al finalizar la animación de salida
    });
  }

  @override
  void dispose() {
    _descripcionIngresoController.dispose();
    _descripcionSalidaController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
