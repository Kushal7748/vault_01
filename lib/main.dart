import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vault_01/src/rust/api/simple.dart';
import 'package:vault_01/src/rust/frb_generated.dart';

void main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Vault_01 Secure Console')),
        body: const VaultControl(),
      ),
    );
  }
}

class VaultControl extends StatefulWidget {
  const VaultControl({super.key});

  @override
  State<VaultControl> createState() => _VaultControlState();
}

class _VaultControlState extends State<VaultControl> {
  String _status = "System Idle";
  List<Memory> _memories = []; // Local list

  Future<void> _initVault() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = '${docsDir.path}/vault.db';
      final result = await initDatabase(path: dbPath, key: "dev_key_123");
      setState(() => _status = "Vault Unlocked.");
      _refreshMemories(); // Load data immediately
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  Future<void> _writeMemory() async {
    try {
      await insertMemory(content: "Log entry: ${DateTime.now().toString()}");
      await _refreshMemories(); // Refresh list after writing
    } catch (e) {
      setState(() => _status = "Write Error: $e");
    }
  }

  Future<void> _refreshMemories() async {
    try {
      // THIS is the line you were missing!
      final data = await readMemories();
      setState(() {
        _memories = data;
        _status = "Synced: ${_memories.length} memories secure.";
      });
    } catch (e) {
      setState(() => _status = "Read Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: Text(_status, style: const TextStyle(fontFamily: 'Courier', fontSize: 12)),
          ),
          const SizedBox(height: 20),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _initVault,
                  icon: const Icon(Icons.lock_open),
                  label: const Text("INIT"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _writeMemory,
                  icon: const Icon(Icons.save),
                  label: const Text("WRITE"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
          
          const Divider(height: 30, thickness: 2),
          const Text("ENCRYPTED STREAM", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 10),

          // The Memory List
          Expanded(
            child: _memories.isEmpty 
              ? const Center(child: Text("Vault is empty.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _memories.length,
                  itemBuilder: (context, index) {
                    final mem = _memories[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.shield, color: Colors.blueGrey),
                        title: Text(mem.content),
                        subtitle: Text(mem.createdAt, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}