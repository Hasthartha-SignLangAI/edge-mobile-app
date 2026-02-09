import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

/// Debug panel showing EMG/IMU data and performance metrics
/// Hidden by default, revealed by triple-tap on connection icon
class DebugPanel extends StatelessWidget {
  final bool isVisible;
  final double fps;
  final int latencyMs;
  final List<double> emgData;
  final List<double> imuData;

  const DebugPanel({
    super.key,
    required this.isVisible,
    this.fps = 60.0,
    this.latencyMs = 0,
    this.emgData = const [],
    this.imuData = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF00).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEBUG MODE',
                style: GoogleFonts.robotoMono(
                  color: const Color(0xFF00FF00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.bug_report, color: const Color(0xFF00FF00), size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // Performance Metrics
          _buildMetricRow('FPS', fps.toStringAsFixed(1), Colors.greenAccent),
          _buildMetricRow(
            'Latency',
            '${latencyMs}ms',
            latencyMs < 100 ? Colors.greenAccent : Colors.orangeAccent,
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // EMG Chart
          if (emgData.isNotEmpty) ...[
            Text(
              'EMG Signals (8 channels)',
              style: GoogleFonts.robotoMono(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: _buildLineChart(emgData, const Color(0xFF00BCD4)),
            ),
            const SizedBox(height: 16),
          ],

          // IMU Chart
          if (imuData.isNotEmpty) ...[
            Text(
              'IMU Data (Accel/Gyro)',
              style: GoogleFonts.robotoMono(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: _buildLineChart(imuData, const Color(0xFFFF9800)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> data, Color color) {
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: -1,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
