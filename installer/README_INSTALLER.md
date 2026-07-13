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
1. بناء Windows Release
2. ZIP محمول في `dist\`
3. `RoseSchoolSetup.exe` عبر Inno Setup

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
| `..\windows\runner\resources\app_icon.ico` | أيقونة الـ Setup والاختصارات |

## 5) المخرجات
| الملف | الاستخدام |
|------|-----------|
| `dist\RoseSchoolSetup.exe` | تثبيت أنيق |
| `dist\RoseSchool2026_Portable_....zip` | تشغيل محمول |
| `build\windows\x64\runner\Release\` | مجلد التنفيذ الخام |

## 6) التوزيع
### الأفضل
أرسل `RoseSchoolSetup.exe` فقط.

### البديل
أرسل ZIP المحمول ثم شغّل `rose_school.exe`.

## 7) ملاحظات
- Windows 10/11 x64
- لا يحتاج Flutter على الجهاز الهدف
- عند نقص DLL نادر: **VC++ Redistributable x64**
- بيانات المستخدم تُحفظ بعد الإلغاء افتراضيًا
