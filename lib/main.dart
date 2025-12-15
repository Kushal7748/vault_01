import 'package:flutter/material.dart';
import 'package:vault_01/src/frb_generated/frb_generated.dart';
import 'package:vault_01/src/frb_generated/api/simple.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VaultRust.init();
  await setupDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Vault'),
    );
  }
}

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
    rethrow;
  }
}

// Save data
Future<void> saveData() async {
  try {
    saveMemory(content: 'My secret note');
    print('Data saved successfully');
  } catch (e) {
    print('Save failed: $e');
  }
}

// Helper to determine the database file path
Future<String> getDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory(); 
  return '${dir.path}/vault.db';
}