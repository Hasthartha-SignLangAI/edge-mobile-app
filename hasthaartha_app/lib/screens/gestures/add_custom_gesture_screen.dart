import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/providers/enrollment_provider.dart';

class AddCustomGestureScreen extends ConsumerStatefulWidget {
  const AddCustomGestureScreen({super.key});

  @override
  ConsumerState<AddCustomGestureScreen> createState() =>
      _AddCustomGestureScreenState();
}

class _AddCustomGestureScreenState
    extends ConsumerState<AddCustomGestureScreen> {
  final TextEditingController _gestureController = TextEditingController();

  int _samples = 10;
  double _duration = 6;

  /// Tracks whether enrollment was active on the last state update so we
  /// can detect the active → inactive transition (done / cancelled / error).
  bool _wasEnrollmentActive = false;

  StreamSubscription? _enrollmentSub;

  @override
  void initState() {
    super.initState();

    // Watch enrollment state changes to stop BLE streaming automatically
    // when enrollment ends (done, cancelled, or error).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(enrollmentServiceProvider);
      _enrollmentSub = service.stateStream.listen((state) {
        if (_wasEnrollmentActive && !state.active) {
          // Enrollment just became inactive — stop streaming.
          ref.read(blePipelineProvider).stopStreaming();
        }
        _wasEnrollmentActive = state.active;
      });
    });
  }

  @override
  void dispose() {
    _enrollmentSub?.cancel();
    _gestureController.dispose();
    super.dispose();
  }


  String _stageText(dynamic stage) => stage.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    final enrollmentState = ref.watch(enrollmentStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Add Custom Gesture",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFDEEDFF), Color(0xFFC7E2FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: enrollmentState.when(
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputSection(),
                  const SizedBox(height: 32),
                  _buildControlButtons(state),
                  const SizedBox(height: 32),
                  _buildStatusCard(state),
                  const SizedBox(height: 20),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFF1976D2)),
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  e.toString(),
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gesture Configuration",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Gesture Name",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF455A64),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gestureController,
            style: GoogleFonts.inter(color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              hintText: "Enter gesture name",
              hintStyle: GoogleFonts.inter(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Samples",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF455A64),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _samples,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(
                              0xFF1976D2,
                            ).withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1976D2),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      items: [5, 10, 15, 20]
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text("$e")),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _samples = v);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Duration (s)",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF455A64),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<double>(
                      value: _duration,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(
                              0xFF1976D2,
                            ).withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1976D2),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      items: [3, 4, 5, 6, 7, 8]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.toDouble(),
                              child: Text("$e s"),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _duration = v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(state) {
    final service = ref.read(enrollmentServiceProvider);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: state.active
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: state.active
                  ? null
                  : () async {
                      final bleService = ref.read(blePipelineProvider);
                      // Capture messenger before any async gap.
                      final messenger = ScaffoldMessenger.of(context);

                      // Start BLE streaming before beginning enrollment.
                      try {
                        await bleService.startStreaming();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not start streaming: $e',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: const Color(0xFFE53935),
                          ),
                        );
                        return;
                      }

                      await service.startEnrollment(
                        word: _gestureController.text,
                        samples: _samples,
                        durationSec: _duration,
                      );
                    },


              child: Text(
                "Start Enrollment",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: BorderSide(
                  color: state.active
                      ? const Color(0xFFE53935).withValues(alpha: 0.5)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: state.active ? service.cancelEnrollment : null,
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: const Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Enrollment Status",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusRow("Stage", _stageText(state.stage)),
          const SizedBox(height: 12),
          _buildStatusRow(
            "Samples",
            "${state.samplesDone} / ${state.samplesTarget}",
          ),
          if (state.countdown != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow(
              "Countdown",
              "${state.countdown}s",
              valueColor: const Color(0xFFE53935), // Red color for countdown
            ),
          ],
          if (state.message != null || state.error != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.black12, height: 1),
            ),
            if (state.message != null)
              Text(
                state.message!,
                style: GoogleFonts.inter(
                  color: const Color(0xFF00897B),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            if (state.error != null)
              Text(
                state.error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF455A64),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (valueColor ?? const Color(0xFF1976D2)).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: valueColor ?? const Color(0xFF1976D2),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}