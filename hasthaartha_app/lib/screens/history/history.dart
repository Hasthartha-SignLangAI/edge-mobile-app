import 'package:flutter/material.dart';
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
        title: const Text("Clear history?"),
        content: const Text("This will delete all saved gesture records."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear"),
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
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            onPressed: _items.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear history",
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const _EmptyState()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
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
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFFD6E4FF),
                  ),
                  child: Text(
                    "$confPct%",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A3B8C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sinhala,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3B8C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeText,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontSize: 12,
              ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 52,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 12),
            const Text(
              "No history yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              "Start translating to see saved gestures here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
