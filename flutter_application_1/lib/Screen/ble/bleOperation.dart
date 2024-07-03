// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleNettelTerminal.dart';
import 'package:flutter_application_1/Screen/ble/bleNordicTerminal.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
  //bool reconnection = false;
  final GlobalKey<BleTerminalPageState> bleTerminalKey =
      GlobalKey<BleTerminalPageState>();

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
    provider.stopReconnection(); // detener la reconexión al salir
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    bleTerminalKey.currentState?.connectingMessage();
    bool connected = await provider.connectToDevice(device, withBond);
    if (connected) {
      bleTerminalKey.currentState?.resubscribeToNotifications(device);
      bleTerminalKey.currentState?.connectedMessage();
    } else {
      bleTerminalKey.currentState?.desconnectedMessage();
    }

    setState(() {});
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
    bleTerminalKey.currentState?.connectingMessage();
    await provider.reconnectToDevice().then((newdevice) {
      if (mounted) {
        setState(() {
          if (newdevice != null) {
            //provider.reconnection = true;
            device = newdevice;
            bleTerminalKey.currentState?.resubscribeToNotifications(device);
            logger.w('reconexión ${device.id}');
            bleTerminalKey.currentState?.connectedMessage();
          } else {
            //provider.reconnection = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disconnectAndNavigate();
        return false;
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
              Consumer<BleProvider>(builder: (context, provider, child) {
                bool isConnected = provider.isConnected;
                bool reconnection = provider.reconnection;
                return TextButton(
                  onPressed: () async {
                    // Si esta conectado saldra la palabra desconectar
                    if (isConnected) {
                      await provider.disconnectFromDevice();
                      bleTerminalKey.currentState?.desconnectedMessage();
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
          ? BleNettelTerminalPage(device: device, provider: provider)
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
