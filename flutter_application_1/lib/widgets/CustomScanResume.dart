import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Funciones/obtener_datos_database.dart';
import 'package:intl/intl.dart';

enum EstadoCandados
{
  ingresado,
  porIngresar,
  mantenimiento,
  listos,
  danados,
}

class CustomScanResume extends StatefulWidget {
  final Candado candado;
  final EstadoCandados estado;  
  const CustomScanResume({Key? key, required this.candado,required this.estado}) : super(key: key);

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
  bool check_mecanica_rota = false;
  bool check_electronca_falla = false;
  List<bool> buttonOnPressed = [false,false,false,false,false];
  List<String> name = ['Joshue','Oliver','Fabian','Oswaldo','Jordy'];
  Map<String,List<Color>> color = {'V':[Colors.white,Colors.white,Colors.red.shade200,Colors.red.shade300],
  'M':[Colors.white,Colors.white,Colors.yellow.shade200,Colors.yellow.shade300],
  'L':[Colors.white,Colors.white,Colors.green.shade200,Colors.green.shade300],
  'I':[Colors.white,Colors.white,Colors.orange.shade200,Colors.orange.shade300],
  };

  @override
  void initState() {
    super.initState();
    candadoEnLista = (widget.candado.tipo == '') ? false:true;
    if(candadoEnLista)
    {
      imagen = widget.candado.imageTipo;
    }
    else if((widget.candado.tipo.contains('Plastico')))
    {
        imagen = 'assets/images/cc_plastico.png';
    }
    else if(widget.candado.numero.contains('N01'))
    {
        imagen = 'assets/images/candado_cable.png';
    }
    else if(widget.candado.numero.contains('N02'))
    {
        imagen = 'assets/images/candado_U.png';
    }
    else if(widget.candado.numero.contains('N03'))
    {
        imagen = 'assets/images/candado_piston.png';
    }
    else if(widget.candado.tipo.contains('CC_4') || widget.candado.tipo.contains('CC_5'))
    {
        imagen = 'assets/images/CC_5.png';
    }
    else
    {
      imagen = 'assets/images/CC_5.png';
    }
    
    _descripcionIngresoController =
        TextEditingController(text: widget.candado.razonIngreso);
    _descripcionSalidaController =
        TextEditingController(text: widget.candado.razonSalida);
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
              colors:color[widget.candado.lugar] ?? [Colors.white, Colors.grey.shade400, Colors.grey.shade400],
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
                        fit: (imagen.contains('CC_4') || imagen.contains('CC_5'))  ? BoxFit.cover:BoxFit.contain,
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
                      if(widget.estado != EstadoCandados.porIngresar)
                      const SizedBox(height: 10.0,),
                      if(widget.estado != EstadoCandados.porIngresar)
                      TextFormField(
                        maxLines: null,
                        controller: _descripcionSalidaController,
                        decoration: decorationTextField(text: 'Descripción de salida'),
                      ),
                      if(widget.estado != EstadoCandados.porIngresar)
                      const SizedBox(height: 10.0,),
                      if(widget.estado != EstadoCandados.porIngresar)
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
                          child: Stack(
                            children: [
                              Positioned(
                                top: -5.0, // Ajusta la posición vertical del texto
                                left: 4.0, // Ajusta la posición horizontal del texto
                                child: Container(
                                  color: Colors.white, // Color del fondo del texto
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
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      // CheckBox de electronica y mecanica dañada
                      customCheckBox(
                        name: "Mecanica Dañada:  ", 
                        onPressed:(bool? value){
                          setState(() {
                            check_mecanica_rota = value ?? false;
                          });
                        },
                        isPressed: check_mecanica_rota,
                      ),
                      customCheckBox(
                        name: "Electronica Dañada:", 
                        onPressed:(bool? value){
                          setState(() {
                            check_electronca_falla = value ?? false;
                          });
                        },
                        isPressed: check_electronca_falla,
                      ),
                    ],
                  ),
                ),
                // Botones
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(  
                          style: ElevatedButton.styleFrom(
                            elevation: 5, // Ajusta el valor según el efecto de sombra deseado
                            // Otros estilos como colores, márgenes, etc.
                            foregroundColor: Colors.transparent,
                            backgroundColor: Colors.white,
                            shadowColor: getColorAlmostBlue(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            minimumSize:  Size(MediaQuery.of(context).size.width*0.7, MediaQuery.of(context).size.height*0.06),
                            maximumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.1),
                          ),
                          onPressed: () {
                          // Acción del botón
                            _saveChanges();
                          },
                          child: Text(
                            widget.estado != EstadoCandados.porIngresar ?
                            "Guardar y actualizar":"Ingresar y actualizar",
                            style: TextStyle(
                              color: getColorAlmostBlue(),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0,),
                      GestureDetector(
                        onTap: (){
                          _saveChanges();
                        },
                        child: Text(
                          widget.estado != EstadoCandados.porIngresar ?
                          'Guardar y seguir escaneando':'Ingresar y seguir escaneando',
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
    switch(widget.estado)
    {
      case EstadoCandados.ingresado:
      break;
      case EstadoCandados.porIngresar:
      break;
      case EstadoCandados.mantenimiento:
      break;
      case EstadoCandados.listos:
      break;
      case EstadoCandados.danados:
      break;
      default:
      break;
    }
    //cerraremos el diálogo
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

class customCheckBox extends StatelessWidget{
  final String name;
  final Function(bool?) onPressed;
  final bool isPressed;

  const customCheckBox({
    Key? key,
    required this.name,
    required this.onPressed,
    required this.isPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
            color: getColorAlmostBlue(),
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Checkbox(
        fillColor:MaterialStateColor.resolveWith((states) => isPressed ? getColorAlmostBlue():Colors.white),
        side: BorderSide.none,
        value: isPressed, 
        onChanged: (value){
          onPressed(value);
        },
        ),
      ],
    );
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
