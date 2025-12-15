import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// Backend Imports
import 'src/frb_generated/frb_generated.dart';
import 'src/frb_generated/api/simple.dart';

// Frontend UI Imports
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Rust Backend
  await VaultRust.init(); 

  // 2. Initialize Database
  await setupDatabase();

  // 3. Run the App (Wrapped in ProviderScope for Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault 01',
      debugShowCheckedModeBanner: false,
      // Use the Friend's Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Load the Friend's Login Screen
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------
// BACKEND UTILITY FUNCTIONS (Kept from your work)
// ---------------------------------------------------------

// Initialize database
Future<void> setupDatabase() async {
  try {
    // 1. Get the correct cross-platform database path
    final dbPath = await getDatabasePath();
    print('📁 Database path: $dbPath');
    
    // 2. Ensure directory exists
    final file = File(dbPath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      print('✅ Created directory: ${dir.path}');
    }
    
    // 3. Call the Rust function with the path and key
    final result = initializeVault(
      dbPath: dbPath,
      encryptionKey: 'your-secure-key-here',
    );
    print("✅ Initialization and Table Creation SUCCESSFUL: $result");
  } catch (e) {
    print('Database setup failed: $e');
    // We catch the error but don't stop the app, so the UI still loads
  }
}

// Helper to determine the database file path
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory(); 
  return '${dir.path}/vault.db';
}