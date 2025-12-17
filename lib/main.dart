import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// Backend Imports (generated bindings)
import 'package:vault_01/src/frb_generated/frb_generated.dart';
import 'package:vault_01/src/frb_generated/api/simple.dart';

// Frontend UI Imports
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rust bindings and database before app start
  try {
    await VaultRust.init();
  } catch (e) {
    // If Rust init fails, log and continue so the UI can still load for development
    // Consider surfacing this error to the user in production.
    debugPrint('Warning: VaultRust.init() failed: $e');
  }

  await setupDatabase();

  // Run the App (Wrapped in ProviderScope for Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault 01',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}

// Keep a simple home page available for quick testing or legacy flows
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter your secret note',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data saved successfully')),
                );
                _controller.clear();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Initialize database
Future<void> setupDatabase() async {
  try {
    // 1. Get the correct cross-platform database path
    final dbPath = await getDatabasePath();
    debugPrint('📁 Database path: $dbPath');

    // 2. Ensure directory exists
    final file = File(dbPath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      debugPrint('✅ Created directory: ${dir.path}');
    }

    // 3. Call the Rust function with the path and key
    final result = initializeVault(
      dbPath: dbPath,
      encryptionKey: 'your-secure-key-here',
    );
    debugPrint("✅ Initialization and Table Creation SUCCESSFUL: $result");
  } catch (e) {
    debugPrint('Database setup failed: $e');
    rethrow;
  }
}

// Save data
Future<void> saveData() async {
  try {
    saveMemory(content: 'My secret note');
    debugPrint('Data saved successfully');
  } catch (e) {
    debugPrint('Save failed: $e');
  }
}

// Helper to determine the database file path
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return '${dir.path}/vault.db';
}
