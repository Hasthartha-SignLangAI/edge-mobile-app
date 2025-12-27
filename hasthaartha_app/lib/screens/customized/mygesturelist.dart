import 'package:flutter/material.dart';

class MyGestureListPage extends StatelessWidget {
  const MyGestureListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for now – later you can replace with real saved gestures
    final gestures = [
      "Gesture 01",
      "Gesture 02",
      "Gesture 03",
      "Gesture 04",
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDFEFF), // almost white
              Color(0xFFBBD9FF), // light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Title
                const Text(
                  'My Gesture List',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // Card with gesture rows
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: gestures
                        .map(
                          (g) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: _GestureRow(
                              label: g,
                              onUse: () {
                                // TODO: handle "Use" (e.g. go to live translation page)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Using $g'),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const Spacer(),

                // Page indicator dots (second one active)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _PageDot(isActive: false),
                    SizedBox(width: 8),
                    _PageDot(isActive: true),
                    SizedBox(width: 8),
                    _PageDot(isActive: false),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GestureRow extends StatelessWidget {
  final String label;
  final VoidCallback onUse;

  const _GestureRow({
    required this.label,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: onUse,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                backgroundColor: const Color(0xFF002766),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Use',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;
  const _PageDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
