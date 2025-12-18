import 'package:flutter_test/flutter_test.dart';
import 'package:vault_01/main.dart';
import 'package:vault_01/src/frb_generated/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Avoid loading the native Rust DLL during tests; initialize mock if needed
  setUpAll(() async {
    try {
      await VaultRust.init();
    } catch (_) {
      // If real init fails (missing DLL), use a mock API so tests won't crash
      VaultRust.initMock(api: _MockVaultApi());
    }
  });

  testWidgets('App shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const VaultApp());
    // The Login screen displays 'Vault_01' text
    expect(find.textContaining('Vault_01'), findsOneWidget);
  });
}

class _MockVaultApi implements VaultRustApi {
  @override
  String crateApiSimpleInitializeVault(
      {required String dbPath, required String encryptionKey}) {
    return 'Hello, Tom!';
  }

  @override
  // Return a dummy int value for saveMemory (compatible with PlatformInt64 on Dart side)
  int crateApiSimpleSaveMemory({required String content}) {
    return 1;
  }
}
