// ignore_for_file: camel_case_types

//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleNettelTerminal.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class bleOperation extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const bleOperation({super.key, required this.device, required this.provider});

  @override
  State<bleOperation> createState() => _bleOperationState();
}

class _bleOperationState extends State<bleOperation> {
  late BleDevice device;
  late BleProvider provider;
  bool isConnected = false;
  bool reconnection = false;
  final GlobalKey<BleTerminalPageState> bleTerminalKey =
      GlobalKey<BleTerminalPageState>();

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = widget.provider;
    _connectToDevice();
  }

  @override
  void dispose() {
    provider.stopReconnection(); // detener la reconexión al salir
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    await provider.connectToDevice(device).then((connected) {
      //provider.requestMTU(device);
      //bleTerminalKey.currentState?.resubscribeToNotifications(device);
      if (connected) {
        bleTerminalKey.currentState?.resubscribeToNotifications(device);
      }
      setState(() {
        //isConnected = connected;
      });
    });
  }

  Future<void> _disconnectAndNavigate() async {
    if (provider.isConnected) {
      await provider.disconnectFromDevice();
    }

    provider.stopReconnection();
    provider.clearMessage();
    Navigator.popAndPushNamed(context, '/bleConexion');
  }

  Future<void> _reconnect() async {
    await provider.reconnectToDevice().then((newdevice) {
      if (mounted) {
        setState(() {
          if (newdevice != null) {
            reconnection = true;
            device = newdevice;
            bleTerminalKey.currentState?.resubscribeToNotifications(device);
            logger.w('reconexión');
          } else {
            reconnection = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        if (isConnected) {
          await _disconnectAndNavigate();
          return;
        }
      },
      child: DefaultTabController(
        length: 3,
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
              TextButton(
                onPressed: () async {
                  // Si esta conectado saldra la palabra desconectar
                  if (provider.isConnected) {
                    await provider.disconnectFromDevice();
                    setState(() {
                      reconnection = true;
                    });
                  } else {
                    setState(() {
                      reconnection = false;
                    });
                    await _reconnect();
                  }
                },
                child: provider.isConnected
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
              ),
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
                Tab(
                  text: 'Extras',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildNordicTab(),
              _buildNettelTab(),
              _buildExtraTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraTab() {
    return Center(
      child: isConnected
          ? FutureBuilder<List<DiscoveredService>>(
              future: provider.flutterReactiveBle.discoverServices(device.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No services found'),
                  );
                } else {
                  return ListView(
                    children: snapshot.data!.map((service) {
                      String nameService =
                          provider.getServiceName(service.serviceId);

                      return nameService.contains('Generic') ||
                              nameService.contains('DFU')
                          ? ExpansionTile(
                              childrenPadding:
                                  const EdgeInsets.only(left: 20.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nameService,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${service.serviceId}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 13.0),
                                  ),
                                ],
                              ),
                              children:
                                  service.characteristics.map((characteristic) {
                                return ListTile(
                                  title: Text(
                                    'Characteristic: ${characteristic.characteristicId}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  //subtitle:
                                  //    Text('Properties: ${characteristic.properties}'),
                                );
                              }).toList(),
                            )
                          : const SizedBox.shrink();
                    }).toList(),
                  );
                }
              },
            )
          : const Text('No data available'),
    );
  }

  Widget _buildNettelTab() {
    return Center(
      child: provider.isConnected
          ? Text('Data from ${device.name}')
          : const Text('No data available'),
    );
  }

  Widget _buildNordicTab() {
    return Center(
        child: BleTerminalPage(
      key: bleTerminalKey,
      device: device,
      provider: provider,
    ));
  }
}
