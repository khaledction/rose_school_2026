; ============================================================
; Rose School 2026 - Inno Setup Installer Script (Elegant)
; ------------------------------------------------------------
; Features:
; - Arabic shortcut names
; - Custom setup icon
; - Welcome + License + After-install pages
; ============================================================

#define MyAppName "Rose School 2026"
#define MyAppNameAr "مدرسة روز 2026"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Rose School"
#define MyAppURL "https://github.com/khaledction/rose_school_2026"
#define MyAppExeName "rose_school.exe"

; Source folder produced by: flutter build windows --release
#define SourceDir "..\build\windows\x64\runner\Release"
#define OutputDir "..\dist"

; Custom installer/app icon
#define AppIcon "..\windows\runner\resources\app_icon.ico"

; Arabic pages
#define WelcomeFile "welcome_ar.txt"
#define LicenseFileName "license_ar.txt"
#define InfoAfterFileName "infoafter_ar.txt"

[Setup]
AppId={{A7C9E2B1-4F18-4D6A-9C3E-ROSE2026SCH00}
AppName={#MyAppNameAr}
AppVersion={#MyAppVersion}
AppVerName={#MyAppNameAr} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
DefaultDirName={autopf}\RoseSchool2026
DefaultGroupName={#MyAppNameAr}
DisableProgramGroupPage=no
OutputDir={#OutputDir}
OutputBaseFilename=RoseSchoolSetup
SetupIconFile={#AppIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppNameAr}
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
ShowLanguageDialog=no
; Welcome / License / After pages
InfoBeforeFile={#WelcomeFile}
LicenseFile={#LicenseFileName}
InfoAfterFile={#InfoAfterFileName}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppNameAr} Setup
VersionInfoProductName={#MyAppNameAr}
VersionInfoCopyright=Copyright (C) {#MyAppPublisher}
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Optional Arabic UI language pack (if installed with Inno Setup):
; Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Messages]
; English base with Arabic-friendly captions used in shortcuts/tasks.
WelcomeLabel1=Welcome to {#MyAppNameAr} Setup
WelcomeLabel2=This will install {#MyAppNameAr} on your computer.%n%nIt is recommended that you close all other applications before continuing.
FinishedLabel=Setup has finished installing {#MyAppNameAr} on your computer.
ClickFinish=Click Finish to exit Setup.
ConfirmUninstall=Are you sure you want to completely remove %1 and all of its components?

[Tasks]
Name: "desktopicon"; Description: "إنشاء اختصار سطح المكتب: {#MyAppNameAr}"; GroupDescription: "الاختصارات:"; Flags: checkedonce
Name: "startmenuicon"; Description: "إنشاء اختصار قائمة ابدأ: {#MyAppNameAr}"; GroupDescription: "الاختصارات:"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "إنشاء اختصار تشغيل سريع"; GroupDescription: "الاختصارات:"; Flags: unchecked

[Files]
; Full Flutter Windows Release payload
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Keep a dedicated icon file inside install folder for shortcuts
Source: "{#AppIcon}"; DestDir: "{app}"; DestName: "app_icon.ico"; Flags: ignoreversion

[Icons]
; Start Menu (Arabic)
Name: "{group}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Comment: "تشغيل نظام إدارة مدرسة روز"
Name: "{group}\إلغاء تثبيت {#MyAppNameAr}"; Filename: "{uninstallexe}"; IconFilename: "{app}\app_icon.ico"
; Desktop (Arabic)
Name: "{autodesktop}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: desktopicon; Comment: "مدرسة روز 2026"
; Optional extra Start Menu entry controlled by task
Name: "{userprograms}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: startmenuicon
; Quick Launch
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "تشغيل {#MyAppNameAr} الآن"; Flags: nowait postinstall skipifsilent unchecked

[UninstallDelete]
; Keep user data by default (safer for school records).
; Type: filesandordirs; Name: "{localappdata}\rose_school"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard();
begin
  // Keep modern wizard; pages are provided via InfoBefore/License/InfoAfter files.
  WizardForm.WelcomeLabel1.Caption := 'مرحبًا بك في تثبيت مدرسة روز 2026';
  WizardForm.WelcomeLabel2.Caption :=
    'سيُثبَّت نظام Rose School 2026 على هذا الجهاز.' + #13#10 + #13#10 +
    'يُنصح بإغلاق البرامج الأخرى قبل المتابعة.' + #13#10 + #13#10 +
    'اضغط "التالي" للمتابعة.';
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption :=
      'اكتمل تثبيت مدرسة روز 2026 بنجاح.' + #13#10 + #13#10 +
      'يمكنك تشغيل البرنامج من الاختصار: مدرسة روز 2026';
  end;
end;
