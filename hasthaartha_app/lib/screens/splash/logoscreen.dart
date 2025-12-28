import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hasthaartha_app/screens/splash/splash1.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Splash1()),
      );
    });
  }

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
                
                return const Icon(
                  Icons.fingerprint, //icon for "Hasthaartha"
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
                color: Color(0xFF007BFF), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
