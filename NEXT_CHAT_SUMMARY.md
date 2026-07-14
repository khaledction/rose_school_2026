# ملخص حي — Rose School 2026

> آخر تحديث: **2026-07-13**
>
> المستودع: https://github.com/khaledction/rose_school_2026
>
> Desktop: `C:\Users\khaledction\Desktop\new-rose`

## تنظيف المستودع (هذه الجلسة)

حُذفت ملفات غير تشغيلية لتخفيف الحجم:
- HTML تجريبية/معاينات كبيرة
- mockups + reference
- خطط قديمة مكررة
- تكرارات logo في الجذر

ما بقي ضروري للتشغيل:
- `lib/` كود التطبيق
- `assets/` + `image/` أصول مستخدمة في pubspec
- منصات Flutter (`windows` أساسًا)
- `README.md` + هذا الملف

## حالة وظيفية مختصرة

- محاسبة: أقساط / دفعات / مستحقون
- زر **قسط** و**دفعة** يصفيان المستحق تلقائيًا (أخضر + تم الدفع)
- إدارة: صلاحيات وتحكم + مركز إدارة
- قوائم طويلة: أكورديون + عدد يسار

## مزامنة Desktop

```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
flutter clean
flutter pub get
flutter run -d windows
```

## بناء تنفيذي

انظر `README.md` → قسم **بناء ملف تنفيذي لويندوز**.

## 📦 تجهيز Installer أنيق (2026-07-13)

### أُضيف
- `scripts/build_release_installer.ps1` — بناء Release + ZIP + Setup
- `installer/RoseSchool.iss` — قالب Inno Setup
- `installer/welcome_ar.txt` — ترحيب
- `installer/license_ar.txt` — ترخيص
- `installer/infoafter_ar.txt` — بعد التثبيت
- `installer/README_INSTALLER.md` — دليل التثبيت الأنيق

### مزايا المثبت
- اختصار عربي: **مدرسة روز 2026**
- أيقونة Setup مخصصة
- صفحات ترحيب / ترخيص / إنهاء

### أوامر سريعة
```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

المخرجات في `dist\`:
- `RoseSchoolSetup.exe`
- `RoseSchool2026_Portable_....zip`

## 📝 أرشيف المحادثة

لقراءة الجلسة كاملة غدًا:

```text
docs/CONVERSATION_ARCHIVE_2026-07-13.md
```

نسخه إلى سطح المكتب:

```powershell
copy /Y "docs\CONVERSATION_ARCHIVE_2026-07-13.md" "%USERPROFILE%\Desktop\CONVERSATION_ARCHIVE_2026-07-13.md"
```

## 🧰 تحديث المثبت + متطلبات العمل

- المثبت يثبّت VC++ x64 تلقائيًا عند الحاجة
- النسخة المحمولة تتضمن `vc_redist.x64.exe`
- أُضيف مجلد `متطلبات_العمل/` بكل برامج ومتطلبات التحويل إلى تنفيذي

