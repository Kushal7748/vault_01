import 'package:flutter/material.dart';
// 1. Import the Rust bridge generated code
// Note: If 'vault_01' is underlined red, check your pubspec.yaml name.
import 'package:vault_01/src/rust/frb_generated.dart';

// 2. Import your Input Screen
// Note: Ensure your input screen file is actually at this path.
import 'screens/input_screen.dart';

Future<void> main() async {
  // 3. Ensure Flutter bindings are ready (required for async main)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize the Rust Bridge
  await RustLib.init();

  // 5. Launch the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vault_01',
      // Applying the Dark Mode theme you built
      theme: ThemeData.dark(useMaterial3: true),
      // Set the home screen to your InputScreen
      home: const InputScreen(),
    );
  }
}
