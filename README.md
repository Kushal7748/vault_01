# vault_01

## Notes for Windows development with the Rust plugin

If you see "Failed to load dynamic library 'rust_lib_vault_01.dll'" at runtime, you can either:

- Run `cargo build` in the `rust` folder and then copy the resulting DLL to the Windows runner directory:

```powershell
cargo build
.Scripts\copy_rust_dll.ps1
```

- Or run the helper script directly from the repo root after building the Rust crate:

```powershell
.Scripts\copy_rust_dll.ps1
```

If you'd like, I can try to diagnose and fix the Windows build error that prevents CMake/MSBuild from building the plugin automatically (often caused by antivirus/file locks or an environment issue).

Workaround: build the Rust crate and use the prebuilt DLL
- Run the helper script to build the Rust crate and copy the DLL into the Windows runner folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .Scripts\copy_rust_dll.ps1
```

- Or use the bundled script that builds, copies, kills any running exe and runs Flutter:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .Scripts\flutter_run_windows.ps1
```

- Alternatively you can set the env var and run Flutter directly in `cmd.exe`:

```powershell
cmd /C "set CARGOKIT_USE_PREBUILT=1 && flutter run -d windows"
```

Notes: The CMake now prefers a prebuilt DLL when present, so the above helper scripts make `flutter run` succeed without special MSBuild fixes.

If you want I can also try diagnosing the MSBuild/cargokit failure further (check antivirus, reproduce in an elevated shell, or adjust the CMake/Cargokit copy behavior).
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Overview

`vault_01` is a Flutter application that uses a Rust backend library via
`flutter_rust_bridge` (FRB). Rust implements secure storage and vault-like
operations (database initialization and storing memory entries). The repo
contains helper tooling (`rust_builder` / `cargokit`) to build and package the
native Rust artifacts for each platform, plus auto-generated FRB bindings and
small Dart wrapper APIs the Flutter UI calls.

---

## flutter_rust_bridge (FRB) workflow

This section describes how FRB is used in this project, what files it
generates, and how to regenerate bindings when the Rust API changes.

- Key files produced by FRB:
	- `rust/src/frb_generated.rs` — Rust-side generated glue that registers
		handlers and FFI symbols.
	- `lib/src/frb_generated/frb_generated.dart` (and `.io.dart` / `.web.dart`) —
		Dart bindings and wire classes used by the Dart runtime.
	- `lib/src/frb_generated/api/simple.dart` — thin public wrapper functions
		(e.g., `initializeVault`, `saveMemory`) that the Flutter UI should call.

### When to regenerate bindings

Regenerate FRB bindings whenever you change the Rust API signatures (new
functions, different argument types, etc.). The typical workflow is:

1. Update your Rust code in `rust/src/` (add functions or change signatures).
2. Run the FRB codegen tool (project-specific command may exist). Conceptual
	 example:

```bash
# from repo root — replace with your project's generator command
flutter_rust_bridge_codegen --config flutter_rust_bridge.yaml
```

3. The codegen will update `rust/src/frb_generated.rs` and the Dart files
	 under `lib/src/frb_generated/`.
4. Run `flutter pub get` and `flutter analyze` to ensure the Dart code compiles.

> Note: The exact codegen command may vary depending on how you installed the
> FRB codegen tool. If a script exists in `tool/` or in `rust_builder/`, prefer
> using that script so options and paths are correct.

### How the runtime call flow works

1. The Flutter UI calls a wrapper like `initializeVault(dbPath, encryptionKey)`.
2. The wrapper constructs a FRB task (serializes arguments) and asks the FRB
	 runtime to invoke the native symbol.
3. The FRB runtime looks up the native symbol in the loaded native library
	 (via `DynamicLibrary.open(...)` or the `ExternalLibrary` helper) and calls it.
4. The Rust code deserializes arguments, runs the requested logic, and returns
	 results which FRB deserializes back into Dart.

---

## Packaging & macOS integration (reproduceable steps)

The Rust native artifact (on macOS) must be available to the app at runtime.
This repo uses a CocoaPods-based flow for macOS to build and embed the Rust
library automatically. Additionally, a development-time fallback loads the
local cargo-built `.dylib` for fast iteration.

### Preconditions

- macOS development machine with Xcode and CocoaPods installed.
- Rust toolchain installed (`rustup`, `cargo`).
- Flutter SDK installed.

### Steps to reproduce packaging and run macOS app

1. From the project root, fetch Dart dependencies and clean previous builds:

```bash
flutter clean
flutter pub get
```

2. Install CocoaPods for the macOS workspace and run pod install:

```bash
cd macos
pod install
cd ..
```

The `macos/Podfile` contains the line:

```ruby
pod 'rust_lib_vault_01', :path => '../rust_builder/macos'
```

This tells CocoaPods to use the `rust_builder/macos/rust_lib_vault_01.podspec`.
That podspec defines a `script_phase` which invokes the `cargokit` build
script to compile the Rust crate and produce a `.framework` or static
artifact.

3. Build and run the macOS app with Flutter:

```bash
flutter run -d macos
```

What happens:

- CocoaPods (via Xcode build) runs the podspec script which calls `cargokit`.
- `cargokit` compiles the Rust crate for macOS and produces `rust_lib_vault_01.framework`
	(or a static library). The build script will place the output where the pod
	expects it and the app bundle will include it under `Contents/Frameworks`.
- FRB's runtime will `dlopen` that framework and calls to Rust succeed.

#### Quick local dev fallback (fast iteration)

During development you can build the Rust crate directly and run the app
without going through CocoaPods every time. Build the debug dylib:

```bash
cargo build --manifest-path=rust/Cargo.toml
# this produces: rust/target/debug/librust_lib_vault_01.dylib
```

`lib/main.dart` includes a dev-time check that, when running on macOS, looks
for this dylib and loads it via `ExternalLibrary.open(...)` so you can iterate
quickly with `flutter run -d macos`.

### Verifying the embedded framework in Xcode (optional but recommended)

1. Open the macOS workspace in Xcode:

```bash
open macos/Runner.xcworkspace
```

2. Build the `Runner` scheme for `Debug` and inspect the produced app bundle
	 in `Build/Products/Debug/` to confirm `Contents/Frameworks/rust_lib_vault_01.framework`
	 exists.

3. If the framework is not present, check Xcode build logs for the `Build Rust Library`
	 script phase; it should have run and produced the artifact.

### Silencing pod script warnings

You may see warnings such as:

```
Run script build phase 'Build Rust Library' will be run during every build because it does not specify any outputs.
```

To silence this, either:
- Add appropriate `:output_files` to the `s.script_phase` in the podspec, or
- In Xcode, open the script phase and uncheck "Based on dependency analysis".

---

## Troubleshooting checklist

- If `dlopen` errors occur at runtime on macOS, ensure either:
	- The CocoaPods build produced `rust_lib_vault_01.framework` and it is present
		in the app bundle at `Contents/Frameworks/`, or
	- You built the local debug dylib (`cargo build`) and `main.dart`'s dev fallback
		was able to locate it.
- If `pod install` fails, ensure CocoaPods is installed and you ran `flutter pub get`
	before invoking `pod install`.
- If Android Gradle fails with SDK not found, set `sdk.dir` in `android/local.properties`
	to your Android SDK path or install the SDK.

---

If you'd like, I can add a separate `DEVELOPER_SETUP.md` with checklist items,
screenshots, and exact commands for macOS, iOS, and Android developers. I can
also add small helper scripts under `tool/` to run `cargo build`, regenerate
FRB bindings, and run `pod install` automatically.
