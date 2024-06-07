import 'dart:async';

import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';

class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final List<int> manufacturerData;
  final List<Uuid> serviceUuids;
  bool isSelected;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.manufacturerData,
    required this.serviceUuids,
    this.isSelected = false,
  });
}

class BleProvider with ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? connectionSubscription;

  List<BleDevice> devices = [];
  BleDevice? connectedDevice;
  bool isConnected = false;

  void startScan() {
    stopScan();
    devices.clear();
    notifyListeners();

    scanSubscription =
        flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      final existingDeviceIndex = devices.indexWhere((d) => d.id == device.id);

      if (existingDeviceIndex != -1) {
        // If the device already exists, update it with the latest data
        devices[existingDeviceIndex] = BleDevice(
          id: device.id,
          name: device.name,
          rssi: device.rssi,
          manufacturerData: device.manufacturerData,
          serviceUuids: device.serviceUuids,
          isSelected: devices[existingDeviceIndex].isSelected,
        );
      } else {
        // If the device doesn't exist, add it to the list
        devices.add(BleDevice(
          id: device.id,
          name: device.name,
          rssi: device.rssi,
          manufacturerData: device.manufacturerData,
          serviceUuids: device.serviceUuids,
        ));
      }
      notifyListeners();
    }, onError: (error) {
      logger.e('Error while scanning: $error');
      stopScan();
    });
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
    notifyListeners();
  }

  Future<bool> connectToDevice(BleDevice device) async {
    connectionSubscription?.cancel();
    isConnected = false;
    connectionSubscription = flutterReactiveBle
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(
        seconds: 5,
      ),
    )
        .listen(
      (update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          connectedDevice = device;
          isConnected = true;
          notifyListeners();
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          connectedDevice = null;
          isConnected = false;
          notifyListeners();
        }
      },
      onError: (error) {
        logger.e('ErrorWhile connecting: $error');
        isConnected = false;
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    return isConnected;
  }

  void disconnectFromDevice() {
    connectionSubscription?.cancel();
    connectedDevice = null;
    notifyListeners();
  }

  void selectDevice(BleDevice selectedDevice) {
    for (var device in devices) {
      device.isSelected = device == selectedDevice;
    }
    notifyListeners();
  }

  Future<List<DiscoveredService>> discoverDevicesServices(
      BleDevice device) async {
    List<DiscoveredService> services =
        await flutterReactiveBle.discoverServices(device.id);
    // Handle discovered services here
    for (var service in services) {
      logger.i('Service: ${service.serviceId}');
      for (var characteristic in service.characteristics) {
        logger.i('Characteristic: ${characteristic.characteristicId}');
      }
    }
    return services;
  }

/* Retorna el nombre del servicio */
  String getServiceName(Uuid service) {
    Map<Uuid, String> name = {
      Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e"): "Nordic Service",
      Uuid.parse("4a4f0001-4156-4920-9a23-4e657454454c"): "Nettel service",
      Uuid.parse("00001800-0000-1000-8000-00805f9b34fb"): "Generic Access",
      Uuid.parse("00001801-0000-1000-8000-00805f9b34fb"): "Generic Attribute",
      Uuid.parse("0000fe59-0000-1000-8000-00805f9b34fb"): "DFU service",
    };

    return name[service] ?? 'Unknown';
  }

  Uuid getCharacteristic(String name) {
    Map<String, Uuid> uuid = {
      "nettelRead": Uuid.parse('4a4f0002-4156-4920-9a23-4e657454454c'),
      "nettelWrite": Uuid.parse('4a4f0003-4156-4920-9a23-4e657454454c'),
      "nordicRead": Uuid.parse('6a400003-b5a3-f393-e0a9-e50e24dcca9e'),
      "nordicWrite": Uuid.parse('6a400002-b5a3-f393-e0a9-e50e24dcca9e'),
    };

    return uuid[name] ?? Uuid.parse('');
  }

  Future<List<int>> readNettelCharacteristic(BleDevice device) async {
    return await flutterReactiveBle.readCharacteristic(
      QualifiedCharacteristic(
        characteristicId: getCharacteristic("nettelWrite"),
        serviceId: Uuid.parse("4a4f0001-4156-4920-9a23-4e657454454c"),
        deviceId: device.id,
      ),
    );
  }

  Future<void> writeNettelCharacteristic(
      BleDevice device, List<int> value) async {
    await flutterReactiveBle.writeCharacteristicWithoutResponse(
      QualifiedCharacteristic(
          characteristicId: getCharacteristic("nettelRead"),
          serviceId: Uuid.parse("4a4f0001-4156-4920-9a23-4e657454454c"),
          deviceId: device.id),
      value: value,
    );
  }

  @override
  void dispose() {
    super.dispose();
    stopScan(); // Ensure the scan is stopped when the provider is disposed
  }
}
