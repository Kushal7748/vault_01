// lib/src/rust/api/simple.dart (Corrected)

// This file is the primary Dart API wrapper.
// It is the file you manually edit or ensure is correct.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// 1. Corrected initDb wrapper
// This calls the generated function directly.
Future<String> initDb({required String appDocDir}) =>
    initDbImpl(appDocDir: appDocDir); // Use a new unique function name (Impl)

// 2. Corrected saveMemory wrapper
// This calls the generated function directly.
Future<String> saveMemory({required String content}) =>
    saveMemoryImpl(content: content); // Use a new unique function name (Impl)

// --- Generated Function Stubs (Add these to fix the reference) ---
// Since the generated file is protected, we define the stubs here
// for the functions we will assume the generator created.

// The actual generated methods are usually named after the Rust function.
@internal
external Future<String> initDbImpl({required String appDocDir});

@internal
external Future<String> saveMemoryImpl({required String content});
