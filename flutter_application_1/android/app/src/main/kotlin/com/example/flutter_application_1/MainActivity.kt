package com.example.flutter_application_1

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var result: MethodChannel.Result? = null
    private val LOCATION_SETTINGS_REQUEST = 1
    private val BLUETOOTH_REQUEST = 2
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.flutter_application_1/bluetooth")
            .setMethodCallHandler { call, result ->
                this.result = result
                when (call.method) {
                    "isBluetoothEnabled" -> {
                        val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
                        result.success(bluetoothAdapter?.isEnabled == true)
                    }
                    "enableBluetooth" -> {
                        val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
                        if (bluetoothAdapter != null && !bluetoothAdapter.isEnabled) {
                            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                            startActivityForResult(enableBtIntent, BLUETOOTH_REQUEST)
                        } else {
                            result.success(true)
                        }
                    }
                    "isDevicePaired" -> {
                        val deviceName = call.argument<String>("deviceName")
                        if (deviceName != null) {
                            isDevicePaired(deviceName, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Device name is required", null)
                        }
                    }
                    "pairWithDevice" -> {
                        val deviceAddress = call.argument<String>("deviceAddress")
                        if (deviceAddress != null) {
                            pairWithDevice(deviceAddress, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Device address is required", null)
                        }
                    }
                    "unpairWithDevice" -> {
                        val deviceName = call.argument<String>("deviceName")
                        if (deviceName != null) {
                            unpairWithDeviceByName(deviceName, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "Device name is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.flutter_application_1/location")
            .setMethodCallHandler { call, result ->
                this.result = result
                when (call.method) {
                    "isLocationEnabled" -> {
                        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                        val isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
                        val isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        result.success(isGpsEnabled || isNetworkEnabled)
                    }
                    "enableLocation" -> {
                        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                        val isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
                        val isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        if (!isGpsEnabled && !isNetworkEnabled) {
                            val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                            startActivityForResult(intent, LOCATION_SETTINGS_REQUEST)
                        } else {
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isDevicePaired(deviceName: String, result: MethodChannel.Result) {
        bluetoothAdapter?.bondedDevices?.forEach { device ->
            if (device.name == deviceName) {
                result.success(true)
                return
            }
        }
        result.success(false)
    }

    private fun pairWithDevice(deviceAddress: String, result: MethodChannel.Result) {
        val device: BluetoothDevice? = bluetoothAdapter?.getRemoteDevice(deviceAddress)
        if (device != null) {
            device.createBond()
            result.success(true)
        } else {
            result.error("DEVICE_NOT_FOUND", "Device not found", null)
        }
    }

    private fun unpairWithDeviceByName(deviceName: String, result: MethodChannel.Result) {
        bluetoothAdapter?.bondedDevices?.forEach { device ->
            if (device.name == deviceName) {
                try {
                    val method = device.javaClass.getMethod("removeBond")
                    method.invoke(device)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UNPAIR_FAILED", "Failed to unpair device", null)
                }
                return
            }
        }
        result.error("DEVICE_NOT_FOUND", "Device not found", null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == LOCATION_SETTINGS_REQUEST) {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
            val isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
            result?.success(isGpsEnabled || isNetworkEnabled)
        } else if (requestCode == BLUETOOTH_REQUEST) {
            val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
            result?.success(bluetoothAdapter?.isEnabled == true)
        }
    }
}

