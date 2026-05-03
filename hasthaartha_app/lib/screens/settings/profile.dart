import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/screens/auth/login.dart';
import 'package:hasthaartha_app/screens/settings/edit_profile.dart';
import 'package:hasthaartha_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    setState(() {
      _userName = user?.displayName ?? 'Guest User';
      _userEmail = user?.email ?? 'No email available';
    });
  }

  void _handleLogout() async {
    final navigator = Navigator.of(context);
    await _authService.signOut();
    if (mounted) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0D47A1),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: const Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileAvatar(),
                const SizedBox(height: 24),
                _buildProfileInfoCard(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: Text(
          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1976D2),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        ],
      ),
      child: Column(
        children: [
          Text(
            _userName,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _userEmail,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.blueGrey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildGlassButton(
          title: 'Edit Profile',
          icon: Icons.edit_rounded,
          iconColor: const Color(0xFF1976D2),
          onTap: () async {
            final didUpdate = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            // If the user updated their profile, refresh this screen's data
            if (didUpdate == true) {
              _loadUserData();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildGlassButton(
          title: 'Logout',
          icon: Icons.logout_rounded,
          iconColor: const Color(0xFFFF5252),
          isLogout: true,
          onTap: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isLogout
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
