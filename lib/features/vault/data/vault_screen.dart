// Legacy compatibility shim: re-export current provider under the old name

import '../data/vault_service.dart' show vaultProvider;

/// Backwards compatible alias used by older imports
final vaultListProvider = vaultProvider;
