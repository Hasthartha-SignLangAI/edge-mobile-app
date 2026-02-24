import 'package:flutter/material.dart';

class BLEDeviceScreen extends StatefulWidget {
  const BLEDeviceScreen({super.key});

  @override
  State<BLEDeviceScreen> createState() => _BLEDeviceScreenState();
}

class _BLEDeviceScreenState extends State<BLEDeviceScreen>
    with TickerProviderStateMixin {
  // Mock data for other devices
  final List<Map<String, dynamic>> otherDevices = [
    {'name': 'Device Name'},
    {'name': 'Device Name'},
    {'name': 'Device Name'},
    {'name': 'Device Name'},
  ];

  bool isScanning = false;
  late AnimationController _radarController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
    });
    _radarController.repeat();
    // Simulate scan completion after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
        _radarController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF), // Very light blue
              Color(0xFFBFDFFF), // Slightly deeper blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Connect Armband',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Bluetooth Radar Scanning Animation
                  Center(
                    child: GestureDetector(
                      onTap: _startScanning,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background radar rings (static)
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4A90E2)
                                    .withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                          ),
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4A90E2)
                                    .withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4A90E2)
                                    .withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                          ),

                          // Animated scanning lines
                          if (isScanning)
                            RotationTransition(
                              turns: _radarController,
                              child: CustomPaint(
                                painter: RadarLinePainter(),
                                size: const Size(240, 240),
                              ),
                            ),

                          // Animated pulse rings
                          if (isScanning)
                            ScaleTransition(
                              scale: _pulseController,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF4A90E2)
                                        .withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                          // Center circle with Bluetooth icon
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF89C4FF),
                                  Color(0xFF4A90E2)
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A90E2)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 8),
                                ),
                                if (isScanning)
                                  BoxShadow(
                                    color: const Color(0xFF4A90E2)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                    offset: const Offset(0, 0),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bluetooth,
                                    size: 50,
                                    color: Colors.blue[900],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isScanning ? 'SCANNING...' : 'SCAN',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w800,
                                      fontSize: isScanning ? 14 : 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      isScanning
                          ? 'Searching for nearby devices...'
                          : 'Tap the radar to start scanning',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isScanning
                            ? const Color(0xFF4A90E2)
                            : Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: isScanning ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Connected Device Mock
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE5FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Device Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF689F38),
                        ), // Green check
                        const SizedBox(width: 15),
                        const Icon(Icons.more_vert, color: Colors.black87),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Other Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // List of other devices
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE5FF).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: otherDevices.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                otherDevices[index]['name'],
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.add_circle,
                                color: Color(0xFF689F38),
                              ), // Green plus
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for radar lines
class RadarLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF4A90E2).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw two scanning lines (sweeping effect)
    final radius = size.width / 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.9,
        center.dy,
      ),
      paint,
    );

    canvas.drawLine(
      center,
      Offset(
        center.dx - radius * 0.3,
        center.dy - radius * 0.8,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(RadarLinePainter oldDelegate) => true;
}
