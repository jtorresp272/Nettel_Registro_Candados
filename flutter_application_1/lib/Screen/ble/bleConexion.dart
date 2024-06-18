import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleOperation.dart';
import 'package:flutter_application_1/ble/bleActivationHandler.dart';
import 'package:flutter_application_1/ble/bleDeviceInfo.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

bool isBleEnabled = false;
bool isLocationEnabled = false;

class bleConexion extends StatefulWidget {
  const bleConexion({super.key});

  @override
  State<bleConexion> createState() => _bleConexionState();
}

class _bleConexionState extends State<bleConexion> {
  bool isScanStarted = false;
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, '/taller');
        return false;
      },
      child: Scaffold(
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
            leadingWidth: 40.0,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: IconButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/taller');
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              if (isBleEnabled && isLocationEnabled)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: TextButton(
                    onPressed: () {
                      //isScanStarted ? stopScan() : startScan();

                      isScanStarted
                          ? context.read<BleProvider>().stopScan()
                          : context.read<BleProvider>().startScan();

                      setState(() {
                        isScanStarted = !isScanStarted;
                      });
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: Colors.red,
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
                          await systemHelper.enableBluetooth();
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
              if (!isLocationEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  color: Colors.red,
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
                          await systemHelper.enableLocation();
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
              if (!isBleEnabled || !isLocationEnabled)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              if (!isBleEnabled)
                Image.asset(
                  'assets/images/bluetooth_desactivado.png',
                ),
              if (!isLocationEnabled)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
              if (!isLocationEnabled)
                Image.asset(
                  'assets/images/ubicacion_desactivada.png',
                ),
              // Lista de dispositivos activados
              if (isBleEnabled && isLocationEnabled)
                Expanded(
                  child: Consumer<BleProvider>(
                    builder: (context, provider, _) {
                      return ListView.builder(
                        itemCount: provider.devices.length,
                        itemBuilder: (context, index) {
                          final device = provider.devices[index];
                          final String company =
                              getDeviceName(device.manufacturerData);

                          if (company == 'Consorcio Nettel') {
                            final String image = getImagePadlock(device.name);
                            final String battery =
                                getBattery(device.manufacturerData);
                            final int bLevel =
                                getBatteryInt(device.manufacturerData);

                            return ExpansionTile(
                              collapsedTextColor: Colors.black,
                              textColor: Colors.black,
                              title: Text(
                                device.name,
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    device.id,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Positioned(
                                            child: Icon(
                                              bLevel < 35
                                                  ? CupertinoIcons
                                                      .battery_25_percent
                                                  : CupertinoIcons
                                                      .battery_75_percent,
                                              color: bLevel < 35
                                                  ? Colors.red
                                                  : Colors.green,
                                              size: 32.0,
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8.0,
                                            left: 7.0,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              battery,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 12.0,
                                      ),
                                      Icon(
                                        getApState(device.manufacturerData) == 0
                                            ? CupertinoIcons.lock_open_fill
                                            : CupertinoIcons.lock_fill,
                                        size: 15.0,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        getAlarmState(
                                                    device.manufacturerData) ==
                                                0
                                            ? getApState(device
                                                        .manufacturerData) ==
                                                    0
                                                ? 'Abierto'
                                                : 'Cerrado'
                                            : 'Alarmado',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              leading: Image.asset(image),
                              trailing: Container(
                                height: 35.0,
                                decoration: BoxDecoration(
                                  color: getColorAlmostBlue(),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    //provider.connectToDevice(device);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => bleOperation(
                                          device: device,
                                          provider: provider,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'CONECTAR',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              childrenPadding:
                                  const EdgeInsets.only(left: 60.0),
                              children: [
                                if (device.manufacturerData.isNotEmpty)
                                  ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        estado(
                                          texto: 'Sensores',
                                          titulo: true,
                                        ),
                                        const SizedBox(
                                          width: 40.0,
                                        ),
                                        estado(
                                          texto: 'Estado',
                                          titulo: true,
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        // Sensores
                                        Column(
                                          children: [
                                            // Apertura
                                            sensor(
                                              texto: 'Apertura',
                                              color: getApState(device
                                                          .manufacturerData) ==
                                                      0
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),

                                            // Corte
                                            if (device.name.contains('CA') ||
                                                device.name.contains('N01') ||
                                                device.name.contains('N03'))
                                              sensor(
                                                texto: 'Corte',
                                                color: getCoState(device
                                                            .manufacturerData) ==
                                                        0
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            // Separacion
                                            if (device.name.contains('CA'))
                                              sensor(
                                                texto: 'Separación',
                                                color: getSeState(device
                                                            .manufacturerData) ==
                                                        0
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            // Tapa
                                            sensor(
                                              texto: 'Tapa',
                                              color: getTaState(device
                                                          .manufacturerData) ==
                                                      0
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 40.0,
                                        ),
                                        // Estado
                                        Column(
                                          children: [
                                            // Apertura
                                            estado(
                                              texto: getApState(device
                                                          .manufacturerData) ==
                                                      0
                                                  ? 'ABIERTO'
                                                  : 'CERRADO',
                                            ),
                                            // Corte
                                            if (device.name.contains('CA') ||
                                                device.name.contains('N01') ||
                                                device.name.contains('N03'))
                                              estado(
                                                texto: getCoState(device
                                                            .manufacturerData) ==
                                                        0
                                                    ? 'ABIERTO'
                                                    : 'CERRADO',
                                              ),
                                            // Separación
                                            if (device.name.contains('CA'))
                                              estado(
                                                texto: getSeState(device
                                                            .manufacturerData) ==
                                                        0
                                                    ? 'ABIERTO'
                                                    : 'CERRADO',
                                              ),
                                            // Tapa
                                            estado(
                                              texto: getTaState(device
                                                          .manufacturerData) ==
                                                      0
                                                  ? 'ABIERTO'
                                                  : 'CERRADO',
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                              onExpansionChanged: (e) {
                                if (e) {
                                  provider.selectDevice(device);
                                }
                              },
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                )
            ],
          )),
    );
  }

  @override
  void initState() {
    checkPermissions();
    checkBleStatus();
    super.initState();
  }

  Future<void> checkBleStatus() async {
    bool bluetoothEnabled = await systemHelper.isBluetoothEnabled();
    bool locationEnabled = await systemHelper.isLocationEnabled();
    logger.i(bluetoothEnabled);
    setState(() {
      isBleEnabled = bluetoothEnabled;
      isLocationEnabled = locationEnabled;
    });
  }

  Future<void> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.bluetoothAdvertise,
    ].request();

    if (statuses[Permission.bluetooth]!.isDenied ||
        statuses[Permission.bluetoothScan]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied ||
        statuses[Permission.location]!.isDenied) {
      // Permissions are denied, handle appropriately
      logger.e("Bluetooth permissions are denied. $statuses");
    } else if (statuses[Permission.bluetooth]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothScan]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothConnect]!.isPermanentlyDenied ||
        statuses[Permission.location]!.isPermanentlyDenied) {
      // Permissions are permanently denied, open app settings
      openAppSettings();
    }
  }
}

/* Devuelve en string de la imagen  */
String getImagePadlock(String name) {
  String image = 'assets/images/candado_cable.png';
  if (name.contains('N01')) {
    image = 'assets/images/candado_cable.png';
  } else if (name.contains('N02')) {
    image = 'assets/images/candado_piston.png';
  } else if (name.contains('N03')) {
    image = 'assets/images/candado_U.png';
  }
  return image;
}

/* Retorna el widget para  la visualizacion de los sensores */
SizedBox sensor({required String texto, required Color color}) {
  return SizedBox(
    width: 100.0,
    child: Row(
      children: [
        Icon(
          Icons.rectangle,
          color: color,
          size: 22.0,
        ),
        const SizedBox(
          width: 2.0,
        ),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.black,
          ),
        )
      ],
    ),
  );
}

/* Retorna el widget para la visualizacion del estado del sensor */
SizedBox estado({required String texto, bool titulo = false}) {
  return SizedBox(
    width: 100.0,
    child: Text(
      texto,
      style: titulo
          ? const TextStyle(
              color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold)
          : const TextStyle(color: Colors.black),
    ),
  );
}
