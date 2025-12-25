import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armband Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BleScanPage(),
    );
  }
}

class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  final BleController _bleController = BleController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initBle();
  }

  Future<void> _initBle() async {
    await _bleController.init();
    // Listen to scan state
    FlutterBluePlus.isScanning.listen((isScanning) {
      if (mounted) {
        setState(() {
          _isScanning = isScanning;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Armband'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Scan Button Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isScanning)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: () => _bleController.startScan(),
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Scan for Devices'),
                  ),
                const SizedBox(width: 16),
                if (_isScanning)
                  ElevatedButton(
                    onPressed: () => _bleController.stopScan(),
                    child: const Text('Stop Scan'),
                  ),
              ],
            ),
          ),

          // Device List
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: _bleController.scanResults,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No devices found.\nTap Scan to start.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final results = snapshot.data!;

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final device = result.device;
                    final name = device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Unknown Device';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: StreamBuilder<BluetoothConnectionState>(
                          stream: device.connectionState,
                          builder: (context, snapshot) {
                            final state =
                                snapshot.data ??
                                BluetoothConnectionState.disconnected;
                            if (state == BluetoothConnectionState.connected) {
                              return ElevatedButton(
                                onPressed: () => _bleController.disconnect(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                ),
                                child: const Text('Disconnect'),
                              );
                            }
                            return ElevatedButton(
                              onPressed: () => _bleController.connect(device),
                              child: const Text('Connect'),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
