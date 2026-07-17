; ============================================================
; Rose School - Inno Setup Installer Script (Elegant)
; ------------------------------------------------------------
; Features:
; - Arabic shortcut names
; - Custom setup icon
; - Welcome + License + After-install pages
; - Designer/programmer credits (name/phone/email)
; - Auto-install VC++ Redistributable x64 if missing
; ============================================================

#include "credits.iss.inc"

#define MyAppName "Rose School"
#define MyAppNameAr "مدرسة روز"
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

; VC++ runtime bootstrap (downloaded by scripts\build_release_installer.ps1)
#define VCRedist "redist\vc_redist.x64.exe"

[Setup]
AppId={{A7C9E2B1-4F18-4D6A-9C3E-ROSE2026SCH00}
AppName={#MyAppNameAr}
AppVersion={#MyAppVersion}
AppVerName={#MyAppNameAr} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppContact={#DesignerPhone} | {#DesignerEmail}
AppComments={#DesignerNote} {#DesignerName}
DefaultDirName={autopf}\RoseSchool
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
VersionInfoCopyright=Copyright (C) {#MyAppPublisher} - {#DesignerName}
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Optional Arabic UI language pack (if installed with Inno Setup):
; Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Messages]
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
; VC++ Redistributable bootstrap (installed only when missing)
Source: "{#VCRedist}"; DestDir: "{tmp}"; DestName: "vc_redist.x64.exe"; Flags: deleteafterinstall ignoreversion

[Icons]
; Start Menu (Arabic)
Name: "{group}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Comment: "تشغيل نظام إدارة مدرسة روز"
Name: "{group}\إلغاء تثبيت {#MyAppNameAr}"; Filename: "{uninstallexe}"; IconFilename: "{app}\app_icon.ico"
; Desktop (Arabic)
Name: "{autodesktop}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: desktopicon; Comment: "مدرسة روز"
; Optional extra Start Menu entry controlled by task
Name: "{userprograms}\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: startmenuicon
; Quick Launch
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppNameAr}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: quicklaunchicon

[Run]
; Install VC++ runtime automatically when needed (silent)
Filename: "{tmp}\vc_redist.x64.exe"; \
  Parameters: "/install /quiet /norestart"; \
  StatusMsg: "جاري تثبيت مكتبات Microsoft Visual C++ المطلوبة..."; \
  Check: VCRedistNeedsInstall; \
  Flags: waituntilterminated
; Launch app
Filename: "{app}\{#MyAppExeName}"; Description: "تشغيل {#MyAppNameAr} الآن"; Flags: nowait postinstall skipifsilent unchecked

[UninstallDelete]
; Keep user data by default (safer for school records).
; Type: filesandordirs; Name: "{localappdata}\rose_school"

[Code]
function VCRedistNeedsInstall: Boolean;
var
  Major: Cardinal;
  Installed: Cardinal;
begin
  Result := True;

  // VC++ 2015-2022 x64 runtime registry marker
  if RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
    begin
      if RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Major', Major) then
      begin
        if Major >= 14 then
          Result := False;
      end
      else
        Result := False;
    end;
  end;

  // Fallback older key casing used on some systems
  if Result then
  begin
    if RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64', 'Installed', Installed) then
    begin
      if Installed = 1 then
        Result := False;
    end;
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard();
begin
  WizardForm.WelcomeLabel1.Caption := 'مرحبًا بك في تثبيت مدرسة روز';
  WizardForm.WelcomeLabel2.Caption :=
    'سيُثبَّت نظام Rose School على هذا الجهاز.' + #13#10 + #13#10 +
    '{#DesignerNote} {#DesignerName}' + #13#10 +
    'الهاتف: {#DesignerPhone}' + #13#10 +
    'البريد: {#DesignerEmail}' + #13#10 + #13#10 +
    'سيقوم المثبت تلقائيًا بتثبيت مكتبات Visual C++ عند الحاجة.' + #13#10 + #13#10 +
    'يُنصح بإغلاق البرامج الأخرى قبل المتابعة.' + #13#10 + #13#10 +
    'اضغط "التالي" للمتابعة.';
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption :=
      'اكتمل تثبيت مدرسة روز بنجاح.' + #13#10 + #13#10 +
      'يمكنك تشغيل البرنامج من الاختصار: مدرسة روز' + #13#10 + #13#10 +
      '{#DesignerNote} {#DesignerName}' + #13#10 +
      'الهاتف: {#DesignerPhone}' + #13#10 +
      'البريد: {#DesignerEmail}';
  end;
end;
