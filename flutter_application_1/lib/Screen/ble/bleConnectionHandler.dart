// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConnectionHandler {
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription? streamSubscription;
  StreamSubscription<ConnectionStateUpdate>? connection;

  BleConnectionHandler();

  void startBluetoothScan(Function(DiscoveredDevice) discoveredDevice) async {
    if (flutterReactiveBle.status == BleStatus.ready) {
      logger.i("Start ble discovery");
      streamSubscription = flutterReactiveBle
          .scanForDevices(withServices: []).listen((device) async {
        if (device.name.isNotEmpty) discoveredDevice(device);
      }, onError: (Object e) => logger.e('Device scan fails with error $e'));
    } else {
      logger.i("Device is not ready for communication");
      Future.delayed(const Duration(seconds: 2), () {
        startBluetoothScan(discoveredDevice);
      });
    }
  }

  void connectToDevice(DiscoveredDevice discoveredDevice,
      Function(bool) connectionStatus) async {
    connection = flutterReactiveBle
        .connectToDevice(id: discoveredDevice.id)
        .listen((connectionState) {
      logger.i(
          "ConnectionState for device ${discoveredDevice.name} : ${connectionState.connectionState}");
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        connectionStatus(true);
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        connectionStatus(false);
      }
    }, onError: (Object error) {
      logger.e("Connecting to device resulted in error $error");
    });
  }

  Future<void> closeConnection() async {
    logger.i("Close Connection");
    await streamSubscription?.cancel();
    await connection?.cancel();
    streamSubscription = null;
  }

  Future<void> stopScan() async {
    logger.i("Stop ble discovery");
    await streamSubscription?.cancel();
    streamSubscription = null;
  }
}

/* Clase para determinar si el ble esta conectado o no */
class BluetoothHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_application_1/bluetooth');

  static Future<void> enableBluetooth() async {
    try {
      await _channel.invokeMethod('enableBluetooth');
      //return result;
    } on PlatformException catch (e) {
      logger.w("Failed to enable Bluetooth: '${e.message}'.");
      //return false;
    }
  }

  static Future<bool> isBluetoothEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isBluetoothEnabled');
      return result;
    } on PlatformException catch (e) {
      logger.w("Failed to check Bluetooth status: '${e.message}'.");
      return false;
    }
  }
}
