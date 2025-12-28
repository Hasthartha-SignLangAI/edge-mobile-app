import 'package:flutter/material.dart';

class Splash3 extends StatelessWidget {
  const Splash3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Wave Background
          ClipPath(
            clipper: Splash3WaveClipper(),
            child: Container(
              height: 300, // Adjusted height for proportion
              color: const Color(0xFF007BFF),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.only(top: 20.0, right: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Who can use ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007BFF),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Central Image
          Image.asset(
            'assets/images/splash3.png',
            height: 250,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 30),

          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Designed specifically for friends with\nspeaking difficulties',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(false),
              const SizedBox(width: 8),
              _buildDot(false),
              const SizedBox(width: 8),
              _buildDot(true),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF007BFF) : Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class Splash3WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start at top-left
    path.lineTo(0, size.height * 0.7);

    // Simple wave curve
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.2, size.height * 0.85);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.7, size.height * 0.65);
    var secondEndPoint = Offset(size.width, size.height * 0.8);

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
