# ملخص حي — Rose School

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
- اختصار عربي: **مدرسة روز التعليمية الخاصة**
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
- `RoseSchool_Portable_....zip`

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

## ✍️ اعتماد المصمم داخل Setup
- عدّل `installer/credits.iss.inc` (الاسم/الهاتف/الإيميل)
- يظهر في الترحيب والإنهاء ومعلومات المثبت
- التوزيع: Setup و Portable كلاهما أساسيان

## 🌐 ربط عدة أجهزة (LAN)
المرجع:
```text
متطلبات_العمل/06_ربط_عدة_اجهزة_على_الشبكة_المحلية.md
```
الوضع الحالي: محلي لكل جهاز.
المطلوب للـ 4 أجهزة: سيرفر مركزي + مستخدمين/صلاحيات مركزية + حفظ عبر الشبكة.

## 🌐 قرارات الشبكة (محدثة)
- سيرفر دائم: نعم
- offline: مطلوب
- المدير يعمل على كل الأجهزة؛ المستخدم يعمل بأبوابه فقط
- البدء: كل النظام
المراجع:
- `متطلبات_العمل/07_قرار_الشبكة_والادوار_Offline.md`
- `متطلبات_العمل/08_لماذا_لا_يصدر_Setup_من_Arena_وكيف_تختبره.md`

## 🔑 نسيت كلمة السر (Login)
- زر «نسيت كلمة السر؟» في شاشة الدخول
- تحقق: اسم المستخدم + موبايل/إيميل المسجل
- تعيين كلمة سر جديدة محليًا
- خيار إبلاغ الإدارة عبر واتساب/إيميل الهوية

