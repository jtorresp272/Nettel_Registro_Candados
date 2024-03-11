import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:intl/intl.dart';

class CustomScanResume extends StatefulWidget {
  final Candado candado;

  const CustomScanResume({Key? key, required this.candado}) : super(key: key);

  @override
  _CustomScanResumeState createState() => _CustomScanResumeState();
}

class _CustomScanResumeState extends State<CustomScanResume> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  late TextEditingController _descripcionIngresoController;
  late TextEditingController _descripcionSalidaController;
  bool candadoEnLista = false;
  late String imagen;
  List<bool> buttonOnPressed = [false,false,false,false,false];
  List<String> name = ['Joshue','Oliver','Fabian','Oswaldo','Jordy'];

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
      duration: const Duration(milliseconds: 1000),
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            _animationController.reverse().then((_) {
              Navigator.of(context).pop();
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    backgroundColor: Colors.transparent, // Para que el fondo del Scaffold sea transparente
    body: Align(
      alignment: Alignment.bottomLeft,
      child: SlideTransition(
        position: _animation,
        child: Container(
          height: MediaQuery.of(context).size.height, // Tamaño completo de la pantalla
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
                Colors.red.shade200,
                Colors.red.shade300,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titulo
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Image.asset(
                        imagen,
                        fit: (widget.candado.tipo == 'CC_5' || widget.candado.tipo == 'CC_4') ? BoxFit.fitWidth:BoxFit.contain,
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
                    Center(child: Text(DateFormat('yyyy-MM-dd').format(widget.candado.fechaIngreso),style: const TextStyle(fontSize: 20.0),)),
                  ],
                ),
              ), 
              const SizedBox(height: 10.0,),
              (widget.candado.responsable != '') ? decorationText("Responsable: ${widget.candado.responsable}"):const SizedBox(height: 10.0,),
              // Body
              Expanded(
                flex: 3,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 5.0),
                  children: [
                      TextFormField(
                        autofocus: true, // Para que este campo tenga el foco cuando la pantalla aparezca
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
                      const SizedBox(height: 10.0,),
                      Text(
                        'Responsable:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: getColorAlmostBlue(),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: getColorAlmostBlue(),
                          )
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RowWithButton(
                                name: [name[0],name[1],name[2]],
                                onPressed:[
                                  () {
                                    setState(() {
                                      buttonOnPressed = List.generate(buttonOnPressed.length, (index) => index == 0 ? !buttonOnPressed[0] : false);
                                    });
                                  },
                                  () {
                                    setState(() {
                                      buttonOnPressed = List.generate(buttonOnPressed.length, (index) => index == 1 ? !buttonOnPressed[1] : false);
                                    });
                                  },
                                  () {
                                    setState(() {
                                      buttonOnPressed = List.generate(buttonOnPressed.length, (index) => index == 2 ? !buttonOnPressed[2] : false);
                                    });
                                  },
                                ],
                                isPressed: [buttonOnPressed[0],buttonOnPressed[1],buttonOnPressed[2]],
                              ),
                              RowWithButton(
                                name: [name[3],name[4]],
                                onPressed:[
                                  () {
                                    setState(() {
                                      buttonOnPressed = List.generate(buttonOnPressed.length, (index) => index == 3 ? !buttonOnPressed[3] : false);
                  
                                    });
                                  },
                                  () {
                                    setState(() {
                                      buttonOnPressed = List.generate(buttonOnPressed.length, (index) => index == 4 ? !buttonOnPressed[4] : false);
                                    });
                                  },
                                ],
                                isPressed: [buttonOnPressed[3],buttonOnPressed[4]],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5, // Ajusta el valor según el efecto de sombra deseado
                            // Otros estilos como colores, márgenes, etc.
                            foregroundColor: Colors.transparent,
                            backgroundColor: getColorAlmostBlue(),
                            shadowColor: getColorAlmostBlue(),
                          ),
                          onPressed: () {
                          // Acción del botón
                          },
                          child: const Text(
                            "Guardar y actualizar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0,),
                      GestureDetector(
                        onTap: (){},
                        child: Text(
                          'Guardar y seguir escaneando',
                          textAlign: TextAlign.center,
                          style: TextStyle(  
                            color: getColorAlmostBlue(),
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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


class RowWithButton extends StatelessWidget {
  final List<String> name;
  final List<VoidCallback> onPressed;
  final List<bool> isPressed;

  const RowWithButton({
    Key? key,
    required this.name,
    required this.onPressed,
    required this.isPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(name.length, (index) {
        return InkWell(
          onTap: () {
            onPressed[index]();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: getColorAlmostBlue(), width: 2.0),
                  ),
                  child: Center(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent),
                        color: isPressed[index]
                            ? getColorAlmostBlue()
                            : getBackgroundColor(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  name[index],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: getColorAlmostBlue(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
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
      fillColor: Colors.white,
  );
}
