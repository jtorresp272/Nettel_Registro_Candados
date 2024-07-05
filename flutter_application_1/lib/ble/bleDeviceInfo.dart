// ignore_for_file: file_names

/* Funcion para obtener el nombre del dispositivo */
import 'package:flutter_application_1/Funciones/enviar_datos_database.dart';

String getDeviceName(List<int> manufacturerData) {
  if (manufacturerData.length < 2) {
    return 'Unknown';
  }
  // El código del fabricante son los dos primeros bytes
  int manufacturerId = (manufacturerData[1] << 8) | manufacturerData[0];
  return convertToHex(manufacturerId) ?? 'Unknown';
}

/* Funcion para obtener el nivel de bateria en formato string */
String getBattery(List<int> manufacturerData) {
  int bateria = 0;
  bateria = manufacturerData[manufacturerData.length - 2];
  bateria = int.parse(bateria.toRadixString(16).padLeft(2, '0'));

  return getBatteryLevel(bateria);
}

/* Retorna del estado del sensor de apertura (Abierto o Cerrado) */
int getApState(List<int> manufacturerData) {
  int sensores = manufacturerData[manufacturerData.length - 1];
  String sen = sensores.toRadixString(2).padLeft(8, '0');
  List<int> sensorBit = [];

  // Iterate over each bit
  for (int i = 0; i < sen.length; i++) {
    sensorBit.add(int.parse(sen[i]));
    //logger.e("Bit $i: ${sensorBit[i]}");
    // Perform your logic for each bit here
  }

  return sensorBit[7];
}

/* Retorna del estado del sensor de separación (Abierto o Cerrado) */
int getSeState(List<int> manufacturerData) {
  int sensores = manufacturerData[manufacturerData.length - 1];
  String sen = sensores.toRadixString(2).padLeft(8, '0');
  List<int> sensorBit = [];

  // Iterate over each bit
  for (int i = 0; i < sen.length; i++) {
    sensorBit.add(int.parse(sen[i]));
    //logger.e("Bit $i: ${sensorBit[i]}");
    // Perform your logic for each bit here
  }

  return sensorBit[6];
}

/* Retorna del estado del sensor de corte (Abierto o Cerrado) */
int getCoState(List<int> manufacturerData) {
  int sensores = manufacturerData[manufacturerData.length - 1];
  String sen = sensores.toRadixString(2).padLeft(8, '0');
  List<int> sensorBit = [];

  // Iterate over each bit
  for (int i = 0; i < sen.length; i++) {
    sensorBit.add(int.parse(sen[i]));

    //logger.e("Bit $i: ${sensorBit[i]}");
    // Perform your logic for each bit here
  }
  return sensorBit[5];
}

/* Retorna del estado del sensor de Tapa (Abierto o Cerrado) */
int getTaState(List<int> manufacturerData) {
  int sensores = manufacturerData[manufacturerData.length - 1];
  String sen = sensores.toRadixString(2).padLeft(8, '0');
  List<int> sensorBit = [];

  // Iterate over each bit
  for (int i = 0; i < sen.length; i++) {
    sensorBit.add(int.parse(sen[i]));
    //logger.e("Bit $i: ${sensorBit[i]}");
    // Perform your logic for each bit here
  }

  return sensorBit[4];
}

/* Retorna del estado del sensor de Tapa (Abierto o Cerrado) */
int getAlarmState(List<int> manufacturerData) {
  int sensores = manufacturerData[manufacturerData.length - 1];
  String sen = sensores.toRadixString(2).padLeft(8, '0');
  List<int> sensorBit = [];

  // Iterate over each bit
  for (int i = 0; i < sen.length; i++) {
    sensorBit.add(int.parse(sen[i]));
    //logger.e("Bit $i: ${sensorBit[i]}");
    // Perform your logic for each bit here
  }

  return sensorBit[0];
}

/* Funcion para obtener el nivel de bateria en formato int */
int getBatteryInt(List<int> manufacturerData) {
  int bateria = 0;
  bateria = manufacturerData[manufacturerData.length - 2];
  bateria = int.parse(bateria.toRadixString(2).padLeft(8, '0'));

  return bateria;
}

/* Funcion para convertir a hex un dato int y devolver un String? */
String? convertToHex(int data) {
  int value = data & 0xFFFF;
  return manufacturerNames[value];
}

/* Funcion para obtener un String del nivel de bateria */
String getBatteryLevel(int battery) {
  Map<int, String> batteryLevels = {
    30: "3.0",
    31: "3.1",
    32: "3.2",
    33: "3.3",
    34: "3.4",
    35: "3.5",
    36: "3.6",
    37: "3.7",
    38: "3.8",
    39: "3.9",
    40: "4.0",
    41: "4.1",
    42: "4.2"
  };

  return batteryLevels[battery] ?? '3.0';
}

/* Listado de equipos ble registrados */
final Map<int, String> manufacturerNames = {
  0x004C: 'Apple Inc.',
  0x0006: 'Microsoft',
  0x000F: 'Texas Instruments Inc,',
  0x0C6A: 'Consorcio Nettel',
};
