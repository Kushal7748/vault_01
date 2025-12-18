import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/vault_service.dart';
import '../../data/secret_model.dart'; // Needed for the type

class AddSecretDialog extends HookConsumerWidget {
  // Optional: If provided, we are in "Edit Mode"
  final SecretModel? secretToEdit;

  const AddSecretDialog({super.key, this.secretToEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Initialize Controllers (Pre-fill if editing)
    final titleController = useTextEditingController(text: secretToEdit?.title);
    final usernameController =
        useTextEditingController(text: secretToEdit?.username);
    final passwordController =
        useTextEditingController(text: secretToEdit?.value);

    final isPasswordObscured = useState(true);

    final isEditing = secretToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Secret' : 'Add New Secret'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: !isEditing, // Only autofocus on new adds
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username / Email',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: isPasswordObscured.value,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(isPasswordObscured.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    isPasswordObscured.value = !isPasswordObscured.value;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (titleController.text.isEmpty) return;

            if (isEditing) {
              // --- UPDATE EXISTING ---
              final updatedSecret = secretToEdit!.copyWith(
                title: titleController.text,
                value: passwordController.text,
                username: usernameController.text.isEmpty
                    ? ''
                    : usernameController.text,
              );

              ref.read(vaultProvider.notifier).editSecret(
                    updatedSecret.id,
                    updatedSecret.title,
                    updatedSecret.username,
                    updatedSecret.value,
                  );
            } else {
              // --- ADD NEW ---
              ref.read(vaultProvider.notifier).addSecret(
                    titleController.text,
                    usernameController.text.isEmpty
                        ? ''
                        : usernameController.text,
                    passwordController.text,
                  );
            }

            Navigator.of(context).pop();
          },
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
