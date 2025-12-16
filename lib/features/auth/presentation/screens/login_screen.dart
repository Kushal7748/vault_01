import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../vault/presentation/screens/vault_home_screen.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Controllers for text input
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // 2. State for Password Visibility (True = Hidden by default)
    final isPasswordVisible = useState(false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon or Logo
              Icon(
                Icons.lock_person_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field with Eye Icon
              TextField(
                controller: passwordController,
                // If visible is TRUE, obscureText is FALSE
                obscureText: !isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: const Icon(Icons.key_outlined),
                  border: const OutlineInputBorder(),

                  // THE EYE ICON TOGGLE
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      // Toggle the state
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              FilledButton(
                onPressed: () {
                  // Navigate to Vault Home
                  // (Add your actual authentication logic here later)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const VaultHomeScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Unlock Vault'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
