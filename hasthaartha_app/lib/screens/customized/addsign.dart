import 'package:flutter/material.dart';

class AddGesturePage extends StatefulWidget {
  const AddGesturePage({super.key});

  @override
  State<AddGesturePage> createState() => _AddGesturePageState();
}

class _AddGesturePageState extends State<AddGesturePage> {
  // Gesture attempt tracking
  List<bool> done = [false, false, false, false, false];
  int currentStep = 0;

  void markStepDone(int index) {
    setState(() {
      done[index] = true;
      if (currentStep < 4) currentStep++;
    });
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
                  'Add Gesture',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Big Add Gesture Button
                GestureDetector(
                  onTap: () {
                    if (currentStep < 5) {
                      markStepDone(currentStep);
                    }
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
                ),

                const SizedBox(height: 40),

                // Subtitle
                const Text(
                  "Enter five times your new sign",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // Input Steps Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${index + 1}st".replaceFirst('1st', '1st') // keep readable
                                    .replaceFirst('2st', '2nd')
                                    .replaceFirst('3st', '3rd')
                                    .replaceFirst('4st', '4th')
                                    .replaceFirst('5st', '5th'),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            done[index]
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green, size: 22)
                                : const Icon(Icons.circle_outlined,
                                    color: Colors.black54, size: 22),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _PageDot(isActive: false),
                    SizedBox(width: 8),
                    _PageDot(isActive: false),
                    SizedBox(width: 8),
                    _PageDot(isActive: true), // active page
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
