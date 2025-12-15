# Copies built Rust DLL(s) to the Windows runner Debug folder for local development.
# Usage: from repo root run: .\scripts\copy_rust_dll.ps1 [-Configuration Debug]
param(
    [string]$Configuration = "Debug"
)
$root = Split-Path -Path $PSScriptRoot -Parent
$src = Join-Path $root ("rust\target\{0}\rust_lib_vault_01.dll" -f $Configuration.ToLower())
$destDir = Join-Path $root ("build\windows\x64\runner\{0}" -f $Configuration)
if (-not (Test-Path $src)) {
    Write-Error "Source DLL not found: $src. Run `cargo build` first (or change configuration)."
    exit 1
}
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}
Copy-Item -Path $src -Destination (Join-Path $destDir "rust_lib_vault_01.dll") -Force
Write-Output "Copied $src -> $destDir"