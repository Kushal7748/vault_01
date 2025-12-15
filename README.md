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
