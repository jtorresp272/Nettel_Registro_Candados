import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleConnectionHandler.dart';
import 'package:flutter_application_1/Screen/ble/communicationHandler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

bool isBleEnabled = false;

class bleConexion extends StatefulWidget {
  const bleConexion({super.key});

  @override
  State<bleConexion> createState() => _bleConexionState();
}

class _bleConexionState extends State<bleConexion> {
  // Variable para usar el bluetooth
  CommunicationHandler? communicationHandler;
  List<DiscoveredDevice> discoveredDevices =
      List<DiscoveredDevice>.empty(growable: true);
  bool isScanStarted = false;
  bool isConnected = false;
  String connectedDeviceDetails = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: getColorAlmostBlue(),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consorcio Nettel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bluetooth',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          leadingWidth: 35.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/taller');
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 25.0,
              ),
            ),
          ),
          actions: [
            if (isBleEnabled)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: TextButton(
                  onPressed: () {
                    isScanStarted ? stopScan() : startScan();
                  },
                  child: Text(
                    isScanStarted ? 'Detener' : 'Escanear',
                    style: TextStyle(
                      color: isScanStarted ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
        body: Column(
          children: [
            // Linea de división
            if (!isBleEnabled)
              const Divider(
                color: Colors.white,
                height: 1.0,
              ),
            // Activar ble
            if (!isBleEnabled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                color: const Color.fromARGB(255, 104, 95, 95),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tu bluetooth esta desactivado',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await BluetoothHelper.enableBluetooth();
                        checkBleStatus();
                      },
                      child: const Text(
                        'Activar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            // Linea de división
            const Divider(
              color: Colors.white,
              height: 1.0,
            ),
            // Activar ubicación
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              color: const Color.fromARGB(255, 104, 95, 95),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tu Ubicación esta desactivada',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await BluetoothHelper.enableBluetooth();
                      checkBleStatus();
                    },
                    child: const Text(
                      'Activar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Lista de dispositivos activados
            Expanded(
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: discoveredDevices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: getColorAlmostBlue(),
                            width: 2.0,
                          )),
                          child: Center(
                              child: TextButton(
                            child: Text(
                              discoveredDevices[index].name,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              DiscoveredDevice selectedDevice =
                                  discoveredDevices[index];
                              connectToDevice(selectedDevice);
                            },
                          )),
                        ),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                connectedDeviceDetails,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ));
  }

  @override
  void initState() {
    checkPermissions();
    checkBleStatus();
    super.initState();
  }

  Future<void> checkBleStatus() async {
    bool isEnable = await BluetoothHelper.isBluetoothEnabled();
    logger.i(isEnable);
    setState(() {
      isBleEnabled = isEnable;
    });
  }

  void checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.bluetoothAdvertise,
    ].request();

    logger.i("PermissionsStatus -- $statuses");
  }

  void startScan() {
    communicationHandler ??= CommunicationHandler();
    communicationHandler?.startScan((scanDevice) {
      logger.i("Scan device: ${scanDevice.name}");
      if (discoveredDevices
              .firstWhereOrNull((val) => val.id == scanDevice.id) ==
          null) {
        logger.i("Added new device to list: ${scanDevice.name}");
        setState(() {
          discoveredDevices.add(scanDevice);
        });
      }
    });

    setState(() {
      isScanStarted = true;
      discoveredDevices.clear();
    });
  }

  Future<void> stopScan() async {
    await communicationHandler?.stopScan();
    setState(() {
      isScanStarted = false;
    });
  }

  Future<void> connectToDevice(DiscoveredDevice selectedDevice) async {
    await stopScan();
    communicationHandler?.connectToDevice(selectedDevice, (isConnected) {
      this.isConnected = isConnected;
      if (isConnected) {
        connectedDeviceDetails = "Connected Device Details\n\n$selectedDevice";
      } else {
        connectedDeviceDetails = "";
      }
      setState(() {
        connectedDeviceDetails;
      });
    });
  }
}
