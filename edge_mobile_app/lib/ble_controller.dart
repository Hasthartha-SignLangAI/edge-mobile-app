import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController {
  // Singleton pattern
  static final BleController _instance = BleController._internal();
  factory BleController() => _instance;
  BleController._internal();

  // Stream of scan results
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // Current connected device
  BluetoothDevice? connectedDevice;

  // Stream for connection state
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<void> init() async {
    // Check permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> startScan() async {
    // Check if scanning is already in progress
    if (FlutterBluePlus.isScanningNow) {
      return;
    }

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
    } catch (e) {
      debugPrint('Error connecting: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
        connectedDevice = null;
      } catch (e) {
        debugPrint('Error disconnecting: $e');
      }
    }
  }
}
