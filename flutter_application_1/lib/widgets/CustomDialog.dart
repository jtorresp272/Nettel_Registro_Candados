import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:intl/intl.dart';
import '../Funciones/class_dato_lista.dart';

class CustomCandadoDialog extends StatefulWidget {
  final Candado candado;

  const CustomCandadoDialog({Key? key, required this.candado}) : super(key: key);

  @override
  _CustomCandadoDialogState createState() => _CustomCandadoDialogState();
}

class _CustomCandadoDialogState extends State<CustomCandadoDialog> {
  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;

  @override
  void initState() {
    super.initState();
    _descripcionIngresoController = TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController = TextEditingController(text: widget.candado.razonSalida);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Image.asset(
            widget.candado.image,
            fit: BoxFit.contain,
            height: 100.0,
            //width: 100.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.candado.numero,
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descripcionIngresoController,
            decoration: const InputDecoration(labelText: 'Descripción de ingreso'),
          ),
          TextFormField(
            controller: _descripcionSalidaController,
            decoration: const InputDecoration(labelText: 'Descripción de salida'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cerrar',
            style: TextStyle(
              color: getColorAlmostBlue(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveChanges();
          },
          child: Text(
            'Guardar Cambios',
            style: TextStyle(
              color: getColorAlmostBlue(),
            ),),
        ),
      ],
    );
  }

  void _saveChanges() {
    final String newDescripcionIngreso = _descripcionIngresoController.text;
    final String newDescripcionSalida = _descripcionSalidaController.text;

    // Aquí puedes guardar los cambios o hacer lo que necesites con las descripciones editadas
    // Por ahora, solo cerraremos el diálogo
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _descripcionIngresoController.dispose();
    _descripcionSalidaController.dispose();
    super.dispose();
  }
}
