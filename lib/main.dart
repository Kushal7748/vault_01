import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // 1. Import path package
import 'package:vault_01/src/rust/frb_generated.dart';
import 'package:vault_01/src/rust/api/simple.dart'; // 2. Import our API
import 'screens/input_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize the Bridge
  await RustLib.init();

  // 4. Find the correct storage location
  final appDir = await getApplicationDocumentsDirectory();

  // 5. Tell Rust to create the database there
  // We pass the string path (e.g., "/data/user/0/com.vault/app_flutter")
  final dbStatus = await initDb(appDocDir: appDir.path);

  print("DATABASE STATUS: $dbStatus"); // Check your debug console for this!

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vault_01',
      theme: ThemeData.dark(useMaterial3: true),
      home: const InputScreen(),
    );
  }
}
