import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'onnx_servce.dart';
import 'realtime_engine.dart';

class BlePipelineService {
  // =========================================================
  // 🔥 YOUR CUSTOM GATT UUIDs
  // =========================================================

  static const String SERVICE_UUID =
      "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";

  static const String TX_UUID =
      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Notify

  static const String CTRL_RX_UUID =
      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // Write

  final OnnxService onnx;
  final RealtimeGestureEngine engine;

  BluetoothDevice? device;
  BluetoothCharacteristic? _streamChar;
  BluetoothCharacteristic? _ctrlChar;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  final StreamController<String> gestureStream =
      StreamController.broadcast();

  final StreamController<BluetoothConnectionState> _connectionController =
    StreamController<BluetoothConnectionState>.broadcast();

  Stream<BluetoothConnectionState> get connectionStream =>
      _connectionController.stream;

  int _lastSeq = -1;
  bool _calibrated = false;
  final List<List<double>> _idleBuffer = [];

  BlePipelineService({
    required this.onnx,
    required this.engine,
  });


  // =========================================================
  // SCAN (Filtered by SERVICE UUID)
  // =========================================================
  Future<List<ScanResult>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await _requestPermissions();

    final Map<DeviceIdentifier, ScanResult> unique = {};

    await FlutterBluePlus.stopScan().catchError((_) {});
    _scanSub?.cancel();

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        unique[r.device.remoteId] = r;
      }
    });

    if (!await FlutterBluePlus.isOn) {
      await FlutterBluePlus.turnOn();
    }

    await FlutterBluePlus.startScan(
      withServices: [Guid(SERVICE_UUID)],
      timeout: timeout,
    );

    await Future.delayed(timeout);

    await FlutterBluePlus.stopScan().catchError((_) {});
    await _scanSub?.cancel();
    _scanSub = null;

    return unique.values.toList();
  }

  // =========================================================
  // CONNECT
  // =========================================================
  Future<void> connect(BluetoothDevice d) async {
    await _requestPermissions();

    await disconnect();

    device = d;

    await device!.connect(autoConnect: false);

    // 🔥 Listen connection state
    _connSub?.cancel();
    _connSub = device!.connectionState.listen((state) {
      _connectionController.add(state);
    });

    await device!.requestMtu(247).catchError((_) {});

    final services = await device!.discoverServices();

    _streamChar = null;
    _ctrlChar = null;

    for (final s in services) {
      if (s.uuid.toString().toUpperCase() == SERVICE_UUID) {
        for (final c in s.characteristics) {
          final uuid = c.uuid.toString().toUpperCase();

          if (uuid == TX_UUID) {
            _streamChar = c;
          }

          if (uuid == CTRL_RX_UUID) {
            _ctrlChar = c;
          }
        }
      }
    }

    if (_streamChar == null || _ctrlChar == null) {
      throw Exception("Required BLE characteristics not found.");
    }

    await _streamChar!.setNotifyValue(true);

    _notifySub?.cancel();
    _notifySub =
        _streamChar!.lastValueStream.listen(_onPacket);

    await _ctrlChar!.write(
      [0x01],
      withoutResponse: _ctrlChar!.properties.writeWithoutResponse,
    );

    _lastSeq = -1;
    _calibrated = false;
    _idleBuffer.clear();
  }

  // =========================================================
  // DISCONNECT
  // =========================================================
  Future<void> disconnect() async {
    _notifySub?.cancel();
    _connSub?.cancel();

    if (_streamChar != null) {
      await _streamChar!
          .setNotifyValue(false)
          .catchError((_) {});
    }

    if (device != null) {
      await device!.disconnect().catchError((_) {});
    }

    device = null;
    _streamChar = null;
    _ctrlChar = null;

    _lastSeq = -1;
    _calibrated = false;
    _idleBuffer.clear();

    _connectionController.add(BluetoothConnectionState.disconnected);
  }

  void dispose() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _connSub?.cancel();
    gestureStream.close();
    _connectionController.close();
  }

  // =========================================================
  // PACKET HANDLER
  // =========================================================
  void _onPacket(List<int> data) {
    if (data.length < 32) return;
    if (data[0] != 0xAA || data[1] != 0x55) return;

    final seq = (data[4] << 8) | data[5];

    if (_lastSeq != -1 && seq != _lastSeq + 1) {
      print("⚠ Packet drop detected");
    }
    _lastSeq = seq;

    final receivedCrc =
        (data[data.length - 2] << 8) | data[data.length - 1];

    final calculatedCrc =
        _crc16(data.sublist(0, data.length - 2));

    if (receivedCrc != calculatedCrc) return;

    if (data.length < 12 + 18 + 2) return;

    final payload = data.sublist(12, 12 + 18);
    final frame9 = _decodeFrame(payload);

    if (!_calibrated) {
      _idleBuffer.add(frame9);
      if (_idleBuffer.length >= 200) {
        engine.calibrateIdle(_idleBuffer);
        _calibrated = true;
        print("✅ Idle calibrated");
      }
      return;
    }

    final window = engine.pushFrame(frame9);
    if (window != null) {
      _runInference(window);
    }
  }

  // =========================================================
  // DECODE
  // =========================================================
  List<double> _decodeFrame(List<int> p) {
    final bd = ByteData.sublistView(Uint8List.fromList(p));
    int i16(int o) => bd.getInt16(o, Endian.little);

    return [
      i16(0).toDouble(),
      i16(2).toDouble(),
      i16(4).toDouble(),
      i16(6) / 10000.0,
      i16(8) / 10000.0,
      i16(10) / 10000.0,
      i16(12) / 100.0,
      i16(14) / 100.0,
      i16(16) / 100.0,
    ];
  }

  // =========================================================
  // INFERENCE
  // =========================================================
  Future<void> _runInference(List<List<double>> window) async {
    try {
      final base = await onnx.predictWord(window);
      final few = await onnx.predictFewShot(window);

      gestureStream.add(base == few ? base : base);
    } catch (e) {
      print("❌ Inference error: $e");
    }
  }

  int _crc16(List<int> data) {
    int crc = 0xFFFF;
    for (final b in data) {
      crc ^= (b & 0xFF) << 8;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0
            ? ((crc << 1) ^ 0x1021)
            : (crc << 1);
        crc &= 0xFFFF;
      }
    }
    return crc;
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }
}