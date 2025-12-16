import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/vault_service.dart';
import '../widgets/add_secret_dialog.dart';

class VaultHomeScreen extends HookConsumerWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secrets = ref.watch(vaultListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        centerTitle: true,
      ),
      body: secrets.isEmpty
          ? Center(
              child: Text(
                'No secrets yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: secrets.length,
              itemBuilder: (context, index) {
                final secret = secrets[index];

                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        secret.title.isNotEmpty
                            ? secret.title[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      secret.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(secret.username ?? 'No username'),

                    // --- CHANGED: Popup Menu for Actions ---
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert), // The 3-dot icon
                      onSelected: (value) async {
                        switch (value) {
                          case 'copy':
                            await Clipboard.setData(
                              ClipboardData(text: secret.value),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password for ${secret.title} copied!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                            break;

                          case 'edit':
                            showDialog(
                              context: context,
                              builder: (context) => AddSecretDialog(
                                secretToEdit: secret,
                              ),
                            );
                            break;

                          case 'delete':
                            // Confirm before deleting
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Secret?'),
                                content: Text(
                                    'Are you sure you want to delete ${secret.title}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(vaultListProvider.notifier)
                                          .removeSecret(secret.id);
                                      Navigator.of(ctx).pop(); // Close Alert
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'copy',
                          child: ListTile(
                            leading: Icon(Icons.copy, size: 20),
                            title: Text('Copy Password'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, size: 20),
                            title: Text('Edit Details'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading:
                                Icon(Icons.delete, color: Colors.red, size: 20),
                            title: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    // ---------------------------------------
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddSecretDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
