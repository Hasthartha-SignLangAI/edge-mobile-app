import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';

class BLEDeviceScreen extends ConsumerStatefulWidget {
  const BLEDeviceScreen({super.key});

  @override
  ConsumerState<BLEDeviceScreen> createState() =>
      _BLEDeviceScreenState();
}



class _BLEDeviceScreenState extends ConsumerState<BLEDeviceScreen>
    with TickerProviderStateMixin {

  bool isScanning = false;
  List<ScanResult> scanResults = [];

  BluetoothConnectionState connectionState =
      BluetoothConnectionState.disconnected;

  late BlePipelineService bleService;

  late AnimationController _radarController;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  @override
  void initState() {
    super.initState();

    bleService = ref.read(blePipelineProvider);

    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 🔥 1️⃣ Immediately sync existing connection state
    _initializeConnectionState();

    // 🔥 2️⃣ Continue listening for updates
    _connSub = bleService.connectionStream.listen((state) {
      setState(() {
        connectionState = state;
      });
    });
  }

  // =====================================================
  // 🔥 SYNC EXISTING CONNECTION
  // =====================================================

  Future<void> _initializeConnectionState() async {
    final device = bleService.device;

    if (device != null) {
      final state = await device.connectionState.first;

      setState(() {
        connectionState = state;
      });
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _radarController.dispose();
    super.dispose();
  }

  // =====================================================
  // SCAN
  // =====================================================

  Future<void> _startScanning() async {

    // ❌ Prevent scan if already connected
    if (connectionState == BluetoothConnectionState.connected) {
      return;
    }

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    _radarController.repeat();

    try {
      final results = await bleService.scan();

      setState(() {
        scanResults = results;
      });

    } catch (e) {
      print("Scan error: $e");
    }

    setState(() {
      isScanning = false;
    });

    _radarController.stop();
  }

  // =====================================================
  // CONNECT
  // =====================================================

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await bleService.connect(device);
    } catch (e) {
      print("Connection error: $e");
    }
  }

  // =====================================================
  // DISCONNECT
  // =====================================================

  Future<void> _disconnect() async {
    await bleService.disconnect();
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final connectedDevice = bleService.device;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFBFDFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Text(
                  'Connect Armband',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // Radar Button
                GestureDetector(
                  onTap: _startScanning,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      for (double size in [240, 160, 80])
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4A90E2)
                                  .withOpacity(0.2),
                            ),
                          ),
                        ),

                      if (isScanning)
                        RotationTransition(
                          turns: _radarController,
                          child: CustomPaint(
                            painter: RadarLinePainter(),
                            size: const Size(240, 240),
                          ),
                        ),

                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF89C4FF),
                              Color(0xFF4A90E2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isScanning ? 'SCANNING...' : 'SCAN',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================================
                // CONNECTION STATUS (NOW PERSISTENT)
                // =====================================================

                if (connectionState == BluetoothConnectionState.connected &&
                    connectedDevice != null)
                  Column(
                    children: [
                      Text(
                        "Connected: ${connectedDevice.platformName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _disconnect,
                        icon: const Icon(Icons.logout),
                        label: const Text("Disconnect"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  )
                else if (connectionState ==
                    BluetoothConnectionState.connecting)
                  const Text(
                    "Connecting...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                else
                  const Text(
                    "Not Connected",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                const SizedBox(height: 20),

                // =====================================================
                // SCAN RESULTS
                // =====================================================

                Expanded(
                  child: ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final result = scanResults[index];
                      final device = result.device;

                      return ListTile(
                        title: Text(
                          device.platformName.isEmpty
                              ? device.remoteId.str
                              : device.platformName,
                        ),
                        subtitle: Text("RSSI: ${result.rssi}"),
                        trailing: const Icon(Icons.bluetooth),
                        onTap: () => _connectToDevice(device),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadarLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.6)
      ..strokeWidth = 2;

    final radius = size.width / 2;

    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.9, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}