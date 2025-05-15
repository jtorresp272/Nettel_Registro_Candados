import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:provider/provider.dart';

class BleNordicTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const BleNordicTerminalPage(
      {super.key, required this.device, required this.provider});

  @override
  State<BleNordicTerminalPage> createState() => BleNordicTerminalPageState();
}

/* La clave esta con AutomaticKeepAliveClientMixin es para poder seguir visualizando la información al cambiar la pantalla */
class BleNordicTerminalPageState extends State<BleNordicTerminalPage>
    with AutomaticKeepAliveClientMixin {
  late BleDevice device;
  late BleProvider provider;
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  int intentcount = 0; // variable parar reintentar subscribirse
  bool addCr = false; // Para agregar un salto de linea al final del texto
  bool clearText = true; // Limpiar el texto luego de presionar el boton enviar
  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = Provider.of<BleProvider>(context, listen: false);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    // Convert message to bytes and write to the characteristic
    final List<int> commandBytes = message.codeUnits;
    await provider.writeNordicCharacteristic(device, commandBytes);

    setState(() {
      provider.addMessage(
          Message(message, MessageType.sent, CharacteristicType.nordic));
    });

    scrollToBottom();
  }

  bool isValidMessage(String content) {
    final regex =
        RegExp(r'^[\w\s]+$'); // Solo permite letras, numeros y espacios.
    return content.isNotEmpty;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer<BleProvider>(builder: (context, provider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    try {
                      final message = provider.messages[index];
                      if (message.characteristic == CharacteristicType.nordic ||
                          message.characteristic == CharacteristicType.both) {
                        final content = message.content.trim();

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message.characteristic == CharacteristicType.both ||
                                    message.characteristic ==
                                        CharacteristicType.nordic
                                ? content
                                : '',
                            style: TextStyle(
                              color: message.type == MessageType.sent
                                  ? Colors.blue
                                  : message.type == MessageType.process
                                      ? Colors.amber
                                      : Colors.green,
                              fontSize: 10.0,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } catch (e) {
                      logger.e('Error processing message at index $index: $e');
                      return const SizedBox.shrink();
                    }
                  },
                );
              }),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(
                  height: 60.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      addCr = !addCr;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10.0),
                                    margin: const EdgeInsets.only(right: 5.0),
                                    width: 55.0,
                                    decoration: BoxDecoration(
                                      color: addCr
                                          ? Colors.green
                                          : Colors.transparent,
                                      border: const Border(
                                        right: BorderSide(
                                          color: Colors.black54,
                                          width: 0.5,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'CR+LF',
                                        style: TextStyle(
                                          color: addCr
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      clearText = !clearText;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10.0),
                                    margin: const EdgeInsets.only(right: 5.0),
                                    width: 55.0,
                                    decoration: BoxDecoration(
                                      color: clearText
                                          ? Colors.green
                                          : Colors.transparent,
                                      border: const Border(
                                        right: BorderSide(
                                          color: Colors.black54,
                                          width: 0.5,
                                        ),
                                        top: BorderSide(
                                          color: Colors.black54,
                                          width: 0.5,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'CLEAR',
                                        style: TextStyle(
                                          color: clearText
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            border: const OutlineInputBorder(),
                            hintText: 'Comando',
                            hintStyle: const TextStyle(color: Colors.black54),
                            focusedBorder: const OutlineInputBorder(
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
                        height: 60.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (_controller.text.isNotEmpty) {
                              if (addCr) {
                                _controller.text = '${_controller.text}\r\n';
                              }
                              _sendMessage(_controller.text);
                              if (clearText) {
                                _controller.clear();
                              }
                            }
                          },
                          child: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
