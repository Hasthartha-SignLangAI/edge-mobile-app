import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user (cached session works offline after first login)
  User? get currentUser => _auth.currentUser;

  // show display name safely
  String get displayNameOrEmail {
    final u = _auth.currentUser;
    final dn = u?.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    return u?.email ?? "User";
  }

  // check if there is an offline cached session
  bool get hasCachedSession => _auth.currentUser != null;

  // Sign Up (requires internet)
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // update display name (requires internet at sign-up time)
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In (requires internet if no cached session)
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('🔐 AUTH: Attempting sign in for: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ AUTH: Sign in successful for: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ AUTH ERROR: Code=${e.code}, Message=${e.message}');
      rethrow;
    } catch (e) {
      print('❌ AUTH UNEXPECTED ERROR: $e');
      throw Exception(e.toString());
    }
  }

  // Update User Profile (Name)
  Future<void> updateUserProfile(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload();
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      print('❌ AUTH ERROR (Update Profile): $e');
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate first
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);

        // Then update password
        await user.updatePassword(newPassword);
      } else {
        throw Exception("No user is currently signed in.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('The current password provided is incorrect.');
      }
      print('❌ AUTH ERROR (Change Password): ${e.code}');
      rethrow;
    } catch (e) {
      print('❌ AUTH UNEXPECTED ERROR: $e');
      throw Exception(e.toString());
    }
  }

  // Sign Out (after this, user cannot sign-in offline)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
