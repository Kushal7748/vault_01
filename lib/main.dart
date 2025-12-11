// lib/main.dart (Using RELATIVE PATHS as a fix)

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; 
import 'dart:io' show Platform, File, Directory;

// FRB Imports: USING RELATIVE PATHS (Assuming main.dart is in lib/)
import 'package:vault_01/src/frb_generated/frb_generated.dart';
import 'package:vault_01/src/frb_generated/api/simple.dart' as simple;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
 

// --- Helper Functions ---
Future<String> getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbPath = path.join(directory.path, 'vault.db'); 
  return dbPath;
}

// --- Main Initialization Logic ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to load the Rust dynamic library directly from the local cargo build
  // output when running on macOS (useful for `flutter run` debug sessions).
  ExternalLibrary? extLib;
  if (Platform.isMacOS) {
    final possible = path.join(Directory.current.path, 'rust', 'target', 'debug', 'librust_lib_vault_01.dylib');
    final f = File(possible);
    if (f.existsSync()) {
      extLib = ExternalLibrary.open(possible);
      print('Using local Rust dylib at: $possible');
    }
  }

  // Initialize FRB; pass `externalLibrary` when available to avoid the
  // framework lookup issue on macOS during local debug builds.
  await VaultRust.init(externalLibrary: extLib);

  final dbFilePath = await getDatabasePath();
  const String _encryptionKey = 'MyStrongSQLCipherKey12345!'; 
  
  print("--- Starting Vault Initialization Test (FRB) ---");
  
  try {
   // lib/main.dart
await simple.initializeVault(
  dbPath: dbFilePath,
  encryptionKey: _encryptionKey,
);
    print("✅ Initialization and Table Creation SUCCESSFUL.");

  } catch (e) {
    print("❌ DATABASE STATUS: Initialization FAILED.");
    print("Rust Error: $e");
  }
  print("--- Attempting to run Flutter UI ---");
  runApp(const MyApp());
}

// ... MyApp Class
// ... MyApp Class (unchanged)
// --- Application Structure ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vault_01',
      theme: ThemeData.dark(useMaterial3: true), 
      home: Scaffold(
        backgroundColor: Colors.indigo[900], 
        appBar: AppBar(
          title: const Text('Vault 01 - FFI Success!'),
          backgroundColor: Colors.deepPurple, 
        ),
        body: const Center(
          child: Text(
            'FFI Initialization Confirmed.',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}