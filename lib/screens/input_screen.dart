import 'package:flutter/material.dart';
// 1. Import the Rust API
import 'package:vault_01/src/rust/api/simple.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Controller to handle the text input
  final TextEditingController _controller = TextEditingController();

  // Variable to show feedback from Rust
  String _statusMessage = "";

  Future<void> _handleSave() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    // FIX: We call 'saveMemory' instead of 'greet'
    // This matches the Rust function we just wrote.
    final result = await saveMemory(content: text);

    setState(() {
      _statusMessage = result;
    });

    // Clear input if successful
    if (!result.contains("Error")) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vault_01")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input Field
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Secret Memory',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _handleSave,
              child: const Text("Secure Memory"),
            ),

            const SizedBox(height: 20),

            // Feedback Text
            if (_statusMessage.isNotEmpty)
              Text(
                "RUST SAYS: $_statusMessage",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
