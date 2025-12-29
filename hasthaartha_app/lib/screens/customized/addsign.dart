import 'package:flutter/material.dart';
import 'package:hasthaartha_app/screens/customized/sinhalameaning.dart';

class AddSignPage extends StatefulWidget {
  const AddSignPage({super.key});

  @override
  State<AddSignPage> createState() => _AddSignPageState();
}

class _AddSignPageState extends State<AddSignPage> {
  // Gesture attempt tracking
  List<bool> done = [false, false, false, false, false];
  int currentStep = 0;

  void markStepDone(int index) {
    setState(() {
      done[index] = true;
    });
  }

  String _ordinal(int index) {
    switch (index) {
      case 0:
        return "1st";
      case 1:
        return "2nd";
      case 2:
        return "3rd";
      case 3:
        return "4th";
      case 4:
      default:
        return "5th";
    }
  }

  void _onAddPressed() {
    // If we have not yet completed all 5 steps
    if (currentStep < 4) {
      markStepDone(currentStep);
      currentStep++;
    } else {
      // This is the 5th tap:
      markStepDone(currentStep);

      // Navigate to SinhalaMeaningPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SinhalaMeaningPage(),
        ),
      );
    }
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
                  onTap: _onAddPressed,
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
                                _ordinal(index),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            done[index]
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 22,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.black54,
                                    size: 22,
                                  ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Page indicator dots (this is step 2)
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
