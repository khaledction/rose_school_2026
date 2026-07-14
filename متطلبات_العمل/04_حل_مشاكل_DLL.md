# 04) حل أخطاء DLL الشائعة

## الخطأ
```text
The code execution cannot proceed because MSVCP140.dll was not found.
The code execution cannot proceed because VCRUNTIME140_1.dll was not found.
```

## السبب
الجهاز لا يحتوي Microsoft Visual C++ Runtime (2015–2022 x64).

## الحل الأسهل (الآن)
استخدم:
```text
RoseSchoolSetup.exe
```
لأنه يثبّت VC++ تلقائيًا إذا كان ناقصًا.

## الحل اليدوي (إن ظهر الخطأ)
1. افتح المتصفح على الجهاز الهدف
2. حمّل:
   - https://aka.ms/vs/17/release/vc_redist.x64.exe
3. شغّل `vc_redist.x64.exe`
4. Install
5. أعد تشغيل الجهاز
6. شغّل `rose_school.exe` مرة أخرى

## إذا كنت تستخدم النسخة المحمولة
1. ادخل مجلد البرنامج
2. شغّل `vc_redist.x64.exe`
3. Install + Restart
4. شغّل `rose_school.exe`

## أخطاء شائعة
| خطأ | الحل |
|-----|------|
| ثبّتت x86 بدل x64 | ثبّت `vc_redist.x64.exe` |
| نسخت exe وحده | انسخ مجلد Release كاملًا |
| ما زال الخطأ بعد التثبيت | أعد التشغيل ثم أعد الفتح |
| Antivirus منع التشغيل | اسمح/استثناء للمجلد |

## ملاحظة
بعد تثبيت VC++ مرة واحدة على الجهاز، لن تحتاج إعادته في كل مرة.
