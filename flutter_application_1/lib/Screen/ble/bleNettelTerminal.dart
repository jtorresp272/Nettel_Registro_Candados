import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:provider/provider.dart';

class BleTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const BleTerminalPage(
      {Key? key, required this.device, required this.provider})
      : super(key: key);

  @override
  BleTerminalPageState createState() => BleTerminalPageState();
}

/* La clave esta con AutomaticKeepAliveClientMixin es para poder seguir visualizando la información al cambiar la pantalla */
class BleTerminalPageState extends State<BleTerminalPage>
    with AutomaticKeepAliveClientMixin {
  late BleDevice device;
  late BleProvider provider;
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<List<int>>? _notificationSubscription;
  final ScrollController _scrollController = ScrollController();
  int intentcount = 0; // variable parar reintentar subscribirse

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = widget.provider;
    //resubscribeToNotifications(device);
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

  /* Funcion para recibir informacion de la caracteristica ble del nordic */
  void _subscribeToNotifications(BleDevice newDevice) {
    _notificationSubscription =
        provider.subscribeToNordicCharacteristic(newDevice).listen((data) {
      setState(() {
        provider.addMessage(Message(utf8.decode(data), MessageType.received));
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
      provider.addMessage(Message(message, MessageType.sent));
    });

    _scrollToBottom();
  }

  Future<void> resubscribeToNotifications(BleDevice newDevice) async {
    _notificationSubscription?.cancel;

    try {
      // verificar si existen servicios antes de subscribirse a una caracteristica
      await provider.flutterReactiveBle.discoverServices(device.id);
      _subscribeToNotifications(newDevice);
    } catch (e) {
      logger.e('Service discovery failed: $e');
      intentcount++;
      if (intentcount < 2) {
        resubscribeToNotifications(newDevice);
      }
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
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
            Text(
              provider.isConnected ? 'Conectado' : 'Desconectado',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      provider.messages[index].content.trim(),
                      style: TextStyle(
                        color: provider.messages[index].type == MessageType.sent
                            ? Colors.blue
                            : Colors.green,
                        fontSize: 10.0,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: SizedBox(
                height: 50.0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Comando',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          border: OutlineInputBorder(),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}