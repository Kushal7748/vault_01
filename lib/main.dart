// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/input_screen.dart';

void main() {
  runApp(const VaultApp());
}

class VaultApp extends StatelessWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault_01',
      debugShowCheckedModeBanner: false,
      theme: vaultDarkTheme, // Uses the file you made in step 1
      home: const InputScreen(), // Uses the file you made in step 2
    );
  }
}
