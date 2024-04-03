
import 'package:flutter/material.dart';
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
  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;
  late TextEditingController _descripcionDanadaController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final String lugares = 'ILMV';
  Map<String,Color> color = {'I':Colors.orange,'L':Colors.green,'V':Colors.red,'M':Colors.yellow};
  bool isEditable_1 = false;
  bool isEditable_2 = false;
  bool isMecDamage = false;

  @override
  void initState() {
    super.initState();
    _descripcionIngresoController =
        TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController =
        TextEditingController(text: widget.candado.razonSalida);
    _descripcionDanadaController =
        TextEditingController(text: '');
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
              Row(
                children: [
                  Checkbox(
                    side: BorderSide(
                      color: getColorAlmostBlue(),
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                    fillColor: MaterialStateColor.resolveWith((states) => isMecDamage ? Colors.red:Colors.transparent),
                    value: isMecDamage, 
                    onChanged: (value){
                      setState(() {
                        isMecDamage = !isMecDamage;
                      });
                    },
                  ),
                  Text(
                    "Mecánica Dañada",
                    style: TextStyle(
                      color: isMecDamage ? Colors.red:getColorAlmostBlue(),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              if(isMecDamage)
                TextFormField(
                  maxLines: null,
                  controller: _descripcionDanadaController,
                  decoration: InputDecoration(
                    labelText: 'Descripción Mecánica Dañada',
                    labelStyle: const TextStyle(
                      color: Colors.red,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white54,
                  ),
                ),
              const SizedBox(
                height: 20.0,
              ),
              if(!isMecDamage)
              // Descripción de entrada
              TextFormField(
                maxLines: null,
                readOnly: !isEditable_1,
                autofocus: !isEditable_1,
                controller: _descripcionIngresoController,
                decoration: decorationTextField(
                  text: 'Descripción de ingreso',
                  isEnabled: isEditable_1,
                  onPressed: () {
                    setState(() {
                      isEditable_1 = !isEditable_1;
                    });
                  },
                ),
              ),
              if(!isMecDamage)
              const SizedBox(
                height: 20.0,
              ),
              if(!isMecDamage)
              // Descripción de salida
              if(lugares.contains(widget.candado.lugar))
              TextFormField(
                maxLines: null,
                readOnly: !isEditable_2,
                controller: _descripcionSalidaController,
                decoration: decorationTextField(
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

Text  decorationText(String texto)
{
  return Text(texto,style: const TextStyle(color: Colors.black),);
}

InputDecoration decorationTextField({required String text, required bool isEnabled, required VoidCallback onPressed}) {
  return InputDecoration(
    labelText: text,
    suffixIcon: IconButton(
      onPressed: onPressed,
      icon: Icon(isEnabled ? Icons.edit_off : Icons.edit),
    ),
    suffixIconColor: getColorAlmostBlue(),
    labelStyle: TextStyle(
      color: getColorAlmostBlue(),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: getColorAlmostBlue(),
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: getColorAlmostBlue(),
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    filled: true,
    fillColor: Colors.white54,
  );
}
