import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/vault/presentation/screens/vault_home_screen.dart';
import 'src/frb_generated/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt to initialize Rust bridge but tolerate failure (e.g., missing DLL on CI / dev machine)
  try {
    await VaultRust.init();
  } catch (e, st) {
    // Log and continue; the app can still run in mock mode or without native features
    // (Use `VaultRust.initMock` in tests to provide deterministic behavior)
    // ignore: avoid_print
    print('flutter_rust_bridge init failed (continuing): $e\n$st');
  }

  // RUN THE APP
  runApp(
    const ProviderScope(
      child: VaultApp(),
    ),
  );
}

class VaultApp extends StatelessWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault_01',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const VaultHomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
