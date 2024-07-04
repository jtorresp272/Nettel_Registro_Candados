import 'dart:async';

import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';
import 'package:flutter_application_1/ble/bleActivationHandler.dart';
import 'package:flutter_application_1/ble/bleDeviceInfo.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';

enum MessageType { sent, received, process }

enum CharacteristicType { nordic, nettel, both }

class Message {
  final String content;
  final MessageType type;
  final CharacteristicType characteristic;

  Message(this.content, this.type, this.characteristic);
}

class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final List<int> manufacturerData;
  final List<Uuid> serviceUuids;
  bool isSelected;
  bool outOfRange;
  bool isbonded;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.manufacturerData,
    required this.serviceUuids,
    this.isSelected = false,
    this.outOfRange = false,
    this.isbonded = false,
  });
}

class BleProvider with ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? connectionSubscription;

  List<BleDevice> devices = [];
  BleDevice? connectedDevice;
  bool isConnected = false;
  bool reconnection = false;
  String? targetDeviceName;
  final List<Message> _messages = [];
  List<Message> get messages => List.unmodifiable(_messages);
  bool shouldStopReconnection = false;
  List<String> foundDevicesId = [];
  Timer? checkTimer;
  bool isBonded = false;
  Map<String, bool> devicesScanned = {};

  Future<void> addMessage(Message message) async {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessage() {
    _messages.clear();
    notifyListeners();
  }

  void startScan() {
    stopScan();
    devices.clear();
    foundDevicesId.clear();
    notifyListeners();

    scanSubscription = flutterReactiveBle
        .scanForDevices(withServices: []).listen((device) async {
      if (getDeviceName(device.manufacturerData) == "Consorcio Nettel") {
        bool isbonded = await systemHelper.isDevicePaired(device.name);

        final existingDeviceIndex =
            devices.indexWhere((d) => d.id == device.id);

        if (existingDeviceIndex != -1) {
          // If the device already exists, update it with the latest data
          devices[existingDeviceIndex] = BleDevice(
            id: device.id,
            name: device.name,
            rssi: device.rssi,
            manufacturerData: device.manufacturerData,
            serviceUuids: device.serviceUuids,
            isSelected: devices[existingDeviceIndex].isSelected,
            outOfRange: false,
            isbonded: isbonded,
          );
        } else {
          // If the device doesn't exist, add it to the list
          devices.add(BleDevice(
            id: device.id,
            name: device.name,
            rssi: device.rssi,
            manufacturerData: device.manufacturerData,
            serviceUuids: device.serviceUuids,
            outOfRange: false,
            isbonded: isbonded,
          ));
        }

        if (!foundDevicesId.contains(device.id)) {
          foundDevicesId.add(device.id);
        }
        // check si el dispositivo esta actualizando
        notifyListeners();
      }
    }, onError: (error) {
      logger.e('Error while scanning: $error');
      stopScan();
    });

    checkTimer?.cancel();
    checkTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      markDevicesOutOfRange();
    });
  }

  // Funcion que revisa si el dispositivo sigue en el aire o no
  void markDevicesOutOfRange() {
    devices.forEach((device) {
      if (foundDevicesId.contains(device.id)) {
        device.outOfRange = false;
      } else {
        device.outOfRange = true;
      }
    });

    foundDevicesId.clear();
    notifyListeners();
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
    shouldStopReconnection = false;
    devicesScanned.clear();
    notifyListeners();
  }

  Future<bool> connectToDevice(BleDevice device, [bool bonded = false]) async {
    connectionSubscription?.cancel();
    isConnected = false;
    targetDeviceName = device.name;
    connectionSubscription = flutterReactiveBle
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(
        seconds: 5,
      ),
    )
        .listen(
      (update) async {
        if (update.connectionState == DeviceConnectionState.connected) {
          connectedDevice = device;
          isConnected = true;
          reconnection = false;
          if (bonded) {
            await systemHelper.pairWithDevice(device.id);
          }
          notifyListeners();
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          connectedDevice = null;
          isConnected = false;
          reconnection = true;
          notifyListeners();
          addMessage(Message(
              'Desconectado', MessageType.process, CharacteristicType.both));
        }
      },
      onError: (error) {
        logger.e('ErrorWhile connecting: $error');
        isConnected = false;
        reconnection = true;
        //handleDisconnection();
        notifyListeners();
      },
    );

    shouldStopReconnection = false;
    await Future.delayed(const Duration(seconds: 3), () {
      if (device.name.isNotEmpty) {
        requestMTU(device); // Pedir mas mtu
      }
    });

    return isConnected;
  }

  Future<void> disconnectFromDevice() async {
    await connectionSubscription?.cancel();
    connectedDevice = null;
    isConnected = false;
    reconnection = true;
    shouldStopReconnection = false;
    notifyListeners();
  }

  void handleDisconnection() {
    // Lógica para manejar la desconexión
    logger.w('me desconecte');
    if (targetDeviceName != null) {
      isConnected = false;
      reconnection = true;
    } else {
      // Aquí puedes manejar otros casos de desconexión
      isConnected = false;
      reconnection = true;
    }
  }

  Future<BleDevice?> reconnectToDevice() async {
    reconnection = false;
    BleDevice finDevice;
    if (targetDeviceName != null) {
      logger.i('Attempting to reconnect to device: $targetDeviceName');
      startScan();
      await for (var device
          in flutterReactiveBle.scanForDevices(withServices: [])) {
        if (device.name == targetDeviceName) {
          finDevice = BleDevice(
            id: device.id,
            name: device.name,
            rssi: device.rssi,
            manufacturerData: device.manufacturerData,
            serviceUuids: device.serviceUuids,
          );
          await connectToDevice(finDevice);
          if (isConnected) {
            return finDevice;
          }
        }
        if (shouldStopReconnection) {
          //reconnection = true;
          shouldStopReconnection = false;
          logger.w('Reconnection stopped by user. $shouldStopReconnection');
          break;
        }
      }
    }
    return null;
  }

  void stopReconnection() {
    shouldStopReconnection = true;
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
      Uuid.parse("4a4f0001-4156-4920-9a23-4e657454454c"): "Nettel service",
      Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e"): "Nordic Service",
      Uuid.parse("00001800-0000-1000-8000-00805f9b34fb"): "Generic Access",
      Uuid.parse("00001801-0000-1000-8000-00805f9b34fb"): "Generic Attribute",
      Uuid.parse("0000fe59-0000-1000-8000-00805f9b34fb"): "DFU service",
    };

    return name[service] ?? 'Unknown';
  }

  Uuid getCharacteristic(String name) {
    Map<String, Uuid> uuid = {
      "nettelRead": Uuid.parse("4a4f0002-4156-4920-9a23-4e657454454c"),
      "nettelWrite": Uuid.parse("4a4f0003-4156-4920-9a23-4e657454454c"),
      "nordicRead": Uuid.parse("6e400002-b5a3-f393-e0a9-e50e24dcca9e"),
      "nordicWrite": Uuid.parse("6e400003-b5a3-f393-e0a9-e50e24dcca9e"),
    };

    return uuid[name] ?? Uuid.parse('');
  }

  Stream<List<int>> subscribeToNettelCharacteristic(
    BleDevice device,
  ) {
    final characteristic = QualifiedCharacteristic(
      characteristicId: getCharacteristic("nettelWrite"),
      serviceId: Uuid.parse("4a4f0001-4156-4920-9a23-4e657454454c"),
      deviceId: device.id,
    );
    try {
      return flutterReactiveBle.subscribeToCharacteristic(characteristic);
    } catch (e) {
      logger.e('Error reading characteristic $e');
      return const Stream.empty();
    }
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

  Stream<List<int>> subscribeToNordicCharacteristic(
    BleDevice device,
  ) {
    final characteristic = QualifiedCharacteristic(
      characteristicId: getCharacteristic("nordicWrite"),
      serviceId: Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
      deviceId: device.id,
    );
    try {
      return flutterReactiveBle.subscribeToCharacteristic(characteristic);
    } catch (e) {
      logger.e('Error reading characteristic $e');
      return const Stream.empty();
    }
  }

  Future<void> writeNordicCharacteristic(
    BleDevice device,
    List<int> value,
  ) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
        QualifiedCharacteristic(
            characteristicId: getCharacteristic("nordicRead"),
            serviceId: Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e"),
            deviceId: device.id),
        value: value,
      );
    } catch (e) {
      logger.e('Error writing characterisitic $e');
    }
  }

  Future<int> requestMTU(BleDevice device) async {
    try {
      int mtu =
          await flutterReactiveBle.requestMtu(deviceId: device.id, mtu: 498);
      logger.i('Cantidad de mtu: $mtu');
      return mtu;
    } catch (e) {
      logger.e('Error pidiendo mas MTU $e');
      return 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    stopScan(); // Ensure the scan is stopped when the provider is disposed
  }
}
