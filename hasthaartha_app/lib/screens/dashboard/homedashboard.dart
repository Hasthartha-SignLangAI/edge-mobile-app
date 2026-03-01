import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hasthaartha_app/screens/auth/login.dart';
import 'package:hasthaartha_app/screens/customized/mygesturelist.dart';
import 'package:hasthaartha_app/screens/dashboard/bledevice.dart';
import 'package:hasthaartha_app/screens/translation/realtime_translation_screen.dart';
import 'package:hasthaartha_app/services/auth_service.dart';
import 'package:hasthaartha_app/screens/history/history.dart';
import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';
import 'package:hasthaartha_app/services/realtime_engine.dart'; // for onnxServiceProvider

class HomeDashboard extends ConsumerStatefulWidget {
  final String userName;
  const HomeDashboard({super.key, required this.userName});

  @override
  ConsumerState<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends ConsumerState<HomeDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  //bool _isConnected = true;
  String _pressedCard = '';

  //late final BlePipelineService bleService;

  @override
  void initState() {
    super.initState();

  //   bleService = BlePipelineService(
  //   onnx: OnnxService(),
  //   engine: RealtimeGestureEngine(),
  // );
    //   Future.microtask(() async {
    //   final onnx = ref.read(onnxServiceProvider);

    //   List<List<double>> dummy =
    //       List.generate(512, (_) => List.generate(9, (_) => 0.1));

    //   final word = await onnx.predictWord(dummy);

    //   debugPrint("🔥 Predicted Word: $word");
    // });

    Future.microtask(() async {
      final onnx = ref.read(onnxServiceProvider);

      final frames = await onnx.loadTxtFrames("assets/test/boru_5.txt");

      if (frames.length < 512) {
        print("Not enough frames: ${frames.length}");
        return;
      }

      // Center crop like training
      int start = (frames.length - 512) ~/ 2;
      final window = frames.sublist(start, start + 512);

      final word = await onnx.predictWord(window);

      print("🔥 REAL TXT PREDICTION: $word");
    });

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleService = ref.watch(blePipelineProvider);
    final isConnected = bleService.device != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFDEEDFF), Color(0xFFC7E2FF)],
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
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D47A1),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    _buildLogoutButton(),
                  ],
                ),

                const SizedBox(height: 25),

                _buildConnectionStatus(bleService),

                const SizedBox(height: 30),

                _buildHeroBanner(),

                const SizedBox(height: 30),

                _buildPrimaryActionButton(
                  title: 'Start Translating',
                  icon: Icons.mic_none_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RealtimeTranslationScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        title: 'History',
                        icon: Icons.history_rounded,
                        iconColor: const Color(0xFF1976D2),
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
                        iconColor: const Color(0xFF00897B),
                        onTap: () {
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

                Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        title: 'Profile',
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF8E24AA),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Profile coming soon!"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFF8E24AA),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMenuCard(
                        title: 'About',
                        icon: Icons.info_rounded,
                        iconColor: const Color(0xFFFF6F00),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("About page coming soon!"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFFFF6F00),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildMenuCard(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  iconColor: const Color(0xFF607D8B),
                  isFullWidth: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Settings coming soon!"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF607D8B),
                      ),
                    );
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

  // ===============================
  // BELOW THIS IS 100% YOUR UI
  // ===============================

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
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5252)),
        tooltip: 'Logout',
      ),
    );
  }

  Widget _buildConnectionStatus(BlePipelineService bleService) {
  return StreamBuilder<BluetoothConnectionState>(
    stream: bleService.connectionStream,
    builder: (context, snapshot) {
      final state = snapshot.data;

      final isConnected =
          bleService.device != null &&
          state == BluetoothConnectionState.connected;

      final statusColor =
          isConnected ? Colors.green : Colors.orange;

      final statusBgColor = isConnected
          ? const Color(0xFFE8F5E9)
          : const Color(0xFFFFF3E0);

      final statusText =
          isConnected ? 'Device Connected' : 'Not Connected';

      final statusIcon = isConnected
          ? Icons.bluetooth_connected_rounded
          : Icons.bluetooth_disabled_rounded;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BLEDeviceScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: statusColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon,
                    color: statusColor, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    statusText,
                    style: GoogleFonts.inter(
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
    },
  );
}

  Widget _buildHeroBanner() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF1565C0),
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
                Color(0xFF64B5F6),
              ],
              stops: [
                0.0,
                0.3 + (_shimmerAnimation.value * 0.1),
                0.6 + (_shimmerAnimation.value * 0.1),
                1.0,
              ],
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
              BoxShadow(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasthaartha',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bridging communication gaps with smart gestures.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFFE3F2FD),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
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
              style: GoogleFonts.inter(
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
    required Color iconColor,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    final isPressed = _pressedCard == title;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedCard = title),
      onTapUp: (_) {
        setState(() => _pressedCard = '');
        onTap();
      },
      onTapCancel: () => setState(() => _pressedCard = ''),
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: isFullWidth ? 90 : 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: iconColor.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isFullWidth
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.black.withValues(alpha: 0.3),
                      size: 18,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
