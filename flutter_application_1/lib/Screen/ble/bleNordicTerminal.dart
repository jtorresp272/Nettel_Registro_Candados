import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:provider/provider.dart';

class BleNordicTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const BleNordicTerminalPage(
      {Key? key, required this.device, required this.provider})
      : super(key: key);

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
                    final message = provider.messages[index];
                    if (message.characteristic == CharacteristicType.nordic ||
                        message.characteristic == CharacteristicType.both) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          provider.messages[index].characteristic ==
                                      CharacteristicType.both ||
                                  provider.messages[index].characteristic ==
                                      CharacteristicType.nordic
                              ? provider.messages[index].content.trim()
                              : '',
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
                      const SizedBox.shrink();
                    }
                  },
                );
              }),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10.0),
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
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Comando'),
                            labelStyle: TextStyle(color: Colors.black54),
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
                        height: 60.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                              _controller.clear();
                            }
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
