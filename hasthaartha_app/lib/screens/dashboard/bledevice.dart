import 'package:flutter/material.dart';

class BLEDeviceScreen extends StatefulWidget {
  const BLEDeviceScreen({super.key});

  @override
  State<BLEDeviceScreen> createState() => _BLEDeviceScreenState();
}

class _BLEDeviceScreenState extends State<BLEDeviceScreen> {
  // Mock data for other devices
  final List<Map<String, dynamic>> otherDevices = [
    {'name': 'Device Name'},
    {'name': 'Device Name'},
    {'name': 'Device Name'},
    {'name': 'Device Name'},
  ];

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
                // Scan Button
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF89C4FF), Color(0xFF4A90E2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'SCAN',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.4,
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
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE5FF).withOpacity(
                        0.5,
                      ), // Lighter background for the list container
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: otherDevices.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors
                                .transparent,
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
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
