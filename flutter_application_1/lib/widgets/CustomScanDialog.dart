import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:intl/intl.dart';

class CustomScanDialog extends StatefulWidget {
  final Candado candado;

  const CustomScanDialog({Key? key, required this.candado}) : super(key: key);

  @override
  _CustomScanDialogState createState() => _CustomScanDialogState();
}

class _CustomScanDialogState extends State<CustomScanDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool candadoEnLista = false;
  late String imagen;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    candadoEnLista = (widget.candado.tipo == '') ? false:true;
    if(candadoEnLista)
    {
      imagen = widget.candado.imageTipo;
    }else{
      if(widget.candado.numero.length== 4 ||widget.candado.numero.length== 5){
        imagen = 'assets/images/CC_5.png';
      }else if(widget.candado.numero.contains('N01'))
      {
        imagen = 'assets/images/candado_cable.png';
      }else if(widget.candado.numero.contains('N02'))
      {
        imagen = 'assets/images/candado_U.png';
      }else if(widget.candado.numero.contains('N03'))
      {
        imagen = 'assets/images/candado_piston.png';
      }
    }
    _descripcionIngresoController =
        TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController =
        TextEditingController(text: widget.candado.razonSalida);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duración de la animación
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward(); // Iniciar la animación al abrir el diálogo
  }

  @override
  Widget build(BuildContext context) {
    String? _selectedValue;

    return ScaleTransition(
      scale: _animation, // Aplicar escala según la animación
      child: AlertDialog(
        title: Column(
          children: [
            Image.asset(
              imagen,
              fit: (widget.candado.tipo == 'CC_5' || widget.candado.tipo == 'CC_4') ? BoxFit.cover:BoxFit.contain,
              height: 110.0,
              width: 200.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.candado.numero,
              style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(DateFormat('yyyy-MM-dd').format(widget.candado.fechaIngreso),style: const TextStyle(fontSize: 20.0),),
          ],
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 220, // Altura mínima del contenido
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0,),
                (widget.candado.responsable != '') ? decorationText("Responsable: ${widget.candado.responsable}"):const SizedBox(height: 10.0,),
                TextFormField(
                  maxLines: null,
                  controller: _descripcionIngresoController,
                  decoration: decorationTextField(text: 'Descripción de ingreso'),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  maxLines: null,
                  controller: _descripcionSalidaController,
                  decoration: decorationTextField(text: 'Descripción de salida'),
                ),
    
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSelected = !_isSelected;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: getColorAlmostBlue(), width: 2.0),
                            color: _isSelected ? Colors.green : Colors.transparent,
                          ),
                          child: _isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16.0,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                          'Opción 1',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _animationController.reverse().then((_) {
                Navigator.of(context).pop(); // Cerrar el diálogo al finalizar la animación de salida
              });
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

InputDecoration decorationTextField({required String text})
{
  return InputDecoration(
      labelText: text,
      labelStyle: TextStyle(
      color: getColorAlmostBlue()
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
          color: getColorAlmostBlue()
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
