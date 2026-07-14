# ============================================================
# Rose School 2026 - Build Release + ZIP + Inno Setup Installer
# ------------------------------------------------------------
# Run in PowerShell:
#   cd C:\Users\khaledction\Desktop\new-rose
#   powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
#
# Options:
#   -SkipClean
#   -SkipInstaller
# ============================================================

param(
  [switch]$SkipClean,
  [switch]$SkipInstaller
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$msg) {
  Write-Host ""
  Write-Host "==> $msg" -ForegroundColor Cyan
}

function Assert-Command([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Command not found: $name"
  }
}

function Ensure-VCRedist([string]$TargetPath) {
  $dir = Split-Path -Parent $TargetPath
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }

  if (Test-Path $TargetPath) {
    $len = (Get-Item $TargetPath).Length
    if ($len -gt 1000000) {
      Write-Host "VC++ redistributable already present: $TargetPath" -ForegroundColor Yellow
      return
    }
  }

  $url = 'https://aka.ms/vs/17/release/vc_redist.x64.exe'
  Write-Host "Downloading VC++ Redistributable x64..." -ForegroundColor Yellow
  Write-Host $url
  try {
    Invoke-WebRequest -Uri $url -OutFile $TargetPath -UseBasicParsing
  } catch {
    # Fallback for older PowerShell
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $TargetPath)
  }

  if (-not (Test-Path $TargetPath) -or ((Get-Item $TargetPath).Length -lt 1000000)) {
    throw "Failed to download vc_redist.x64.exe"
  }
  Write-Host "Saved: $TargetPath" -ForegroundColor Green
}

# Resolve project root (parent of scripts/)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "Rose School 2026 - Release Builder" -ForegroundColor Green
Write-Host "Project: $ProjectRoot"

Assert-Command flutter

$ReleaseDirCandidates = @(
  (Join-Path $ProjectRoot 'build\windows\x64\runner\Release'),
  (Join-Path $ProjectRoot 'build\windows\runner\Release')
)
$DistDir = Join-Path $ProjectRoot 'dist'
$InstallerDir = Join-Path $ProjectRoot 'installer'
$RedistDir = Join-Path $InstallerDir 'redist'
$VCRedistPath = Join-Path $RedistDir 'vc_redist.x64.exe'
$IssFile = Join-Path $InstallerDir 'RoseSchool.iss'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmm'
$ZipName = "RoseSchool2026_Portable_$Stamp.zip"
$ZipPath = Join-Path $DistDir $ZipName
$SetupPath = Join-Path $DistDir 'RoseSchoolSetup.exe'

if (-not (Test-Path $DistDir)) {
  New-Item -ItemType Directory -Path $DistDir | Out-Null
}

# Always ensure VC redist is available for installer packaging / portable bundle tip
Write-Step "Ensure Microsoft VC++ Redistributable (x64)"
Ensure-VCRedist -TargetPath $VCRedistPath

if (-not $SkipClean) {
  Write-Step "flutter clean"
  flutter clean
}

Write-Step "flutter pub get"
flutter pub get

Write-Step "flutter build windows --release"
flutter build windows --release

$ReleaseDir = $null
foreach ($candidate in $ReleaseDirCandidates) {
  if (Test-Path (Join-Path $candidate 'rose_school.exe')) {
    $ReleaseDir = $candidate
    break
  }
}

if (-not $ReleaseDir) {
  throw "Release folder not found. Expected rose_school.exe under build\\windows\\...\\Release"
}

Write-Host "Release folder: $ReleaseDir" -ForegroundColor Yellow

# Copy VC redist next to portable package for machines that run ZIP without Setup
Write-Step "Attach VC++ runtime helper into portable package folder"
Copy-Item -Force $VCRedistPath (Join-Path $ReleaseDir 'vc_redist.x64.exe')
$ReadmePortable = @"
Rose School 2026 - Portable

1) If rose_school.exe shows MSVCP140.dll / VCRUNTIME140_1.dll missing:
   run: vc_redist.x64.exe  (Install), then reboot, then run rose_school.exe

2) Always keep this whole folder together (do not move exe alone).
"@
Set-Content -Path (Join-Path $ReleaseDir 'README_PORTABLE.txt') -Value $ReadmePortable -Encoding UTF8

# Portable ZIP
Write-Step "Creating portable ZIP"
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
Compress-Archive -Path (Join-Path $ReleaseDir '*') -DestinationPath $ZipPath -Force
Write-Host "ZIP: $ZipPath" -ForegroundColor Green

# Inno Setup installer (optional)
if (-not $SkipInstaller) {
  Write-Step "Building Inno Setup installer"

  if (-not (Test-Path $IssFile)) {
    throw "Missing installer script: $IssFile"
  }
  if (-not (Test-Path $VCRedistPath)) {
    throw "Missing VC redist for installer: $VCRedistPath"
  }

  $isccCandidates = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe"
  )
  $iscc = $isccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

  if (-not $iscc) {
    Write-Host "ISCC.exe not found. Install Inno Setup 6, then re-run without -SkipInstaller." -ForegroundColor Yellow
    Write-Host "Download: https://jrsoftware.org/isinfo.php" -ForegroundColor Yellow
  } else {
    Write-Host "Using: $iscc"
    & $iscc $IssFile
    if ($LASTEXITCODE -ne 0) {
      throw "Inno Setup compile failed with exit code $LASTEXITCODE"
    }

    if (-not (Test-Path $SetupPath)) {
      $found = Get-ChildItem $DistDir -Filter 'RoseSchoolSetup*.exe' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
      if ($found) {
        $SetupPath = $found.FullName
      }
    }

    if (Test-Path $SetupPath) {
      Write-Host "Installer: $SetupPath" -ForegroundColor Green
    } else {
      Write-Host "Installer compile finished, but exe not found in dist/. Check OutputDir in .iss" -ForegroundColor Yellow
    }
  }
}

Write-Host ""
Write-Host "================ DONE ================" -ForegroundColor Green
Write-Host "Portable ZIP : $ZipPath"
if (Test-Path $SetupPath) {
  Write-Host "Installer    : $SetupPath"
} else {
  Write-Host "Installer    : (not built)"
}
Write-Host "Release dir  : $ReleaseDir"
Write-Host "VC++ redist  : $VCRedistPath"
Write-Host ""
Write-Host "Distribute either:" -ForegroundColor Cyan
Write-Host "  1) RoseSchoolSetup.exe  (recommended - auto installs VC++ if needed)"
Write-Host "  2) Portable ZIP         (includes vc_redist.x64.exe helper)"
Write-Host "======================================"
