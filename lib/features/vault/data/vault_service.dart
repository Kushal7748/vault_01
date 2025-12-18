import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'secret_model.dart';

// --- Providers ---

// 1. Storage Provider: Gives us the secure storage instance
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  // We must enable encryptedSharedPreferences for Android to be secure
  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  return FlutterSecureStorage(aOptions: getAndroidOptions());
});

// 2. Vault Provider: The StateNotifier that the UI watches
final vaultProvider =
    StateNotifierProvider<VaultNotifier, List<SecretModel>>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return VaultNotifier(storage);
});

// --- Notifier Logic ---

class VaultNotifier extends StateNotifier<List<SecretModel>> {
  final FlutterSecureStorage _storage;
  static const _storageKey = 'vault_data_01'; // The database key

  VaultNotifier(this._storage) : super([]) {
    // Attempt to load data as soon as this provider is initialized
    _loadSecrets();
  }

  // --- Persistence Helpers ---

  Future<void> _loadSecrets() async {
    try {
      final String? jsonString = await _storage.read(key: _storageKey);

      if (jsonString != null) {
        // Decode: String -> List<dynamic> -> List<SecretModel>
        final List<dynamic> jsonList = jsonDecode(jsonString);
        state = jsonList.map((e) => SecretModel.fromMap(e)).toList();
      }
    } catch (e) {
      // In a real app, you might want to log this error
      debugPrint("Error loading secrets: $e");
    }
  }

  Future<void> _saveSecrets(List<SecretModel> secrets) async {
    try {
      // Encode: List<SecretModel> -> List<Map> -> String
      final List<Map<String, dynamic>> maps =
          secrets.map((e) => e.toMap()).toList();
      final String jsonString = jsonEncode(maps);

      await _storage.write(key: _storageKey, value: jsonString);
    } catch (e) {
      debugPrint("Error saving secrets: $e");
    }
  }

  // --- Actions (CRUD) ---

  Future<void> addSecret(String title, String username, String value) async {
    final newSecret = SecretModel(
      id: const Uuid().v4(), // Generates a unique random ID
      title: title,
      username: username,
      value: value,
    );

    // Update state immediately
    state = [...state, newSecret];
    // Persist to storage
    await _saveSecrets(state);
  }

  Future<void> editSecret(
      String id, String title, String username, String value) async {
    state = [
      for (final secret in state)
        if (secret.id == id)
          secret.copyWith(title: title, username: username, value: value)
        else
          secret
    ];
    await _saveSecrets(state);
  }

  Future<void> deleteSecret(String id) async {
    state = state.where((secret) => secret.id != id).toList();
    await _saveSecrets(state);
  }
}
