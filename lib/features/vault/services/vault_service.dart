import 'dart:async';
import 'package:vault_01/utils/result.dart';
import '../data/secret_model.dart'; // Import the model we just made

class VaultService {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  bool _initialized = false;

  // --- Temporary In-Memory Storage (Acts as our Database) ---
  final List<Secret> _mockDatabase = [];

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
  Future<Result<List<Secret>>> getAllSecrets() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    return Success(_mockDatabase);
  }

  /// Store a new secret
  Future<Result<bool>> storeSecret(
      {required String key, required String value}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if key already exists
    final exists = _mockDatabase.any((s) => s.key == key);
    if (exists) {
      return const Failure("Key already exists");
    }

    _mockDatabase
        .add(Secret(key: key, value: value, createdAt: DateTime.now()));

    return const Success(true);
  }
}
