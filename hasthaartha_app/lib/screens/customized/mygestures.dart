import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Gestures',
      home: const MyGesturesPage(),
    );
  }
}

class MyGesturesPage extends StatelessWidget {
  const MyGesturesPage({super.key});

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
              Color(0xFFFDFEFF), // top (almost white)
              Color(0xFFBBD9FF), // bottom light blue – tweak as you like
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Title
              const Text(
                'My Gestures',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 56),

              // Icon / image in the middle
              // TODO: replace with your real asset
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/images/hand_sign.png',
                  fit: BoxFit.contain,
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

              const SizedBox(height: 24),

              // Description text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "To personalize your sign gesture, please follow the steps below:\n\n"
  "1. Perform your new gesture once and hold it still — we will capture it.\n"
  "2. Repeat the same gesture 5 times, one by one, for better accuracy.\n"
  "3. After the 5 recordings, enter the meaning of the gesture in Sinhala.\n"
  "4. Press the Save button to store your personalized gesture.\n\n"
  "Make sure you perform the gesture clearly and consistently for the best results.",
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 13,
    height: 1.4,
                  ),
                ),
              ),

              // push content a bit up (optional)
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
