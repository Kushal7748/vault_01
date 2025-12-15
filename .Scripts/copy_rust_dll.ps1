# Build the rust crate and copy the DLL to the Flutter Windows runner Debug folder.
# Usage (PowerShell):
#   .Scripts\copy_rust_dll.ps1

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path "$root\.."
$repoRoot = $repo.Path
$rustDir = Join-Path $repoRoot "rust"
Write-Output "Building Rust crate in: $rustDir"
pushd $rustDir
cargo build
popd
$debugDll = Join-Path $rustDir "target\debug\rust_lib_vault_01.dll"
$dest = Join-Path $repoRoot "build\windows\x64\runner\Debug\rust_lib_vault_01.dll"
if (Test-Path $debugDll) {
  Write-Output "Copying $debugDll to $dest"
  Copy-Item -Force $debugDll $dest
  Write-Output "Done. You can now run: `powershell -NoProfile -Command \"$env:CARGOKIT_USE_PREBUILT=1; flutter run -d windows\"` to build using the prebuilt DLL."
} else {
  Write-Error "Prebuilt DLL not found: $debugDll"
  exit 1
}