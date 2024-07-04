import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_application_1/widgets/ble/CustomSelection.dart';
import 'package:provider/provider.dart';

class BleNettelTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;
  const BleNettelTerminalPage(
      {super.key, required this.device, required this.provider});

  @override
  State<BleNettelTerminalPage> createState() => BleNettelTerminalPageState();
}

class BleNettelTerminalPageState extends State<BleNettelTerminalPage>
    with AutomaticKeepAliveClientMixin {
  late BleDevice device;
  late BleProvider provider;
  bool moreAction = false;
  final TextEditingController _controllerSend = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int intentcount = 0; // variable parar reintentar subscribirse

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = Provider.of<BleProvider>(context, listen: false);
    //provider = widget.provider;
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

/* Enviar mensajes a la caracteristica de nettel */
  Future<void> _sendMessage(String message) async {
    // Convert message to bytes and write to the characteristic
    final List<int> commandBytes = message.codeUnits;

    await provider.writeNettelCharacteristic(device, commandBytes);

    setState(() {
      provider.addMessage(
          Message(message, MessageType.sent, CharacteristicType.nettel));
    });

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Consumer<BleProvider>(builder: (context, provider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    if (message.characteristic == CharacteristicType.nettel ||
                        message.characteristic == CharacteristicType.both) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          provider.messages[index].content.trim(),
                          style: TextStyle(
                            color: provider.messages[index].type ==
                                    MessageType.sent
                                ? Colors.blue
                                : provider.messages[index].type ==
                                        MessageType.process
                                    ? Colors.amber
                                    : Colors.green,
                            fontSize: 10.0,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prompt
                    SizedBox(
                      height: 60.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllerSend,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12.0),
                              decoration: const InputDecoration(
                                label: Text('Comando'),
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
                            height: 56.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sendMessage(_controllerSend.text);
                                });
                              },
                              child: const Icon(
                                Icons.send,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            height: 56.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  moreAction = !moreAction;
                                });
                              },
                              child: Icon(
                                moreAction
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: moreAction,
                      child: SelectionWidget(
                        addValue: (String value) {
                          _controllerSend.text =
                              value.replaceAll('[', '{').replaceAll(']', '}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
