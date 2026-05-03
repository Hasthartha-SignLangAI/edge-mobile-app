import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';
import 'package:hasthaartha_app/main.dart';

class SensorMonitorScreen extends ConsumerWidget {
  const SensorMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleService = ref.watch(blePipelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Sensor Monitor"),
      ),
      body: StreamBuilder<List<double>>(
        stream: bleService.frameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Waiting for data..."),
            );
          }

          final values = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                _buildSectionTitle("EMG"),
                _buildValueTile("EMG 1", values[0]),
                _buildValueTile("EMG 2", values[1]),
                _buildValueTile("EMG 3", values[2]),

                const SizedBox(height: 20),

                _buildSectionTitle("Accelerometer"),
                _buildValueTile("Acc X", values[3]),
                _buildValueTile("Acc Y", values[4]),
                _buildValueTile("Acc Z", values[5]),

                const SizedBox(height: 20),

                _buildSectionTitle("Gyroscope"),
                _buildValueTile("Gyro X", values[6]),
                _buildValueTile("Gyro Y", values[7]),
                _buildValueTile("Gyro Z", values[8]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildValueTile(String label, double value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value.toStringAsFixed(3),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}