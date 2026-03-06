import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/providers/custom_gesture_provider.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';

class ManageCustomGestureScreen extends ConsumerWidget {
  const ManageCustomGestureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gesturesAsync = ref.watch(customGesturesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Custom Gestures"),
      ),
      body: gesturesAsync.when(
        data: (gestures) {
          if (gestures.isEmpty) {
            return const Center(
              child: Text("No custom gestures added yet."),
            );
          }

          return ListView.builder(
            itemCount: gestures.length,
            itemBuilder: (context, index) {
              final g = gestures[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    g.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Samples: ${g.sampleCount} • Created: ${g.createdAt.toLocal()}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await _confirmDelete(context, ref, g.id);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, int id) async {
    final repo = LocalRepo();

    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Gesture"),
        content: const Text(
            "Are you sure you want to delete this custom gesture?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repo.deleteCustomGesture(id);

      // refresh provider
      ref.invalidate(customGesturesProvider);
    }
  }
}