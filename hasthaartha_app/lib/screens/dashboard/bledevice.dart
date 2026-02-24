import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEDeviceScreen extends StatefulWidget {
  const BLEDeviceScreen({super.key});

  @override
  State<BLEDeviceScreen> createState() => _BLEDeviceScreenState();
}

class _BLEDeviceScreenState extends State<BLEDeviceScreen>
    with TickerProviderStateMixin {

  bool isScanning = false;
  bool isConnected = false;

  late AnimationController _radarController;

  final List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  // =====================================================
  // PERMISSIONS
  // =====================================================

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // =====================================================
  // SCAN
  // =====================================================

  Future<void> _startScanning() async {
    await _requestPermissions();

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    _radarController.repeat();

    final Map<DeviceIdentifier, ScanResult> unique = {};

    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        unique[r.device.remoteId] = r;
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    await Future.delayed(const Duration(seconds: 5));


    setState(() {
      scanResults.addAll(unique.values);
      isScanning = false;
    });

    _radarController.stop();
  }

  // =====================================================
  // CONNECT
  // =====================================================

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);

      setState(() {
        connectedDevice = device;
        isConnected = true;
      });

      // Navigate to prediction screen
      Navigator.pushNamed(
        context,
        "/prediction",
        arguments: device,
      );

    } catch (e) {
      print("Connection error: $e");
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
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
                                  .withValues(alpha: 0.2),
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

                if (isConnected && connectedDevice != null)
                  Text(
                    "Connected: ${connectedDevice!.platformName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                const SizedBox(height: 20),

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
      ..color = const Color(0xFF4A90E2)
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