import 'package:flutter/material.dart';

class LogoScreen extends StatelessWidget {
  const LogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150, // Adjust size as needed
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                // Placeholder if asset is missing
                return const Icon(
                  Icons
                      .fingerprint, // Relevant icon for "Hasthaartha" (sounds like hand/meaning)
                  size: 100,
                  color: Colors.black,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Hasthaartha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007BFF), // Blue color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
