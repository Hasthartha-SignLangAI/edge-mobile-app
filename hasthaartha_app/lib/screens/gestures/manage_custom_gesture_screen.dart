import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/providers/custom_gesture_provider.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';

class ManageCustomGestureScreen extends ConsumerWidget {
  const ManageCustomGestureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gesturesAsync = ref.watch(customGesturesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Manage Gestures",
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
          child: gesturesAsync.when(
            data: (gestures) {
              if (gestures.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                itemCount: gestures.length,
                itemBuilder: (context, index) {
                  final g = gestures[index];

                  // Format dates simply for UI
                  final dateStr =
                      "${g.createdAt.toLocal().day}/${g.createdAt.toLocal().month}/${g.createdAt.toLocal().year}";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                        BoxShadow(
                          color: const Color(
                            0xFF1976D2,
                          ).withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF90CAF9,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.back_hand_rounded,
                              color: Color(0xFF1976D2),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.data_usage_rounded,
                                      size: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${g.sampleCount} Samples",
                                      style: GoogleFonts.inter(
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.inter(
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: const Color(0xFFE53935),
                            tooltip: "Delete gesture",
                            onPressed: () async {
                              await _confirmDelete(context, ref, g.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
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
              child: const Icon(
                Icons.back_hand_rounded,
                size: 64,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Gestures Yet",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't added any custom gestures. Navigate to Add Gesture to create one.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final repo = LocalRepo();

    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Delete Gesture",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Are you sure you want to delete this custom gesture? This action cannot be undone.",
          style: GoogleFonts.inter(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Delete",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
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