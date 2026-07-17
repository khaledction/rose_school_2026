# 08) لماذا لم يُحوَّل المشروع إلى Setup من هنا؟ وكيف تختبره الآن؟

## السؤال
> لماذا لم تحول المشروع إلى setup لتجربته؟

## الجواب المباشر

لأن بيئة العمل هنا (Arena) **ليست جهاز ويندوز بناء كامل**:

- لا يوجد Visual Studio Windows Desktop toolchain
- لا يمكن تشغيل `flutter build windows` الحقيقي لويندوز من هذه البيئة
- لا يمكن تشغيل Inno Setup (`ISCC.exe`) لإنتاج `RoseSchoolSetup.exe` هنا
- ناتج Setup يجب أن يُبنى على **جهاز ويندوزك**

### ما تم تجهيزه بدلًا من ذلك
تم إعداد خط الإنتاج كاملًا داخل المشروع:

| الملف | الدور |
|------|------|
| `scripts/build_release_installer.ps1` | يبني Release + ZIP + Setup |
| `installer/RoseSchool.iss` | قالب المثبت |
| `installer/welcome_ar.txt` / `license_ar.txt` / `infoafter_ar.txt` | صفحات المثبت |
| `installer/credits.iss.inc` | اسم/هاتف/إيميل المصمم |
| `installer/redist/` | مكان `vc_redist.x64.exe` (يُنزَّل عند البناء) |
| `متطلبات_العمل/` | كل المتطلبات والخطوات |

يعني: **القالب جاهز**، والتنفيذي يُنتَج عندك بأمر واحد.

---

## كيف تنتج Setup الآن للاختبار (على جهازك)

### 1) متطلبات على جهاز البناء
- Windows 10/11 x64
- Flutter
- Visual Studio + Desktop development with C++
- Inno Setup 6

### 2) مزامنة
```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
```

### 3) أمر البناء
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_release_installer.ps1
```

### 4) أين تجد Setup؟
```text
C:\Users\khaledction\Desktop\new-rose\dist\RoseSchoolSetup.exe
```

وأيضًا:
```text
dist\RoseSchool_Portable_YYYYMMDD_HHMM.zip
```

---

## ماذا تتوقع عند الاختبار على جهاز ثاني؟

### إذا استخدمت Setup الجديد
- يثبّت البرنامج
- يثبّت VC++ تلقائيًا إذا ناقص (MSVCP140 / VCRUNTIME140_1)

### إذا استخدمت ZIP
- فك الضغط كاملًا
- إن ظهرت رسائل DLL: شغّل `vc_redist.x64.exe` داخل المجلد

---

## الفرق بين “تجهيز Setup” و“بناء Setup”

| المهمة | أين تتم |
|--------|---------|
| كتابة سكربتات المثبت والوثائق | تم هنا في المستودع |
| توليد `RoseSchoolSetup.exe` فعليًا | على جهاز ويندوزك فقط |

---

## إذا فشل البناء عندك
أرسل ناتج:
```powershell
flutter doctor -v
```
ووجود:
```powershell
Test-Path "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
```
