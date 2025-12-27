import 'package:flutter/material.dart';

class SinhalaMeaningPage extends StatefulWidget {
  const SinhalaMeaningPage({super.key});

  @override
  State<SinhalaMeaningPage> createState() => _SinhalaMeaningPageState();
}

class _SinhalaMeaningPageState extends State<SinhalaMeaningPage> {
  final TextEditingController _meaningController = TextEditingController();

  @override
  void dispose() {
    _meaningController.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _meaningController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the Sinhala meaning first.'),
        ),
      );
      return;
    }

    // TODO: handle saving the meaning (local DB / API / Firebase etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved meaning: $text'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Sinhala Meaning',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Big circle "Add" button (for consistency with other pages)
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE0ECFF),
                        Color(0xFF5B8CFF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Subtitle
                const Text(
                  'Enter the Sinhala word',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // Text field for Sinhala meaning
                TextField(
                  controller: _meaningController,
                  decoration: InputDecoration(
                    hintText: 'Enter Sinhala Meaning',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5B8CFF),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0057FF),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Page indicator (this is the 3rd step, so last dot active)
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

class _PageDot extends StatelessWidget {
  final bool isActive;
  const _PageDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
