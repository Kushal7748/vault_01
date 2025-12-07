// lib/main.dart (Final complete version)

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; 

// FRB Imports
import 'package:vault_01/src/rust/frb_generated.dart'; 
import 'package:vault_01/src/rust/api/simple.dart'; 

// --- Helper Functions ---
Future<String> getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbPath = path.join(directory.path, 'vault.db'); 
  return dbPath;
}

// --- Main Initialization Logic ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  final dbFilePath = await getDatabasePath();
  const String _encryptionKey = 'MyStrongSQLCipherKey12345!'; 
  
  print("--- Starting Vault Initialization Test (FRB) ---");
  print("Target DB File Path: $dbFilePath");
  
  try {
    // Calling the function with the path, using the generated parameter name 'appDocDir'.
    final dbStatus = await initDb(appDocDir: dbFilePath); 
    
    print("DATABASE STATUS (Success String): $dbStatus");
    print("✅ Initialization and Table Creation SUCCESSFUL.");

  } catch (e) {
    print("❌ DATABASE STATUS: Initialization FAILED.");
    print("Rust Error: $e");
  }
  print("--- Attempting to run Flutter UI ---");
  runApp(const MyApp());
}

// --- Application Structure (Ensure this class is present) ---

// lib/main.dart (or wherever your MyApp widget is defined)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. MaterialApp sets up the core theme
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vault_01',
      // Using dark theme, which often results in a black background
      theme: ThemeData.dark(useMaterial3: true), 
      
      // 2. FIX: Use Scaffold to guarantee visual structure and background color
      home: Scaffold(
        // Set an explicit, non-black background color for testing
        backgroundColor: Colors.indigo[900], 
        
        appBar: AppBar(
          title: const Text('Vault 01 - FFI Success!'),
          // Optional: Set a contrasting color for the app bar
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