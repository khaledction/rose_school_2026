# تجهيز Installer أنيق — Rose School 2026

هذا المجلد ينتج:

```text
dist\RoseSchoolSetup.exe
```

## المزايا الحالية
- اسم عربي للاختصارات: **مدرسة روز 2026**
- أيقونة مخصصة لملف الـ Setup (`app_icon.ico`)
- صفحة ترحيب عربية
- صفحة ترخيص/موافقة
- صفحة ختامية بعد التثبيت
- اختصارات سطح المكتب + قائمة ابدأ
- **تثبيت VC++ Redistributable x64 تلقائيًا عند الحاجة** (لحل MSVCP140 / VCRUNTIME140_1)

## 1) المتطلبات (مرة واحدة)
1. Flutter SDK  
2. Visual Studio مع **Desktop development with C++**  
3. [Inno Setup 6](https://jrsoftware.org/isinfo.php)

```powershell
flutter doctor
```

## 2) الطريقة الأسهل
```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

ينفّذ:
1. تنزيل `installer\redist\vc_redist.x64.exe` إن لم يوجد
2. بناء Windows Release
3. ZIP محمول في `dist\` (مع `vc_redist.x64.exe` داخل الحزمة)
4. `RoseSchoolSetup.exe` عبر Inno Setup

### خيارات
```powershell
# بدون clean
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1 -SkipClean

# ZIP فقط
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1 -SkipInstaller
```

## 3) طريقة يدوية
```powershell
cd C:\Users\khaledction\Desktop\new-rose
flutter clean
flutter pub get
flutter build windows --release
```

تأكد من وجود:
```text
installer\redist\vc_redist.x64.exe
```
(يمكن تنزيله من: https://aka.ms/vs/17/release/vc_redist.x64.exe)

ثم افتح:
```text
installer\RoseSchool.iss
```
واضغط **Compile**.

## 4) ملفات المثبت
| ملف | الدور |
|-----|------|
| `RoseSchool.iss` | سكربت Inno Setup |
| `welcome_ar.txt` | صفحة الترحيب |
| `license_ar.txt` | صفحة الترخيص/الموافقة |
| `infoafter_ar.txt` | صفحة ما بعد التثبيت |
| `redist\vc_redist.x64.exe` | مكتبات Microsoft (تُنزّل عند البناء) |
| `..\windows\runner\resources\app_icon.ico` | أيقونة الـ Setup والاختصارات |

## 5) المخرجات
| الملف | الاستخدام |
|------|-----------|
| `dist\RoseSchoolSetup.exe` | تثبيت أنيق + VC++ تلقائي |
| `dist\RoseSchool2026_Portable_....zip` | تشغيل محمول + helper VC++ |
| `build\windows\x64\runner\Release\` | مجلد التنفيذ الخام |

## 6) التوزيع
### الأفضل
أرسل `RoseSchoolSetup.exe` فقط.

### البديل
أرسل ZIP المحمول ثم شغّل `rose_school.exe`.

## 7) ملاحظات
- Windows 10/11 x64
- لا يحتاج Flutter على الجهاز الهدف
- بيانات المستخدم تُحفظ بعد الإلغاء افتراضيًا

## 8) حل خطأ MSVCP140.dll / VCRUNTIME140_1.dll
مع `RoseSchoolSetup.exe` الحديث: التثبيت يتم تلقائيًا.

إذا ظهرت الرسالة رغم ذلك (أو عند استخدام ZIP):
1. شغّل `vc_redist.x64.exe`
2. Install
3. أعد التشغيل
4. افتح البرنامج

رابط Microsoft المباشر:
- https://aka.ms/vs/17/release/vc_redist.x64.exe
