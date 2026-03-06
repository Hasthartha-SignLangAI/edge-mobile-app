import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _stageText(stage) {
    return stage.toString().split('.').last;
  }

  int _samples = 10;
  double _duration = 6;

  @override
  Widget build(BuildContext context) {
    final enrollmentState = ref.watch(enrollmentStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Custom Gesture"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: enrollmentState.when(
          data: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputSection(),
              const SizedBox(height: 30),
              _buildControlButtons(state),
              const SizedBox(height: 40),
              _buildStatusCard(state),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gesture Name",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _gestureController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter gesture name",
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _samples,
                decoration: const InputDecoration(
                  labelText: "Samples",
                  border: OutlineInputBorder(),
                ),
                items: [5, 10, 15, 20]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text("$e"),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _samples = v);
                  }
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: DropdownButtonFormField<double>(
                value: _duration,
                decoration: const InputDecoration(
                  labelText: "Duration (s)",
                  border: OutlineInputBorder(),
                ),
                items: [3, 4, 5, 6, 7, 8]
                    .map((e) => DropdownMenuItem(
                          value: e.toDouble(),
                          child: Text("$e s"),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _duration = v);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(state) {
    final service = ref.read(enrollmentServiceProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: state.active
                ? null
                : () async {
                    await service.startEnrollment(
                      word: _gestureController.text,
                      samples: _samples,
                      durationSec: _duration,
                    );
                  },
            child: const Text("Start Enrollment"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: state.active ? service.cancelEnrollment : null,
            child: const Text("Cancel"),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(state) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Stage: ${_stageText(state.stage)}"),
            const SizedBox(height: 6),
            Text("Samples: ${state.samplesDone}/${state.samplesTarget}"),
            const SizedBox(height: 6),
            if (state.countdown != null)
              Text("Countdown: ${state.countdown}"),
            const SizedBox(height: 6),
            if (state.message != null)
              Text(
                state.message!,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            if (state.error != null)
              Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}