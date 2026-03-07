import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';
import 'package:hasthaartha_app/localdb/models/history_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = LocalRepo();
  bool _loading = true;
  List<HistoryRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.latestHistory(limit: 200);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Clear history?",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "This will delete all saved gesture records.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.inter()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Clear", style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await _repo.clearHistory();
    await _load();
  }

  String _timeText(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return "$h:$m  •  $d/$mo/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "History",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D47A1)),
        actions: [
          IconButton(
            onPressed: _items.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFE53935),
            tooltip: "Clear history",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFDEEDFF), Color(0xFFC7E2FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF1976D2),
                  backgroundColor: Colors.white,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return _HistoryCard(
                        label: item.gestureLabel,
                        sinhala: item.sinhalaText,
                        confidence: item.confidence,
                        timeText: _timeText(item.createdAt),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String label;
  final String sinhala;
  final double confidence;
  final String timeText;

  const _HistoryCard({
    required this.label,
    required this.sinhala,
    required this.confidence,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final confPct = (confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
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
            color: const Color(0xFF1976D2).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFFE3F2FD),
                    border: Border.all(
                      color: const Color(0xFF90CAF9).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    "$confPct%",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sinhala,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  timeText,
                  style: GoogleFonts.inter(
                    color: Colors.black.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Icons.history_rounded,
                size: 64,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No history yet",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start translating to see saved gestures here.",
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
}
