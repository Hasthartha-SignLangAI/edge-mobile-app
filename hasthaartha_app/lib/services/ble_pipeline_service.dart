import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'onnx_servce.dart';
import 'realtime_engine.dart';

class BlePipelineService {
  final OnnxService onnx;
  final RealtimeGestureEngine engine;

  BluetoothDevice? device;
  BluetoothCharacteristic? _streamChar;
  BluetoothCharacteristic? _ctrlChar;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _notifySub;

  final StreamController<String> gestureStream = StreamController.broadcast();

  int _lastSeq = -1;
  bool _calibrated = false;
  final List<List<double>> _idleBuffer = [];

  BlePipelineService({
    required this.onnx,
    required this.engine,
  });

  // =========================================================
  // SCAN
  // =========================================================
  Future<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 5)}) async {
    await _requestPermissions();

    final Map<DeviceIdentifier, ScanResult> unique = {};

    // stop any previous scan
    await FlutterBluePlus.stopScan().catchError((_) {});

    // listen results
    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        unique[r.device.remoteId] = r;
      }
    });

    if (!await FlutterBluePlus.isOn) {
      await FlutterBluePlus.turnOn();
    }

    // start scan
    await FlutterBluePlus.startScan(timeout: timeout);

    // wait until scan finishes
    await Future.delayed(timeout);

    // stop scan + cleanup
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

    // disconnect previous if any
    await disconnect();

    device = d;

    await device!.connect(autoConnect: false);

    // optional: request larger MTU (Android)
    // ignore errors on devices that don’t support it
    await device!.requestMtu(247).catchError((_) {});

    final services = await device!.discoverServices();

    _streamChar = null;
    _ctrlChar = null;

    for (final s in services) {
      for (final c in s.characteristics) {
        // IMPORTANT:
        // In production, you should match by SERVICE UUID + CHAR UUID
        // Here we pick first notify as stream, first write as ctrl
        if (_streamChar == null && c.properties.notify) {
          _streamChar = c;
        }
        if (_ctrlChar == null && (c.properties.write || c.properties.writeWithoutResponse)) {
          _ctrlChar = c;
        }
      }
    }

    if (_streamChar == null || _ctrlChar == null) {
      throw Exception("BLE characteristics not found (notify/write). Check UUIDs.");
    }

    // enable notifications
    await _streamChar!.setNotifyValue(true);

    _notifySub?.cancel();
    _notifySub = _streamChar!.lastValueStream.listen(_onPacket);

    // start streaming (control packet example)
    await _ctrlChar!.write([0x01], withoutResponse: _ctrlChar!.properties.writeWithoutResponse);

    // reset state for a clean session
    _lastSeq = -1;
    _calibrated = false;
    _idleBuffer.clear();
  }

  // =========================================================
  // DISCONNECT
  // =========================================================
  Future<void> disconnect() async {
    _notifySub?.cancel();
    _notifySub = null;

    if (_streamChar != null) {
      await _streamChar!.setNotifyValue(false).catchError((_) {});
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
  }

  void dispose() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    gestureStream.close();
  }

  // =========================================================
  // PACKET HANDLER
  // =========================================================
  void _onPacket(List<int> data) {
    // you may receive partial packets depending on your firmware/MTU strategy
    // For now, assume one notify = one full packet
    if (data.length < 32) return;
    if (data[0] != 0xAA || data[1] != 0x55) return;

    final seq = (data[4] << 8) | data[5];

    if (_lastSeq != -1 && seq != _lastSeq + 1) {
      // not fatal — just log
      // ignore: avoid_print
      print("⚠ Packet drop detected: last=$_lastSeq now=$seq");
    }
    _lastSeq = seq;

    // verify CRC
    final receivedCrc = (data[data.length - 2] << 8) | data[data.length - 1];
    final calculatedCrc = _crc16(data.sublist(0, data.length - 2));

    if (receivedCrc != calculatedCrc) {
      // ignore: avoid_print
      print("⚠ CRC mismatch");
      return;
    }

    // payload offset MUST match your ESP32 packet format
    // here: payload starts at byte 12, length 18 (9 * int16)
    if (data.length < 12 + 18 + 2) return;
    final payload = data.sublist(12, 12 + 18);

    final frame9 = _decodeFrame(payload);

    // ==========================
    // AUTO IDLE CALIBRATION
    // ==========================
    if (!_calibrated) {
      _idleBuffer.add(frame9);

      // 200 frames @100Hz ≈ 2 seconds idle
      if (_idleBuffer.length >= 200) {
        engine.calibrateIdle(_idleBuffer);
        _calibrated = true;
        // ignore: avoid_print
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
  // DECODE INT16 FRAME
  // =========================================================
  List<double> _decodeFrame(List<int> p) {
    final bd = ByteData.sublistView(Uint8List.fromList(p));

    int i16(int o) => bd.getInt16(o, Endian.little);

    final emg1 = i16(0).toDouble();
    final emg2 = i16(2).toDouble();
    final emg3 = i16(4).toDouble();

    final ax = i16(6) / 10000.0;
    final ay = i16(8) / 10000.0;
    final az = i16(10) / 10000.0;

    final gx = i16(12) / 100.0;
    final gy = i16(14) / 100.0;
    final gz = i16(16) / 100.0;

    return [emg1, emg2, emg3, ax, ay, az, gx, gy, gz];
  }

  // =========================================================
  // INFERENCE
  // =========================================================
  Future<void> _runInference(List<List<double>> window) async {
    try {
      final base = await onnx.predictWord(window);
      final few = await onnx.predictFewShot(window);

      final finalGesture = _vote(base, few);
      gestureStream.add(finalGesture);
    } catch (e) {
      // ignore: avoid_print
      print("❌ Inference error: $e");
    }
  }

  String _vote(String base, String few) {
    if (base == few) return base;
    return base; // base priority (we can upgrade later)
  }

  // =========================================================
  // CRC16 (CCITT-FALSE poly 0x1021)
  // =========================================================
  int _crc16(List<int> data) {
    int crc = 0xFFFF;
    for (final b in data) {
      crc ^= (b & 0xFF) << 8;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
        crc &= 0xFFFF;
      }
    }
    return crc;
  }

  Future<void> _requestPermissions() async {
    // Android 12+: scan/connect permissions
    // Android <12: location is required for scan
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }
}