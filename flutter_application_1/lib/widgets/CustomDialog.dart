import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildDecorationTextField.dart';
import 'package:flutter_application_1/Funciones/BuildClass/BuildRowWithCheckBox.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
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
  late bool isDamage;
  late bool isMecDamage;
  late bool isElectDamage;

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
                  if(lugares.contains(widget.candado.lugar))
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: isDamage
                            ? Colors.red.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconButton(
                          color: isDamage ? Colors.white : Colors.black,
                          icon: const Icon(Icons.error_outline_sharp),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(isDamage)
              const Text( 
                'Tipo de daño:',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13.0,
                ),
              ),
              // Check para saber si se daño la electronica o la mecanica
              if(isDamage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customCheckBox(
                      name: "Mecánico", 
                      onPressed: (value){
                        setState(() {
                          isMecDamage = !isMecDamage;
                        });
                      }, 
                      isPressed: isMecDamage,
                    ),
                    customCheckBox(
                      name: "Electronico", 
                      onPressed: (value){
                        setState(() {
                          isElectDamage = !isElectDamage;
                        });
                      }, 
                      isPressed: isElectDamage,
                    ),    
                  ],
                ),
              if(isDamage)
                const SizedBox(
                  height: 20.0,
                ),
              // TextFromField Candado dañado
              if (isDamage)
                TextFormField(
                  maxLines: null,
                  controller: _descripcionDanadaController,
                  decoration: decorationTextField(
                      text: 'Descripción de daño', color: Colors.red),
                ),
              if (!isDamage)
                // Descripción de entrada
                TextFormField(
                  maxLines: null,
                  readOnly: !isEditable_1,
                  autofocus: !isEditable_1,
                  controller: _descripcionIngresoController,
                  decoration: lugares.contains(widget.candado.lugar)?
                    decorationTextFieldwithAction(
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
              if (!['I','V','E'].contains(widget.candado.lugar))
                const SizedBox(
                  height: 20.0,
                ),
              
              if (!isDamage && !['I','V','E'].contains(widget.candado.lugar))
                // Descripción de salida
                if (lugares.contains(widget.candado.lugar))
                  TextFormField(
                    maxLines: null,
                    readOnly: !isEditable_2,
                    controller: _descripcionSalidaController,
                    decoration: 
                    decorationTextFieldwithAction(
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
    final String newDescripcionIngreso = _descripcionIngresoController.text.replaceAll(',', '/');
    final String newDescripcionSalida = _descripcionSalidaController.text.replaceAll(',', '/');
    final String newDescripcionDanada = _descripcionDanadaController.text.replaceAll(',', '/');
    List<String> valoresNuevos;
    // Aquí puedes guardar los cambios o hacer lo que necesites con las descripciones editadas
    // Por ahora, solo cerraremos el diálogo
    if(isDamage)
    {
      // Ningun check seleccionado
      if (!isElectDamage && !isMecDamage)
      {
        customSnackBar(context, 'No se selecciono el tipo de daño', Colors.red);
        return;
      }
      // Mecanica Dañada
      else if (!isElectDamage && isMecDamage)
      {
        valoresNuevos = [newDescripcionDanada,'','',DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),'','V'];
      }
      // Electronica Dañada
      else if (isElectDamage && !isMecDamage)
      {
        valoresNuevos = [newDescripcionDanada,'','',DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),'','E'];
      }
      // Electronica Dañada
      else
      {
        valoresNuevos = [newDescripcionDanada,'','',DateFormat('dd-MM-yyyy').format(widget.candado.fechaIngreso),'','E'];
      }

      // Enviar a la funcion modificar valores
      modificarRegistro('modificarRegistroHistorial', widget.candado.numero, valoresNuevos);
      _animationController.reverse().then((_) {
      Navigator.of(context)
          .pop(); // Cerrar el diálogo al finalizar la animación de salida
      });
    }
    else
    {
      switch(widget.candado.lugar)
      {
        case 'I':
          break;
        case 'M':
          break;
        case 'L':
          break;
        case 'V':
          break;
        case 'E':
          break;
        default:
          break;
      }
      
      _animationController.reverse().then((_) {
      Navigator.of(context)
          .pop(); // Cerrar el diálogo al finalizar la animación de salida
      });
    }
  }

  @override
  void dispose() {
    _descripcionIngresoController.dispose();
    _descripcionSalidaController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
