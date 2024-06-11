import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';

enum MessageType { sent, received }

class Message {
  final String content;
  final MessageType type;

  Message(this.content, this.type);
}

class BleTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const BleTerminalPage(
      {Key? key, required this.device, required this.provider})
      : super(key: key);

  @override
  _BleTerminalPageState createState() => _BleTerminalPageState();
}

/* La clave esta con AutomaticKeepAliveClientMixin es para poder seguir visualizando la información al cambiar la pantalla */
class _BleTerminalPageState extends State<BleTerminalPage>
    with AutomaticKeepAliveClientMixin {
  late BleDevice device;
  late BleProvider provider;
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription<List<int>> _notificationSubscription;
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = widget.provider;
    _subscribeToNotifications();
    _requestMTU();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Future.delayed(const Duration(milliseconds: 100), () {
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

  /* Solicita espacio para obtener mas datos */
  void _requestMTU() {
    provider.requestMTU(device);
  }

  /* Funcion para recibir informacion de la caracteristica ble del nordic */
  void _subscribeToNotifications() {
    _notificationSubscription =
        provider.subscribeToNordicCharacteristic(device).listen((data) {
      setState(() {
        _messages
            .add(Message(String.fromCharCodes(data), MessageType.received));
      });
      _scrollToBottom();
    }, onError: (error) {
      logger.e('Error subscribing to notifications: $error');
    });
  }

  Future<void> _sendMessage(String message) async {
    // Convert message to bytes and write to the characteristic
    final List<int> commandBytes = message.codeUnits;

    //logger.w('mensaje: $message comando: $commandBytes');
    await provider.writeNordicCharacteristic(device, commandBytes);

    setState(() {
      _messages.add(Message(message, MessageType.sent));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _messages[index].content.trim(),
                      style: TextStyle(
                        color: _messages[index].type == MessageType.sent
                            ? Colors.blue
                            : Colors.green,
                        fontSize: 12.0,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Comando',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
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
