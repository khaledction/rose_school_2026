# Rose School 2026

نظام إدارة مدرسي محلي لويندوز — Flutter + SQLite (عربي / RTL).

## التشغيل (تطوير)

```cmd
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
flutter clean
flutter pub get
flutter run -d windows
```

## المستودع

https://github.com/khaledction/rose_school_2026

## الوثائق

| ملف | الغرض |
|-----|--------|
| `NEXT_CHAT_SUMMARY.md` | المرجع الحي |
| `README.md` | تشغيل + بناء |
| `installer/README_INSTALLER.md` | دليل الـ Installer الأنيق |

---

## بناء ملف تنفيذي (Release)

### المتطلبات
- Flutter
- Visual Studio (Desktop development with C++)
- اختياري للتثبيت الأنيق: [Inno Setup 6](https://jrsoftware.org/isinfo.php)

### طريقة واحدة — سكربت كامل (موصى به)

```powershell
cd C:\Users\khaledction\Desktop\new-rose
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

ينتج:
- `dist\RoseSchoolSetup.exe` ← ملف تثبيت أنيق
- `dist\RoseSchool2026_Portable_YYYYMMDD_HHMM.zip` ← نسخة محمولة
- `build\windows\x64\runner\Release\` ← مجلد التشغيل

### طريقة اثنين — بناء فقط

```cmd
flutter clean
flutter pub get
flutter build windows --release
```

المخرجات:

```text
build\windows\x64\runner\Release\rose_school.exe
```

> انسخ مجلد `Release` كاملًا (ليس exe وحده).

---

## Installer أنيق (Inno Setup)

القالب جاهز:

```text
installer\RoseSchool.iss
```

بعد `flutter build windows --release`:

1. افتح الملف بـ Inno Setup
2. Compile
3. احصل على `dist\RoseSchoolSetup.exe`

أو استخدم السكربت أعلاه ليقوم بكل شيء تلقائيًا.

### ماذا يفعل الـ Setup؟
- يثبّت في `Program Files\RoseSchool2026`
- اختصار عربي: **مدرسة روز 2026**
- أيقونة مخصصة لملف التثبيت والاختصارات
- صفحة ترحيب + ترخيص + إنهاء بالعربية
- اختصار قائمة ابدأ + سطح المكتب (اختياري)
- زر تشغيل بعد التثبيت
- إلغاء تثبيت نظيف

---

## التوزيع لأي جهاز ويندوز

### الأفضل
أرسل:

```text
RoseSchoolSetup.exe
```

### البديل المحمول
أرسل ZIP، يُفك الضغط، ثم تشغيل:

```text
rose_school.exe
```

### ملاحظات توافق
- Windows 10/11 (x64)
- لا يحتاج Flutter على الجهاز الآخر
- عند نقص DLL نادر: ثبّت **Microsoft Visual C++ Redistributable x64**

---

## ملاحظات الحجم

- التطبيق موجّه لويندوز أساسًا.
- مجلدات `android/ios/macos/linux/web` باقية كدعم Flutter متعدد المنصات.
