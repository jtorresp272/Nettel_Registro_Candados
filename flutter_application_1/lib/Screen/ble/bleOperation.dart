// ignore_for_file: camel_case_types

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleNettelTerminal.dart';
import 'package:flutter_application_1/Screen/ble/bleNordicTerminal.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:provider/provider.dart';

class BleOperation extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;
  final bool withBond;

  const BleOperation(
      {super.key,
      required this.device,
      required this.provider,
      required this.withBond});

  @override
  State<BleOperation> createState() => BleOperationState();
}

class BleOperationState extends State<BleOperation> {
  late BleDevice device;
  late BleProvider provider;
  late bool withBond;
  bool isConnected = false;

  final GlobalKey<BleNordicTerminalPageState> bleNordicTerminalKey =
      GlobalKey<BleNordicTerminalPageState>();

  final GlobalKey<BleNettelTerminalPageState> bleNettelTerminalKey =
      GlobalKey<BleNettelTerminalPageState>();

  StreamSubscription<List<int>>? _notificationNettelSubscription;
  StreamSubscription<List<int>>? _notificationNordicSubscription;
  int intentcount = 0;

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = Provider.of<BleProvider>(context, listen: false);
    withBond = widget.withBond;
    _connectToDevice();
  }

  @override
  void dispose() {
    _notificationNettelSubscription?.cancel();
    _notificationNordicSubscription?.cancel();
    provider.stopReconnection(); // detener la reconexión al salir
    super.dispose();
  }

  /* Mensajes para el terminal de ambas caracteristicas */
  void connectedMessage() {
    setState(() {
      provider.addMessage(Message('Conectado a ${device.name}',
          MessageType.process, CharacteristicType.both));
    });
  }

  void connectingMessage() {
    setState(() {
      provider.addMessage(Message(
          'Conectando...', MessageType.process, CharacteristicType.both));
    });
  }

  void disconnectedMessage() {
    setState(() {
      provider.addMessage(Message(
          'Desconectado', MessageType.process, CharacteristicType.both));
    });
  }

  /* Funcion para conectarse con el dispositivo ble */
  Future<void> _connectToDevice() async {
    bool connected = await provider.connectToDevice(device, withBond);
    if (connected) {
      resubscribeToNettelNotifications(device);
      connectedMessage();
    } else {
      disconnectedMessage();
    }

    setState(() {});
  }

  // Reconexion con el dispositivo
  Future<void> _reconnect() async {
    connectingMessage();
    await provider.reconnectToDevice().then((newdevice) {
      if (mounted) {
        setState(() {
          if (newdevice != null) {
            device = newdevice;
            resubscribeToNettelNotifications(newdevice);

            connectedMessage();
          }
        });
      }
    });
  }

  /* Funcion para recibir informacion de la caracteristica ble del dispositivo */
  void _subscribeToNotifications(BleDevice newDevice) {
    _notificationNettelSubscription =
        provider.subscribeToNettelCharacteristic(newDevice).listen((data) {
      setState(() {
        provider.addMessage(Message(utf8.decode(data), MessageType.received,
            CharacteristicType.nettel));
      });

      bleNettelTerminalKey.currentState?.scrollToBottom();
    }, onError: (error) {
      logger.e('Error subscribing to notifications: $error');
    });

    _notificationNordicSubscription =
        provider.subscribeToNordicCharacteristic(newDevice).listen((data) {
      setState(() {
        provider.addMessage(Message(utf8.decode(data), MessageType.received,
            CharacteristicType.nordic));
      });

      bleNordicTerminalKey.currentState?.scrollToBottom();
    }, onError: (error) {
      logger.e('Error subscribing to notifications: $error');
    });
  }

  // Funcion para volverse a subscribir a las notificaciones de las caracteristicas
  Future<void> resubscribeToNettelNotifications(BleDevice newDevice) async {
    _notificationNettelSubscription?.cancel;
    _notificationNordicSubscription?.cancel;
    device = newDevice;
    try {
      await provider.flutterReactiveBle.discoverAllServices(device.id);

      _subscribeToNotifications(device);
    } catch (e) {
      logger.e('Service discovery failed: $e');
      intentcount++;
      if (intentcount < 3) {
        await Future.delayed(const Duration(seconds: 2));
        resubscribeToNettelNotifications(device);
      }
    }
  }

  // Desconectar del dispositivo y salir de la pantalla
  Future<void> _disconnectAndNavigate() async {
    if (provider.isConnected) {
      await provider.disconnectFromDevice();
    }

    provider.stopReconnection();
    provider.clearMessage();
    Navigator.popAndPushNamed(context, '/bleConexion');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disconnectAndNavigate();
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: getColorAlmostBlue(),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  device.id,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            leadingWidth: 35.0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconButton(
                onPressed: _disconnectAndNavigate,
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              Consumer<BleProvider>(builder: (context, provider, child) {
                bool isConnected = provider.isConnected;
                bool reconnection = provider.reconnection;
                return TextButton(
                  onPressed: () async {
                    // Si esta conectado saldra la palabra desconectar
                    if (isConnected) {
                      await provider.disconnectFromDevice();
                      disconnectedMessage();
                    } else {
                      await _reconnect();
                    }
                  },
                  child: isConnected
                      ? const Text(
                          'Desconectar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold),
                        )
                      : reconnection
                          ? const Text(
                              'Conectar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: BorderSide.strokeAlignOutside,
                            ),
                );
              }),
            ],
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: 'Nordic',
                ),
                Tab(
                  text: 'Nettel',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildNordicTab(),
              _buildNettelTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNettelTab() {
    return Center(
      child: BleNettelTerminalPage(
        key: bleNettelTerminalKey,
        device: device,
        provider: provider,
      ),
    );
  }

  Widget _buildNordicTab() {
    return Center(
        child: BleNordicTerminalPage(
      key: bleNordicTerminalKey,
      device: device,
      provider: provider,
    ));
  }
}
