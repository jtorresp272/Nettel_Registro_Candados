// ignore_for_file: file_names, camel_case_types

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';

/* Clase para determinar si el ble esta conectado o no */
class systemHelper {
  static const MethodChannel _bluetoothChannel =
      MethodChannel('com.example.flutter_application_1/bluetooth');
  static const MethodChannel _locationChannel =
      MethodChannel('com.example.flutter_application_1/location');

  static Future<void> enableBluetooth() async {
    try {
      await _bluetoothChannel.invokeMethod('enableBluetooth');
    } on PlatformException catch (e) {
      logger.w("Failed to enable Bluetooth: '${e.message}'.");
    }
  }

  static Future<void> enableLocation() async {
    try {
      await _locationChannel.invokeMethod('enableLocation');
    } on PlatformException catch (e) {
      logger.w("Failed to enable location: '${e.message}'.");
    }
  }

  static Future<bool> isBluetoothEnabled() async {
    try {
      final bool result =
          await _bluetoothChannel.invokeMethod('isBluetoothEnabled');
      return result;
    } on PlatformException catch (e) {
      logger.w("Failed to check Bluetooth status: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> isLocationEnabled() async {
    try {
      final bool result =
          await _locationChannel.invokeMethod('isLocationEnabled');
      return result;
    } on PlatformException catch (e) {
      logger.w("Failed to check location status: '${e.message}'.");
      return false;
    }
  }
}
