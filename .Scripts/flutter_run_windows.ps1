# Build Rust crate, copy DLL, kill any running exe, and run `flutter run -d windows` using the prebuilt DLL.
# Usage: PowerShell (ExecutionPolicy Bypass if needed)
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\.Scripts\flutter_run_windows.ps1

$repoRoot = Resolve-Path "." | Select-Object -ExpandProperty Path
$rustDir = Join-Path $repoRoot "rust"
$debugDll = Join-Path $rustDir "target\debug\rust_lib_vault_01.dll"
$destDll = Join-Path $repoRoot "build\windows\x64\runner\Debug\rust_lib_vault_01.dll"

Write-Output "Building Rust crate..."
Push-Location $rustDir
cargo build
Pop-Location

if (Test-Path $debugDll) {
  Write-Output "Copying $debugDll -> $destDll"
  Copy-Item -Force $debugDll $destDll
} else {
  Write-Warning "Prebuilt DLL not found at $debugDll. Continuing - CMake will try to build via cargokit."
}

# Kill running app to avoid LNK1168
$process = Get-Process -Name vault_01 -ErrorAction SilentlyContinue
if ($process) {
  Write-Output "Killing running vault_01.exe (PID: $($process.Id))"
  Stop-Process -Id $process.Id -Force
}

# Set env var for the current process and run flutter
$env:CARGOKIT_USE_PREBUILT = '1'
Write-Output "Running: flutter run -d windows (with CARGOKIT_USE_PREBUILT=1)"
flutter run -d windows

# Clear env var
Remove-Item Env:CARGOKIT_USE_PREBUILT -ErrorAction SilentlyContinue

Write-Output "Done."