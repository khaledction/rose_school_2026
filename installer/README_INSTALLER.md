# تجهيز Installer أنيق — Rose School 2026

هذا المجلد يحتوي سكربت **Inno Setup** لإنتاج:

```text
dist\RoseSchoolSetup.exe
```

## 1) المتطلبات (مرة واحدة)

1. Flutter SDK
2. Visual Studio مع **Desktop development with C++**
3. [Inno Setup 6](https://jrsoftware.org/isinfo.php)

تحقق:

```powershell
flutter doctor
```

## 2) الطريقة الأسهل (موصى بها)

من مجلد المشروع:

```powershell
cd C:\Users\khaledction\Desktop\new-rose
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

السكربت يقوم بـ:
1. `flutter clean` (اختياري تخطيه بـ `-SkipClean`)
2. `flutter pub get`
3. `flutter build windows --release`
4. إنشاء ZIP محمول في `dist\`
5. بناء `RoseSchoolSetup.exe` عبر Inno Setup

### خيارات

```powershell
# بدون clean
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1 -SkipClean

# ZIP فقط بدون installer
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1 -SkipInstaller
```

## 3) طريقة يدوية (Inno Setup)

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

## 4) المخرجات

| الملف | الاستخدام |
|------|-----------|
| `dist\RoseSchoolSetup.exe` | تثبيت أنيق على أي ويندوز |
| `dist\RoseSchool2026_Portable_....zip` | تشغيل محمول بدون تثبيت |
| `build\windows\x64\runner\Release\` | مجلد التنفيذ الخام |

## 5) التوزيع

### الأفضل
أرسل `RoseSchoolSetup.exe` فقط.

### البديل
أرسل ZIP المحمول، ويُستخرج كاملًا ثم:

```text
rose_school.exe
```

## 6) ملاحظات

- التطبيق 64-bit / Windows 10+
- لا تحتاج Flutter على الجهاز الهدف
- إذا ظهر نقص DLL نادرًا: ثبّت **VC++ Redistributable x64**
- بيانات المستخدم تبقى بعد الإلغاء (لا نحذفها افتراضيًا)
