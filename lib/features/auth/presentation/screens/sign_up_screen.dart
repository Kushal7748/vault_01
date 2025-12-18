import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final _userEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();

  // Logic: Handle "Create Account"
  void _handleCreateAccount() {
    // Simple Validation
    final input = _userEmailController.text.trim();
    final pass = _passwordController.text;

    if (input.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Determine if it looks like an email or username
    final isEmail = input.contains('@');
    final type = isEmail ? "Email" : "Username";

    // Show Success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account Created with $type: $input'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Go back to Login after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // Logic: Handle Google Sign Up
  Future<void> _handleGoogleSignUp() async {
    final user = await _authService.signInWithGoogle();

    if (user != null && mounted) {
      // Show Success with their Google Name
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account Created for ${user.displayName}!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to Home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // --- BOX 1: USERNAME OR EMAIL ---
            const Text("Username or Email",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _userEmailController,
                decoration: const InputDecoration(
                  hintText: 'john_doe OR john@example.com',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- BOX 2: PASSWORD (WITH EYE ICON) ---
            const Text("Password",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Toggles visibility
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: const Icon(Icons.lock_outline),
                  // THE EYE ICON LOGIC
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- BOX 3: CREATE BUTTON ---
            SizedBox(
              height: 55,
              child: FilledButton(
                onPressed: _handleCreateAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Create Account",
                    style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 30),

            // --- OR DIVIDER ---
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 30),

            // --- GOOGLE BUTTON (With Logo on Left) ---
            SizedBox(
              height: 55,
              child: OutlinedButton(
                onPressed: _handleGoogleSignUp,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GOOGLE LOGO IMAGE
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      height: 24,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.public, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Create using Google",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
