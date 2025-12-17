import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vault_01/utils/result.dart';
import '../../features/vault/services/vault_service.dart';

// Provides the VaultService instance
final vaultServiceProvider = Provider<VaultService>((ref) {
  return VaultService();
});

// Provides the initialization state (returns Result so callers can inspect success/failure)
final initializationProvider = FutureProvider<Result<void>>((ref) async {
  final vaultService = ref.watch(vaultServiceProvider);
  return await vaultService.initialize();
});
