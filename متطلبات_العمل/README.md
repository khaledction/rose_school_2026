# متطلبات العمل — Rose School 2026

هذا المجلد يلخّص **كل ما تحتاجه** لتحويل المشروع إلى ملف تنفيذي وتوزيعه على أجهزة أخرى.

## المحتويات

| ملف | الغرض |
|-----|--------|
| `01_متطلبات_جهاز_البناء.md` | برامج ومتطلبات الجهاز الذي يبني التطبيق |
| `02_خطوات_البناء_والتثبيت.md` | خطوات عملية من الكود إلى Setup.exe |
| `03_متطلبات_الجهاز_الهدف.md` | ما يحتاجه أي لابتوب/ديسكتوب لتشغيل البرنامج |
| `04_حل_مشاكل_DLL.md` | حل MSVCP140 / VCRUNTIME140_1 |
| `05_قائمة_تحقق_قبل_التوزيع.md` | Checklist سريعة قبل إرسال النسخة |

## روابط سريعة

- Flutter: https://docs.flutter.dev/get-started/install/windows
- Visual Studio: https://visualstudio.microsoft.com/
- Inno Setup 6: https://jrsoftware.org/isinfo.php
- VC++ Redistributable x64: https://aka.ms/vs/17/release/vc_redist.x64.exe
- المستودع: https://github.com/khaledction/rose_school_2026

## أمر البناء الكامل (بعد تجهيز المتطلبات)

```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

المخرجات:
- `dist\RoseSchoolSetup.exe` (يثبّت VC++ تلقائيًا عند الحاجة)
- `dist\RoseSchool2026_Portable_....zip` (يحتوي أيضًا `vc_redist.x64.exe`)
