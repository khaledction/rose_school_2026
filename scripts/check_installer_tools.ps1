# Quick diagnostics: why Installer may show (not built)
$ErrorActionPreference = 'Continue'

Write-Host "=== Rose School installer tools check ===" -ForegroundColor Cyan

$paths = @(
  "$env:ProgramFiles\Inno Setup 7\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
  "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe"
)

# Discover any Inno Setup* folder
foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
  if ($root -and (Test-Path $root)) {
    $paths += Get-ChildItem -Path $root -Directory -Filter 'Inno Setup *' -ErrorAction SilentlyContinue |
      ForEach-Object { Join-Path $_.FullName 'ISCC.exe' }
  }
}

$paths = $paths | Select-Object -Unique
$found = $false
$foundPath = $null
foreach ($p in $paths) {
  if (-not $p) { continue }
  $ok = Test-Path $p
  Write-Host ("ISCC: {0} => {1}" -f $p, $ok)
  if ($ok -and -not $found) {
    $found = $true
    $foundPath = $p
  }
}

if (-not $found) {
  Write-Host ""
  Write-Host "RESULT: Inno Setup is NOT installed (or ISCC.exe not found)." -ForegroundColor Red
  Write-Host "This is the usual reason for: Installer : (not built)" -ForegroundColor Yellow
  Write-Host "Download: https://jrsoftware.org/isinfo.php" -ForegroundColor Cyan
} else {
  Write-Host ""
  Write-Host "RESULT: Inno Setup compiler found." -ForegroundColor Green
  Write-Host "Using: $foundPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "Flutter:" -ForegroundColor Cyan
try { flutter --version } catch { Write-Host "flutter not found" -ForegroundColor Red }

Write-Host ""
Write-Host "Release folder candidates:" -ForegroundColor Cyan
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
@(
  (Join-Path $root 'build\windows\x64\runner\Release\rose_school.exe'),
  (Join-Path $root 'build\windows\runner\Release\rose_school.exe')
) | ForEach-Object {
  Write-Host ("{0} => {1}" -f $_, (Test-Path $_))
}

Write-Host ""
Write-Host "VC redist:" -ForegroundColor Cyan
$vc = Join-Path $root 'installer\redist\vc_redist.x64.exe'
Write-Host ("{0} => {1}" -f $vc, (Test-Path $vc))

if ($found) {
  Write-Host ""
  Write-Host "Next:" -ForegroundColor Cyan
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1 -SkipClean"
}