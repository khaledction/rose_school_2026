# Apply Rose School updates from rose_school_updates.zip into new-rose
# 1) Download/save rose_school_updates.zip to Downloads (or Desktop)
# 2) Run this script in PowerShell:
#    powershell -ExecutionPolicy Bypass -File .\APPLY_UPDATES.ps1

$ErrorActionPreference = 'Stop'
$project = 'C:\Users\khaledction\Desktop\new-rose'
$candidates = @(
  "$env:USERPROFILE\Downloads\rose_school_updates.zip",
  "$env:USERPROFILE\Desktop\rose_school_updates.zip",
  "$project\rose_school_updates.zip",
  ".\rose_school_updates.zip"
)

$zip = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $zip) {
  Write-Host "ERROR: rose_school_updates.zip not found." -ForegroundColor Red
  Write-Host "Put it in Downloads or Desktop, then re-run."
  exit 1
}
if (-not (Test-Path $project)) {
  Write-Host "ERROR: project not found: $project" -ForegroundColor Red
  exit 1
}

Write-Host "ZIP: $zip"
Write-Host "Project: $project"

$tmp = Join-Path $project 'tmp_updates'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $tmp -Force

$files = @(
  'school_shell_page.dart',
  'school_shell_sections.dart',
  'student_sorting_page.dart',
  'employees_page.dart',
  'dashboard_page.dart'
)

foreach ($f in $files) {
  $src = Join-Path $tmp $f
  $dst = Join-Path $project "lib\pages\$f"
  if (-not (Test-Path $src)) { throw "Missing in zip: $f" }
  Copy-Item $src $dst -Force
  Write-Host "Copied $f" -ForegroundColor Green
}

Write-Host "`nGit status:"
Set-Location $project
git status --short -- lib/pages

Write-Host "`nQuick checks (should find matches):"
Select-String -Path .\lib\pages\school_shell_page.dart -Pattern "data_center', '📁 مركز البيانات" | Select-Object -First 1
Select-String -Path .\lib\pages\school_shell_sections.dart -Pattern "💵 دفعة|مدير المدرسة|نطاق الإعفاء" | Select-Object -First 5
Select-String -Path .\lib\pages\student_sorting_page.dart -Pattern "حسب المعدل والدرجات" | Select-Object -First 1
Select-String -Path .\lib\pages\employees_page.dart -Pattern "تعليم اساسي حلقة 1|_departmentDropdown" | Select-Object -First 2

Write-Host "`nRun app:"
Write-Host "  flutter run -d windows"
