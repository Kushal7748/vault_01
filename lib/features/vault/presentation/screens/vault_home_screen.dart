import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/providers/providers.dart';
import '../../data/secret_model.dart';

class VaultHomeScreen extends HookConsumerWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Access the Service
    final vaultService = ref.watch(vaultServiceProvider);

    // 2. Local State for the list of secrets
    final secrets = useState<List<Secret>>([]);
    final isLoading = useState<bool>(true);

    // 3. Function to load data
    Future<void> loadSecrets() async {
      isLoading.value = true;
      final result = await vaultService.getAllSecrets();
      result.when(
        success: (data) => secrets.value = List.from(data),
        failure: (msg, _) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg))),
      );
      isLoading.value = false;
    }

    // 4. Load data when screen opens
    useEffect(() {
      loadSecrets();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('My Secure Vault')),

      // THE LIST VIEW
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : secrets.value.isEmpty
              ? const Center(child: Text("No secrets yet. Tap + to add one!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: secrets.value.length,
                  itemBuilder: (context, index) {
                    final secret = secrets.value[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.lock, color: Colors.blue),
                        ),
                        title: Text(secret.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Hidden Value: ••••••••'),
                        onTap: () {
                          // Show the secret value on tap
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Value: ${secret.value}')),
                          );
                        },
                      ),
                    );
                  },
                ),

      // THE ADD BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Show the Add Dialog
          await showDialog(
            context: context,
            builder: (ctx) => _AddSecretDialog(
              onSave: (key, value) async {
                final result =
                    await vaultService.storeSecret(key: key, value: value);
                result.when(
                  success: (_) {
                    Navigator.pop(ctx); // Close dialog
                    loadSecrets(); // Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Secret Saved!')),
                    );
                  },
                  failure: (msg, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $msg'),
                          backgroundColor: Colors.red),
                    );
                  },
                );
              },
            ),
          );
        },
        label: const Text('Add Secret'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// --- Small Helper Widget for the Dialog ---
class _AddSecretDialog extends HookWidget {
  final Function(String key, String value) onSave;

  const _AddSecretDialog({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final keyCtrl = useTextEditingController();
    final valueCtrl = useTextEditingController();

    return AlertDialog(
      title: const Text('New Secret'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(labelText: 'Key (e.g. Gmail)')),
          const SizedBox(height: 16),
          TextField(
              controller: valueCtrl,
              decoration:
                  const InputDecoration(labelText: 'Value (e.g. password123)')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => onSave(keyCtrl.text, valueCtrl.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
