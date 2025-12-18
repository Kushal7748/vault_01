import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Configure Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  // Trigger the Sign-In Flow
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // This opens the Native Dialog on Android or Browser on Windows
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      if (kDebugMode) {
        print("Google Sign-In Error: $error");
      }
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() => _googleSignIn.disconnect();
}
