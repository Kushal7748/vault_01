import 'dart:ffi'; // Core FFI library
import 'dart:io'; // For platform detection and finding the library
import 'package:ffi/ffi.dart'; // For managing native memory (Pointer<Utf8>)

// --- 1. Load the Native Library ---

// Define the name of your compiled Rust library (e.g., libvault_01.a)
const String _libName = 'vault_01';

/// Locates and loads the compiled Rust library based on the current platform.
final DynamicLibrary _vaultLib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    // macOS/iOS use a dynamic library name pattern
    // The lib name in CargoKit/CocoaPods context might vary,
    // but typically links a static lib or a framework.
    // For macOS testing, you might use: DynamicLibrary.open('$_libName.dylib');
    // For a CargoKit setup, it's often linked directly, so `DynamicLibrary.process()`
    // or a specific path might be needed. We'll use the platform standard name first.
    if (Platform.isMacOS) {
      return DynamicLibrary.open('$_libName.dylib');
    }
    // For actual iOS, the library is statically linked into the executable.
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  // Other platforms would require their own logic
  throw UnsupportedError('Platform not supported.');
}();

// --- 2. FFI Function Definitions (Rust Signatures) ---

// Define the signature of the Rust function (how Rust sees it)
typedef InitializeVaultRust =
    Int32 Function(Pointer<Utf8> dbPath, Pointer<Utf8> key);

// Define the signature of the Dart function (how Dart sees it)
typedef InitializeVaultDart =
    int Function(Pointer<Utf8> dbPath, Pointer<Utf8> key);

// Define the signature for table creation
typedef CreateTableRust = Int32 Function();
typedef CreateTableDart = int Function();

// --- 3. Rust Function Bindings ---

// Look up the Rust function and cast it to the Dart signature
final initializeVault = _vaultLib
    .lookupFunction<InitializeVaultRust, InitializeVaultDart>(
      'initialize_vault',
    );

final vaultDbCreateTable = _vaultLib
    .lookupFunction<CreateTableRust, CreateTableDart>('vault_db_create_table');

// --- 4. Dart Wrapper Functions (Safe and Convenient) ---

class VaultDb {
  /// Calls the Rust FFI to initialize and open the encrypted database.
  static bool initialize({
    required String dbFilePath,
    required String encryptionKey,
  }) {
    // Convert Dart Strings to native C-style strings (Pointer<Utf8>)
    final dbPathPointer = dbFilePath.toNativeUtf8();
    final keyPointer = encryptionKey.toNativeUtf8();

    try {
      // Call the FFI function
      final result = initializeVault(dbPathPointer, keyPointer);

      // Check the error code returned from Rust (0 is success)
      if (result == 0) {
        print('✅ Rust database initialized successfully.');
        return true;
      } else {
        print('❌ Database initialization failed with error code: $result');
        return false;
      }
    } finally {
      // **CRITICAL**: Free the native memory allocated by toNativeUtf8()
      malloc.free(dbPathPointer);
      malloc.free(keyPointer);
    }
  }

  /// Calls the Rust FFI to run the initial table creation query.
  static bool createInitialTable() {
    final result = vaultDbCreateTable();

    if (result == 0) {
      print('✅ Rust executed initial table creation.');
      return true;
    } else {
      print('❌ Table creation failed with error code: $result');
      return false;
    }
  }
}
