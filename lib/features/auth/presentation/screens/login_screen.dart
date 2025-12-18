import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../data/biometric_service.dart'; // Import Biometric Service
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final AuthService _authService = AuthService();
  // Initialize Biometric Service
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    // Optional: Auto-trigger biometrics on load
    // _handleBiometricLogin();
  }

  // --- BIOMETRIC LOGIC ---
  Future<void> _handleBiometricLogin() async {
    final isAvailable = await _biometricService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Biometrics not available on this device')),
        );
      }
      return;
    }

    final isAuthenticated = await _biometricService.authenticate();

    if (isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Identity Verified!'), backgroundColor: Colors.green),
      );
      // Navigate to Home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Google Login Logic (Existing)
  Future<void> _handleGoogleLogin() async {
    final user = await _authService.signInWithGoogle();
    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_rounded,
                  size: 80, color: Colors.blueGrey),
              const SizedBox(height: 16),
              const Text('Vault_01',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- LOGIN BUTTONS ROW ---
              Row(
                children: [
                  // Standard Login Button (Expanded)
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child:
                          const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // BIOMETRIC BUTTON (Square Icon Button)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint,
                          size: 28, color: Colors.blueGrey),
                      tooltip: "Login with Fingerprint",
                      onPressed: _handleBiometricLogin, // Triggers the scan
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),

              // Google Button
              OutlinedButton(
                onPressed: _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      height: 24,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.public, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text('Sign in with Google',
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Link
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen())),
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
