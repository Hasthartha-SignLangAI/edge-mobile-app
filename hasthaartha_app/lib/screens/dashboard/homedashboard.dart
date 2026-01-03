import 'package:flutter/material.dart';

import 'package:hasthaartha_app/screens/auth/login.dart';
import 'package:hasthaartha_app/screens/customized/mygesturelist.dart';
import 'package:hasthaartha_app/screens/dashboard/bledevice.dart';
import 'package:hasthaartha_app/services/auth_service.dart';
import 'package:hasthaartha_app/screens/history/history.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';

class HomeDashboard extends StatefulWidget {
  final String userName;
  const HomeDashboard({super.key, required this.userName});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F7FF), // Very light blue
              Color(0xFFDEEDFF), // Soft blue
              Color(0xFFC7E2FF), // Medium soft blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1), // Deep Blue
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    _buildLogoutButton(),
                  ],
                ),

                const SizedBox(height: 25),

                // Status Bar (Connected)
                _buildConnectionStatus(),

                const SizedBox(height: 30),

                // Hero Banner
                _buildHeroBanner(),

                const SizedBox(height: 30),

                // Primary Action
                _buildPrimaryActionButton(
                  title: 'Start Translating',
                  icon: Icons.mic_none_rounded, // Or gesture icon
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await LocalRepo().addHistory(
                      gestureLabel: "HELLO",
                      sinhalaText: "ආයුබෝවන්",
                      confidence: 0.92,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text("Dummy history saved"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF1E88E5),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Grid Menu
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        title: 'History',
                        icon: Icons.history_rounded,
                        colorStart: const Color(0xFF1A3B8C),
                        colorEnd: const Color(0xFF2C56B5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMenuCard(
                        title: 'Gestures',
                        icon: Icons.back_hand_rounded,
                        colorStart: const Color(
                          0xFF00695C,
                        ), // Teal-ish for variety but keeping theme harmony
                        colorEnd: const Color(0xFF00897B),
                        onTap: () {
                          // Navigate to gestures
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyGestureListPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Settings Full Width
                _buildMenuCard(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  isFullWidth: true,
                  colorStart: const Color(0xFF455A64),
                  colorEnd: const Color(0xFF607D8B),
                  onTap: () {
                    // Navigate to settings
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          await AuthService().signOut();
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        },
        icon: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFFF5252),
        ), // Soft red for logout
        tooltip: 'Logout',
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BLEDeviceScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB3D9FF).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bluetooth_connected_rounded,
                color: Colors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Device Connected',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)], // Rich Blue Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hasthaartha',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bridging communication gaps with smart gestures.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE3F2FD),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.graphic_eq_rounded, // Sound/Gesture wave representative
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2962FF), Color(0xFF448AFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2962FF).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color colorStart,
    required Color colorEnd,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isFullWidth ? 90 : 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorStart, colorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorStart.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isFullWidth
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
