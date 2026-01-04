import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../screens/auth/login.dart';
import '../screens/dashboard/homedashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Offline behavior:
        // - If user previously signed in, Firebase returns cached currentUser even offline.
        // - If user is null, show Login (first sign-in needs internet).
        final user = snap.data ?? auth.currentUser;

        if (user == null) {
          return const LoginScreen();
        }

        // Prefer displayName if available, else email.
        final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email ?? "User");

        return HomeDashboard(userName: name);
      },
    );
  }
}