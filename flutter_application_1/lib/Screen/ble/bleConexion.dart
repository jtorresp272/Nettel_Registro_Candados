import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Funciones/generales/enviar_datos_database.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/Screen/ble/bleOperation.dart';
import 'package:flutter_application_1/ble/bleActivationHandler.dart';
import 'package:flutter_application_1/ble/bleDeviceInfo.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_application_1/widgets/CustomSnackBar.dart';
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
  Map<String, bool> tapContainer = {};
  Map<String, List<Color>> containerGradientColor = {
    "inRangeCompact": [
      Colors.white,
      getColorAlmostBlue().withOpacity(0.5),
      getColorAlmostBlue().withOpacity(0.8),
    ],
    "outRangeCompact": [
      Colors.white,
      Colors.grey.withOpacity(0.8),
      Colors.grey.withOpacity(0.5),
    ],
    "inRange": [
      Colors.white,
      Colors.white,
      Colors.white,
      getColorAlmostBlue().withOpacity(0.5),
      getColorAlmostBlue().withOpacity(0.8),
    ],
    "outRange": [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.grey.withOpacity(0.8),
      Colors.grey.withOpacity(0.5),
    ],
  };

  /* Funcion para el menu que esta del lado derecho del boton conectar */
  void _showPopupMenu(BuildContext context, Offset offset, BleDevice device,
      BleProvider provider) {
    final RelativeRect position = RelativeRect.fromLTRB(
        offset.dx, offset.dy, offset.dx + 1, offset.dy + 1);
    showMenu(context: context, position: position, items: [
      PopupMenuItem(
        value: 0,
        child: Text(device.isbonded
            ? 'Borrar datos vinculacion'
            : 'Vincular y Conectar'),
      ),
      const PopupMenuItem(
        value: 1,
        child: Text('dos'),
      ),
      const PopupMenuItem(
        value: 2,
        child: Text('tres'),
      ),
    ]).then((value) async {
      if (value != null) {
        switch (value) {
          case 0:
            if (!device.outOfRange) {
              device.isbonded
                  ? await systemHelper.unpairWithDevice(device.name)
                  : Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BleOperation(
                          device: device,
                          provider: provider,
                          withBond: true,
                        ),
                      ),
                    );
            } else {
              customSnackBar(
                context,
                mensaje: 'No se pueden eliminar los datos',
                colorFondo: Colors.red,
                colorText: Colors.white,
              );
            }
            break;
          case 1:
            logger.i('dos');
            break;
          case 2:
            logger.i('tres');
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consorcio Nettel',
                style: TextStyle(
                  color: getColorAlmostBlue(),
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bluetooth',
                style: TextStyle(
                  color: getColorAlmostBlue(),
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          leadingWidth: 30.0,
          leading: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, '/taller');
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              color: getColorAlmostBlue(),
            ),
          ),
          actions: [
            if (isBleEnabled && isLocationEnabled)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: TextButton(
                  onPressed: () {
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
                      color: isScanStarted
                          ? Colors.redAccent
                          : getColorAlmostBlue(),
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

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8.0, bottom: 2.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  tapContainer[device.id] =
                                      !(tapContainer[device.id] ?? false);
                                  provider.selectDevice(device);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(3.0),
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.2,
                                    color: !device.outOfRange
                                        ? getColorAlmostBlue()
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  gradient: tapContainer[device.id] ?? false
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: !device.outOfRange
                                              ? containerGradientColor[
                                                  "inRange"]!
                                              : containerGradientColor[
                                                  "outRange"]!,
                                        )
                                      : LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: !device.outOfRange
                                              ? containerGradientColor[
                                                  "inRangeCompact"]!
                                              : containerGradientColor[
                                                  "outRangeCompact"]!,
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: Image.asset(
                                            image,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                device.name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      device.id,
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      device.isbonded
                                                          ? 'Vinculado'
                                                          : 'Desvinculado',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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
                                                          textDirection:
                                                              TextDirection.rtl,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 8.0,
                                                        left: 7.0,
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.right,
                                                          battery,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10.0,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 12.0,
                                                  ),
                                                  Icon(
                                                    getApState(device
                                                                .manufacturerData) ==
                                                            0
                                                        ? CupertinoIcons
                                                            .lock_open_fill
                                                        : CupertinoIcons
                                                            .lock_fill,
                                                    size: 15.0,
                                                    color: Colors.black,
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    getAlarmState(device
                                                                .manufacturerData) ==
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
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 12.0,
                                                  ),
                                                  const Icon(
                                                    CupertinoIcons
                                                        .chart_bar_fill,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    '${device.rssi} dBm',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Despues de presionar el container
                                    Visibility(
                                      visible: tapContainer[device.id] ?? false,
                                      // Row general
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Row solo para el estado de los sensores
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (device.manufacturerData
                                                      .isNotEmpty)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        estado(
                                                          texto: 'Sensores',
                                                          titulo: true,
                                                        ),
                                                        estado(
                                                          texto: 'Estado',
                                                          titulo: true,
                                                        ),
                                                      ],
                                                    ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
                                                          if (device.name
                                                                  .contains(
                                                                      'CA') ||
                                                              device.name
                                                                  .contains(
                                                                      'N01') ||
                                                              device.name
                                                                  .contains(
                                                                      'N03') ||
                                                              device.name
                                                                  .contains(
                                                                      'C07'))
                                                            sensor(
                                                              texto: 'Corte',
                                                              color: getCoState(
                                                                          device
                                                                              .manufacturerData) ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                            ),
                                                          // Separacion
                                                          if (device.name
                                                              .contains('C07'))
                                                            sensor(
                                                              texto:
                                                                  'Separación',
                                                              color: getSeState(
                                                                          device
                                                                              .manufacturerData) ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
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
                                                        width: 15.0,
                                                      ),
                                                      // Estado
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Apertura
                                                          estado(
                                                            texto: getApState(device
                                                                        .manufacturerData) ==
                                                                    0
                                                                ? 'OP'
                                                                : 'CL',
                                                          ),
                                                          // Corte
                                                          if (device.name
                                                                  .contains(
                                                                      'CA') ||
                                                              device.name
                                                                  .contains(
                                                                      'N01') ||
                                                              device.name
                                                                  .contains(
                                                                      'N03') ||
                                                              device.name
                                                                  .contains(
                                                                      'C07'))
                                                            estado(
                                                              texto: getCoState(
                                                                          device
                                                                              .manufacturerData) ==
                                                                      0
                                                                  ? 'OP'
                                                                  : 'CL',
                                                            ),
                                                          // Separación
                                                          if (device.name
                                                              .contains('C07'))
                                                            estado(
                                                              texto: getSeState(
                                                                          device
                                                                              .manufacturerData) ==
                                                                      0
                                                                  ? 'OP'
                                                                  : 'CL',
                                                            ),
                                                          // Tapa
                                                          estado(
                                                            texto: getTaState(device
                                                                        .manufacturerData) ==
                                                                    0
                                                                ? 'OP'
                                                                : 'CL',
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Boton para conexión
                                          Container(
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Boton conectar
                                                GestureDetector(
                                                  onTap: () {
                                                    if (!device.outOfRange) {
                                                      // Detener el escaneo de dispositivos
                                                      setState(() {
                                                        context
                                                            .read<BleProvider>()
                                                            .stopScan();
                                                        isScanStarted = false;
                                                      });
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BleOperation(
                                                            device: device,
                                                            provider: provider,
                                                            withBond: false,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      customSnackBar(
                                                        context,
                                                        mensaje:
                                                            'No se puede conectar con el dispositivo',
                                                        colorFondo: Colors.red,
                                                        colorText: Colors.black,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 35.0,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: const Text(
                                                      'CONECTAR',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const VerticalDivider(
                                                  endIndent: 3.0,
                                                  indent: 3.0,
                                                  thickness: 1,
                                                  color: Colors.grey,
                                                ),
                                                // Menu extra
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                  child: GestureDetector(
                                                    onTapDown: (TapDownDetails
                                                        details) {
                                                      _showPopupMenu(
                                                          context,
                                                          details
                                                              .globalPosition,
                                                          device,
                                                          provider);
                                                    },
                                                    child: const Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
        ));
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

    setState(() {
      isBleEnabled = bluetoothEnabled;
      isLocationEnabled = locationEnabled;
      context.read<BleProvider>().stopScan();
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
  } else if (name.contains('C07')) {
    image = 'assets/images/cc_plastico.png';
  } else if (name.contains('S09')) {
    image = 'assets/images/solar.png';
  }
  return image;
}

/* Retorna el widget para  la visualizacion de los sensores */
SizedBox sensor({required String texto, required Color color}) {
  return SizedBox(
    width: 80.0,
    child: Row(
      children: [
        Icon(
          Icons.rectangle,
          color: color,
          size: 15.0,
        ),
        const SizedBox(
          width: 2.0,
        ),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12.0,
          ),
        )
      ],
    ),
  );
}

/* Retorna el widget para la visualizacion del estado del sensor */
SizedBox estado({required String texto, bool titulo = false}) {
  return SizedBox(
    width: 80.0,
    child: Text(
      texto,
      textAlign: TextAlign.left,
      style: titulo
          ? const TextStyle(
              color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold)
          : const TextStyle(color: Colors.black),
    ),
  );
}
