; ============================================================
; Rose School 2026 - Inno Setup Installer Script
; ------------------------------------------------------------
; المتطلبات:
; 1) Flutter build windows --release
; 2) Inno Setup 6+
; 3) Compile this script (or use scripts\build_release_installer.ps1)
; ============================================================

#define MyAppName "Rose School 2026"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Rose School"
#define MyAppURL "https://github.com/khaledction/rose_school_2026"
#define MyAppExeName "rose_school.exe"

; Source folder produced by: flutter build windows --release
; If your path differs, edit SourceDir below.
#define SourceDir "..\build\windows\x64\runner\Release"
#define OutputDir "..\dist"
#define AppIcon "..\windows\runner\resources\app_icon.ico"

[Setup]
AppId={{A7C9E2B1-4F18-4D6A-9C3E-ROSE2026SCH00}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\RoseSchool2026
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=RoseSchoolSetup
SetupIconFile={#AppIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
DisableWelcomePage=no
DisableDirPage=no
DisableReadyMemo=no
AllowNoIcons=yes
ChangesAssociations=no
CloseApplications=yes
RestartApplications=no
; Arabic-friendly installer UI when available
ShowLanguageDialog=no
LicenseFile=
InfoBeforeFile=
InfoAfterFile=

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; If you installed Arabic translation pack for Inno, you can enable:
; Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "إنشاء اختصار على سطح المكتب"; GroupDescription: "اختصارات:"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "إنشاء اختصار تشغيل سريع"; GroupDescription: "اختصارات:"; Flags: unchecked

[Files]
; Copy the full Flutter Windows Release folder
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\إلغاء تثبيت {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\{#MyAppExeName}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "تشغيل {#MyAppName} الآن"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Keep user data by default. Uncomment next line only if you want full wipe.
; Type: filesandordirs; Name: "{localappdata}\rose_school"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
