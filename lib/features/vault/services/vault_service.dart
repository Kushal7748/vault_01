import 'dart:async';
import 'package:vault_01/utils/result.dart';
import '../data/secret_model.dart'; // Import the model

class VaultService {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  bool _initialized = false;

  // --- Temporary In-Memory Storage (Acts as our Database) ---
  final List<SecretModel> _mockDatabase = [];

  Future<Result<void>> initialize() async {
    if (_initialized) return const Success(null);
    try {
      // await RustLibVault01.init(); // Uncomment when Rust is ready
      _initialized = true;
      return const Success(null);
    } catch (e) {
      return Failure('Failed init: $e', e as Exception?);
    }
  }

  /// Get all secrets to show in the list
  Future<Result<List<SecretModel>>> getAllSecrets() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    return Success(_mockDatabase);
  }

  /// Store a new secret (uses title as `key` for legacy API compatibility)
  Future<Result<bool>> storeSecret(
      {required String key, required String value}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if a secret with the same title already exists
    final exists = _mockDatabase.any((s) => s.title == key);
    if (exists) {
      return const Failure("Key already exists");
    }

    _mockDatabase.add(SecretModel(
      id: DateTime.now().toIso8601String(),
      title: key,
      username: '',
      value: value,
    ));

    return const Success(true);
  }
}
