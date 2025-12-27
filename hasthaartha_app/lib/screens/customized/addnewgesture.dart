import 'package:flutter/material.dart';

class AddGesturePage extends StatelessWidget {
  const AddGesturePage({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Title
              const Text(
                'Add Gesture',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              // Big circular "Add" button
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: handle "Add" tap (start recording etc.)
                  },
                  child: Container(
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
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Subtitle
              const Text(
                'Personalize your sign',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Instruction paragraph
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "To personalize your sign gesture, follow these steps:\n\n"
                  "1. Perform your new gesture and hold it still. We will capture it.\n"
                  "2. Repeat the same gesture 5 times, one by one, for better accuracy.\n"
                  "3. After the 5 recordings, enter the meaning of the sign gesture in Sinhala.\n"
                  "4. Press the Save button to store your personalized gesture.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // Page indicator dots
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _PageDot(isActive: false),
                    SizedBox(width: 8),
                    _PageDot(isActive: true), // middle active
                    SizedBox(width: 8),
                    _PageDot(isActive: false),
                  ],
                ),
              ),
            ],
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
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
