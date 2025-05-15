import 'package:flutter/material.dart';

import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
import 'package:flutter_application_1/widgets/ble/CustomDropMenu.dart';

class Json {
  String key;
  String valor;

  Json({required this.key, required this.valor});

// Para poder visulizar los datos dentro del json
  @override
  String toString() {
    return '"$key": $valor';
  }

  // Para poder hacer comparaciones si existe un json en una lista o no
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Json && other.key == key;
  }

  // para que el hasCode sea valido como ==
  @override
  int get hashCode => key.hashCode;
}

List<Json> jsonList = [];

class SelectionWidget extends StatefulWidget {
  final ValueChanged<String> addValue;
  const SelectionWidget({
    super.key,
    required this.addValue,
  });

  @override
  State<SelectionWidget> createState() => SelectionWidgetState();
}

class SelectionWidgetState extends State<SelectionWidget> {
  final TextEditingController controllerClave = TextEditingController();
  final TextEditingController controllerValor = TextEditingController();
  TextInputType teclado = TextInputType.name;
  int indexView = 0;
  // Variable json para poder agregar los valores a solicitar
  Json json = Json(key: '', valor: '');
  List<String> jsonStrings = ['eKey', 'secret', 'iv', 'imei', 'gps', 'sensors'];
  bool isConfig = false;

  @override
  void dispose() {
    super.dispose();
    jsonList.clear();
    indexView = 0;
  }

  // Actualizar campos de clave y valor
  void updateField(int item) {
    controllerClave.text = jsonList[item].key;
    String preValue = jsonList[item].valor;
    if (jsonStrings.contains(jsonList[item].key)) {
      preValue = preValue.replaceAll('"', '');
    }
    controllerValor.text = preValue;

    teclado = selectTypeKeyboard(controllerClave.text = jsonList[item].key);
  }

  // Agregar valor al json
  void addToJson(String key, String value) {
    // check si el key se encuentra en el listado para determinar si el dato debe ser String o no
    if (jsonStrings.contains(key)) {
      value = '"$value"';
    }
    Json json = Json(key: key, valor: value);
    // Buscar si el inidice del objeto existe basandose en la clave
    int index = jsonList.indexWhere((element) => element.key == json.key);

    if (index != -1) {
      // Reemplazar
      jsonList[index] = json;
    } else {
      // Agregar
      jsonList.add(json);
    }
  }

  // Remover valores del json
  void removeFromJson(String key, String value) {
    Json json = Json(key: key, valor: value);
    // Buscar si el inidice del objeto existe basandose en la clave
    int index = jsonList.indexWhere((element) => element.key == json.key);

    if (index != -1) {
      // Eliminar
      jsonList.removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                const Text(
                  'Configuración',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isConfig = !isConfig;
                      addToJson('config', isConfig.toString());
                      if (controllerClave.text == 'config') {
                        controllerValor.text = isConfig.toString();
                      }
                      // Enviar la lista actualizada
                      widget.addValue('$jsonList');
                    });
                  },
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isConfig ? getColorAlmostBlue() : Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: Text(
                    isConfig
                        ? 'Se configurara los valores de las opciones agregadas'
                        : 'Se solicitara información de las opciones agregadas',
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: const Text(
                    'Opciones',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    'Seleccionadas (${jsonList.length})',
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: customDrop(
                    selection: (value) {
                      setState(() {
                        controllerClave.text = value;
                        json.key = value;
                        teclado = selectTypeKeyboard(value);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Hacia la izquierda
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (jsonList.isNotEmpty) {
                                  setState(() {
                                    if (indexView == 0) {
                                      indexView = jsonList.length - 1;
                                    } else {
                                      indexView--;
                                    }
                                    updateField(indexView);
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.arrow_left_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // Hacia la derecha
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (jsonList.isNotEmpty) {
                                  setState(() {
                                    if (indexView < jsonList.length - 1) {
                                      indexView++;
                                    } else {
                                      indexView = 0;
                                    }

                                    updateField(indexView);
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.arrow_right_outlined,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 3.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            jsonList.isNotEmpty ? '${jsonList[indexView]}' : '',
                            style: const TextStyle(color: Colors.black),
                          ),
                          // Eliminar un key
                          GestureDetector(
                            onTap: () {
                              if (jsonList.isNotEmpty) {
                                setState(() {
                                  removeFromJson(jsonList[indexView].key,
                                      jsonList[indexView].valor);
                                  if (jsonList.isNotEmpty) {
                                    indexView = jsonList.length - 1;
                                  } else {
                                    indexView = 0;
                                  }
                                  widget.addValue('$jsonList');
                                });
                              }
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 50.0,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllerClave,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        label: Text('clave'),
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controllerValor,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: teclado,
                      decoration: const InputDecoration(
                        label: Text('Valor'),
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    height: 50.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (controllerValor.text.isNotEmpty) {
                          json.key = controllerClave.text;
                          json.valor = controllerValor.text;
                          if (checkValue(json)) {
                            addToJson(json.key, json.valor);
                            if (json.key == 'config') {
                              if (json.valor == 'true') {
                                isConfig = true;
                              } else {
                                isConfig = false;
                              }
                            }
                            setState(() {
                              widget.addValue('$jsonList');
                            });
                          } else {
                            customSnackBar(context,
                                mensaje:
                                    'verifique el valor ingresado en Valor',
                                colorFondo: Colors.red);
                          }
                        } else {
                          customSnackBar(context,
                              mensaje: 'Completar el campo Valor',
                              colorFondo: Colors.red);
                        }
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

TextInputType selectTypeKeyboard(String value) {
  return switch (value) {
    'config' => TextInputType.text,
    'proximity' => TextInputType.text,
    'open' => TextInputType.text,
    'claveM' => TextInputType.number,
    'claveA' => TextInputType.number,
    'time' => TextInputType.number,
    'eKey' => TextInputType.name,
    'secret' => TextInputType.name,
    'iv' => TextInputType.name,
    'imei' => TextInputType.name,
    'gps' => TextInputType.name,
    'sensors' => TextInputType.name,

    // TODO: Handle this case.
    String() => throw UnimplementedError(),
  };
}

bool checkValue(Json json) {
  if (json.key == 'claveM' || json.key == 'claveA') {
    if (json.valor.length != 5) {
      return false;
    }

    for (int i = 0; i < json.valor.length; i++) {
      int digit = int.parse(json.valor[i]);
      if (digit > 4) {
        return false;
      }
    }
    return true;
  } else if (json.key == 'time') {
    if (int.parse(json.valor) >= 10) {
      return true;
    }
    return false;
  } else if (json.key == 'proximity' ||
      json.key == 'open' ||
      json.key == 'config') {
    if (json.valor == 'true' || json.valor == 'false') {
      return true;
    }
    return false;
  } else if (json.key == 'eKey' ||
      json.key == 'secret' ||
      json.key == 'iv' ||
      json.key == 'imei' ||
      json.key == 'gps' ||
      json.key == 'sensors') {
    return true;
  }
  return false;
}
