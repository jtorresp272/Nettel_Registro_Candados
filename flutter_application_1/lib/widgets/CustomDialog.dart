
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
  final String lugares = 'ILMVE';
  // Colores para el fondo dependiendo del lugar
  Map<String,Color> color = {'I':Colors.orange,'L':Colors.green,'V':Colors.blueAccent,'E':Colors.red,'M':Colors.yellow};
  // Variables globales
  bool isEditable_1 = false;
  bool isEditable_2 = false;
  late bool isMecDamage;
  late bool isElectDamage;
  
  @override
  void initState() {
    super.initState();
    isMecDamage = widget.candado.lugar == 'V' ? true: false;
    isElectDamage = widget.candado.lugar == 'E' ? true: false;
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
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward(); // Iniciar la animación al abrir el diálogo
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation, // Aplicar escala según la animación
      child: AlertDialog(
        scrollable: true,
        surfaceTintColor: color[widget.candado.lugar] ?? Colors.grey,
        insetPadding: const EdgeInsets.all(20.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: (){
                    _animationController.reverse().then((_) {
                    Navigator.of(context).pop(); // Cerrar el diálogo al finalizar la animación de salida
                    });
                  }, 
                  icon: const Icon(Icons.arrow_back,size: 25.0,),
                ),
              ],
            ),
            Center(
              child: Image.asset(
                widget.candado.imageTipo,
                fit: (widget.candado.tipo == 'CC_5' || widget.candado.tipo == 'CC_4') ? BoxFit.cover:BoxFit.contain,
                width: MediaQuery.of(context).size.width*0.58,
                height: 110.0,
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
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 120,
            maxWidth: MediaQuery.of(context).size.width*0.7,
            minWidth: MediaQuery.of(context).size.width*0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /* Check de mecanica dañada */
              if(!isElectDamage)
              customCheckBox(
                name: "Mecanica Dañada", 
                onPressed:(bool? value){
                  setState(() {
                    isMecDamage = value ?? false;
                  });
                },
                isPressed: isMecDamage,
              ),
              /* Check de electronica dañada */
              if(!isMecDamage)
              customCheckBox(
                name: "Electronica Dañada", 
                onPressed:(bool? value){
                  setState(() {
                    isElectDamage = value ?? false;
                  });
                },
                isPressed: isElectDamage,
              ),
              if(isMecDamage || isElectDamage)
                TextFormField(
                  maxLines: null,
                  controller: _descripcionDanadaController,
                  decoration: decorationTextField(text: 'Descripción de daño',color: Colors.red),
                ),
              const SizedBox(
                height: 20.0,
              ),
              if(!isMecDamage && !isElectDamage)
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
              if(!isMecDamage && !isElectDamage)
              const SizedBox(
                height: 20.0,
              ),
              if(!isMecDamage && !isElectDamage)
              // Descripción de salida
              if(lugares.contains(widget.candado.lugar))
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
          if(lugares.contains(widget.candado.lugar))
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
              ),
              onPressed: () {
                _saveChanges();
              },
              child: Text(
                'Guardar Cambios',
                style: TextStyle(
                  color: getColorAlmostBlue(),
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
      Navigator.of(context).pop(); // Cerrar el diálogo al finalizar la animación de salida
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
