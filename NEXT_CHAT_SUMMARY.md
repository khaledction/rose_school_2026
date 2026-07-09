# ملخص الجلسة للمحادثة القادمة

> تاريخ التحديث: **2026-07-09**
>
> المشروع: `rose_school_2026`
>
> المستودع: https://github.com/khaledction/rose_school_2026.git
>
> الفرع: `main`
>
> آخر commit: `5318953` — *UX overhaul: form layout, preset installments, compact widgets, sidebar fixes*
>
> المجلد المحلي على ويندوز: `C:\Users\khaledction\Desktop\new-rose`

---

## ⚠️ تنبيه أمني

إذا سبق مشاركة GitHub token في أي محادثة: **ألغِه فوراً** من GitHub Settings → Tokens وأنشئ توكن جديد.

---

## 🎯 ملخص تنفيذي سريع

المشروع تطبيقة Flutter لويندوز (RTL / عربي) لإدارة مدرسة **Rose School 2026**.

- **~19,300 سطر Dart** في `lib/`
- **22 commit** على `main`
- المراحل الأساسية من الخطة **مكتوبة كملفات** (Dashboard → Dark Mode)
- لكن **بعض الوظائف موجودة ككود ولم تُربط بعد** بالواجهة (Export / حماية المدير / Dark Mode)
- **Flutter غير متاح داخل Arena** — التعديلات static، والاختبار محلياً على ويندوز

---

## 🖥️ تشغيل محلي (ويندوز)

```cmd
cd C:\Users\khaledction\Desktop\new-rose
git pull
flutter clean
flutter pub get
flutter run -d windows
```

أو استنساخ نظيف:

```cmd
cd /d C:\Users\khaledction\Desktop
git clone https://github.com/khaledction/rose_school_2026.git rose-school-new
cd /d C:\Users\khaledction\Desktop\rose-school-new
flutter clean
flutter pub get
flutter run -d windows
```

---

## 📂 بنية التخزين المحلي

```
Documents/
└── Rose_School_edu/
    ├── data/          ← rose_school_2026.db
    ├── files/
    │   ├── students/
    │   ├── employees/
    │   └── school/    ← ختم، توقيع، شعار
    ├── backups/       ← ROSE_BACKUP_*.zip (حالياً JSON+base64 وليس ZIP حقيقي)
    ├── reports/       ← تقارير التصدير
    └── config/
```

الخدمة المركزية: `lib/services/app_storage_paths_service.dart`  
**قاعدة:** لا تستخدم `getApplicationDocumentsDirectory()` مباشرة في ملفات جديدة.

---

## 🗺️ حالة المراحل (بعد المراجعة الفعلية للكود — 2026-07-09)

| # | المرحلة | الحالة | ملاحظات |
|---|---------|--------|---------|
| A | توحيد مسارات التخزين | ✅ مكتمل | `app_storage_paths_service.dart` مربوط بـ DB وملفات الطلاب |
| 1 | لوحة القيادة + إشعارات | ✅ مكتمل تقريباً | `dashboard_page.dart` + `notification_service.dart` + جرس في الهيدر |
| 2 | الموظفون | ✅ مكتمل تقريباً | استمارة أمانة السر + مراجعة مالية للإدارة؛ التنقل تحت أمانة السر |
| 3 | الإيرادات والصرفيات | ✅ مكتمل تقريباً | `accounting_income_expenses_page.dart` + `finance_service.dart` |
| 4 | اجتماعات أولياء الأمور | ✅ مكتمل تقريباً | `parent_meetings_page.dart` + `meeting_service.dart` |
| 5 | مركز البيانات المحلي | 🟡 جزئي | UI موجود؛ Backup/Restore يعملان بأسلوب JSON؛ **لا أزرار Export**؛ فتح المجلد = نسخ مسار |
| 6 | تغيير الأسماء + ختم/توقيع | ✅ مكتمل | مدير عام / مشرف القسم / المشرف العام + صور ختم وتوقيع |
| 7 | فرز الطلاب | ✅ مكتمل + تحسينات | حسب الصف / الصف+شعبة + أعلى 3 على مستوى المدرسة |
| 8 | النسخ الاحتياطي | 🟡 جزئي | `BackupService` موجود لكن الـ "zip" هو JSON+base64 (لا حزمة `archive`) |
| 9 | التصدير | 🟡 كود فقط | `ExportService` (JSON/CSV) **غير مستدعى** من أي صفحة |
| 10 | حماية المدير | 🟡 كود فقط | `AdminPasswordDialog` **غير مربوط** بعمليات Backup/Restore/Export |
| 11 | أقساط ذكية | 🟡 جزئي | إعدادات أقساط/مواصلات + presets (عادي / +مواصلات / +منحة) في المحاسبة |
| 12 | Dark Mode | 🟡 كود فقط | `DarkModeProvider` موجود؛ **غير مدمج** في `main.dart` ولا زر في الهيدر |
| 13 | طباعة جماعية | 🟡 جزئي | طباعة جماعية للجلاء موجودة؛ باقي التقارير الجماعية حسب الخطة غير مكتملة |
| 14 | أرشفة تلقائية | ❌ غير منفّذ | لا منطق نهاية سنة / فلتر أرشيف |
| 15 | اختبار ويندوز الشامل | ⏳ معلّق | `WINDOWS_TEST_CHECKLIST.md` جاهز (83 حالة) — يحتاج تشغيل محلي |

---

## 📁 خريطة الملفات الحالية

### pages (`lib/pages/`)
| ملف | الدور |
|-----|-------|
| `school_shell_page.dart` (~3577 سطر) | الهيكل الرئيسي، تسجيل الدخول، state، تنقل |
| `school_shell_sections.dart` (~7003 سطر) | أقسام الواجهة (part of shell) |
| `dashboard_page.dart` | لوحة القيادة |
| `employees_page.dart` | موظفين — أمانة السر |
| `employee_finance_review_page.dart` | مراجعة مالية — إدارة |
| `accounting_income_expenses_page.dart` | إيرادات وصرفيات |
| `parent_meetings_page.dart` | اجتماعات أولياء الأمور |
| `local_data_center_page.dart` | مركز البيانات |
| `student_sorting_page.dart` | فرز الطلاب |

### services (`lib/services/`)
| ملف | الدور |
|-----|-------|
| `app_storage_paths_service.dart` | مسارات موحّدة |
| `school_database_service.dart` | SQLite + JSON keys |
| `local_student_file_service.dart` | صور/QR/مرفقات الطلاب |
| `notification_service.dart` | إشعارات داخلية |
| `employee_service.dart` | موظفين |
| `finance_service.dart` | إيرادات/صرفيات |
| `meeting_service.dart` | اجتماعات |
| `backup_service.dart` | نسخ احتياطي (شبه ZIP) |
| `export_service.dart` | JSON/CSV (**غير مربوط**) |

### models / dialogs / widgets
| ملف | الدور |
|-----|-------|
| `school_models.dart` | طلاب، هوية، مستخدمين، محاسبة أساسية… |
| `employee_model.dart` | موظف + سجل مالي |
| `finance_models.dart` | تصنيفات وقيود |
| `meeting_models.dart` | اجتماع + حضور |
| `notification_model.dart` | إشعار |
| `admin_password_dialog.dart` | حماية مدير (**غير مربوط**) |
| `dark_mode_toggle.dart` | Provider + زر (**غير مربوط**) |
| `school_shell_widgets.dart` | ويدجتات مشتركة |
| `seed_data.dart` | بيانات أولية |

### deps مهمة (`pubspec.yaml`)
`sqflite_common_ffi`, `path_provider`, `provider`, `intl`, `image_picker`, `file_picker`, `qr`, `pdf`, `printing`, `crypto`, `shared_preferences`, `excel`

> ملاحظة: حزمة `excel` موجودة في pubspec لكن مسار التصدير الحالي في `ExportService` يكتب **CSV** وليس XLSX فعلي. لا توجد حزمة `archive` لـ ZIP حقيقي.

---

## 🧭 الشريط الجانبي الحالي (من الكود)

**الإدارة**
- 📊 لوحة القيادة
- 🔍 مراجعة الموظفين
- لوحة الإدارة
- الهوية والاعتماد (فيها أيضاً إعدادات الأقساط والمواصلات)

**أمانة السر**
- قائمة الطلاب
- 👥 الموظفين
- استمارة طالب
- الحضور والغياب
- المكافآت والعقوبات
- الشهادات
- الوثائق والمرفقات
- التقارير
- بطاقة الطالب والطباعة
- النسخ الاحتياطي والاستعادة (القديم)
- 📁 مركز البيانات المحلي
- 📅 اجتماعات أولياء الأمور
- النقل المدرسي
- مراسلات أولياء الأمور

**الامتحانات**
- لوحة الامتحانات
- 🔍 فرز الطلاب

**المحاسبة**
- لوحة المحاسبة (أقساط / تبرعات / مساعدات + presets)
- التبرعات
- 💰 الإيرادات والصرفيات

---

## 🔧 قرارات معتمدة سابقاً (ما زالت سارية)

- جذر التخزين: `Rose_School_edu`
- الموظفون: أمانة السر = بيانات شخصية فقط → الإدارة = مالي + قبول/رفض
- الإيرادات: أقساط + تبرعات + تصنيفات قابلة للإضافة
- الصرفيات: تصنيفات افتراضية + قابلة للإضافة
- الأسماء: الموجه ← مشرف القسم، أمين السر ← مدير/مدير عام، + المشرف العام
- الخاتم والتوقيع: صور اختيارية
- الفرز: صفحة مستقلة تحت الامتحانات

---

## 📌 ما تغيّر بعد ملخص 2026-07-07

commits بعد مرحلة A:

1. `f621ad4` Phase 1 Dashboard + notifications  
2. `5db848f` Phase 2 Employees  
3. `7742df7` Phase 3 Income & Expenses  
4. `bcd01d0` Phase 4 Parent meetings  
5. `a8bb3fe` Phase 5 Local Data Center + Backup  
6. `44c3143` Phase 6 Names + seal/signature  
7. `4f02bc2` Phase 7 Student sorting  
8. `de472ac` Phases 8–14 Export, security, Dark Mode, checklist  
9. `6612633` Fix compile errors  
10. `1c44388` نقل الموظفين إلى أمانة السر  
11. `bbb0418` UI: كنية، بحث حي، نقل الفرز للامتحانات، المدير العام…  
12. `dc5cf59` / `853254d` / `689e3e6` / `397c366` إصلاح تبويبات الاستمارة + تحسين الفرز  
13. `5318953` UX: تخطيط نماذج، preset أقساط، ويدجتات مدمجة، إصلاحات سايدبار  

---

## 🔴 فجوات معروفة (أولوية إصلاح/إكمال)

### P0 — ربط ما هو مكتوب وغير موصول
1. **ربط `AdminPasswordDialog.requirePassword`** قبل: إنشاء نسخة، استعادة، حذف نسخة، تصدير كامل  
2. **أزرار Export في `local_data_center_page.dart`** تستدعي `ExportService`  
3. **دمج Dark Mode** في `main.dart` (Provider + themeMode) وزر في الهيدر بجانب الجرس  

### P1 — جودة Backup/Export
4. ZIP حقيقي (إضافة `archive` أو أداة نظام) بدل JSON+base64  
5. فتح مجلدات ويندوز فعلياً (`Process.start('explorer', [path])`) بدل نسخ المسار فقط  
6. استخدام حزمة `excel` لتصدير XLSX حقيقي إن لزم  

### P2 — ميزات الخطة المتبقية
7. أرشفة نهاية السنة + فلتر أرشيف  
8. تقوية الأقساط الذكية (ربط أوضح بالإعدادات المحفوظة لكل طالب)  
9. طباعة جماعية أوسع (ليس فقط الجلاء)  
10. إزالة/دمج صفحة `backup` القديمة مع مركز البيانات لتفادي التكرار  

### P3 — تنظيف / اختبار
11. تشغيل `WINDOWS_TEST_CHECKLIST.md` محلياً وتوثيق النتائج  
12. إصلاح أي أخطاء compile تظهر عند `flutter run -d windows`  
13. `DarkModeToggleWidget` الحالي ينشئ Provider جديد في كل build — يحتاج Provider واحد على مستوى التطبيق  

---

## 📝 نص مقترح للمحادثة الجديدة

> افتح `NEXT_CHAT_SUMMARY.md` كمرجع أساسي (محدث 2026-07-09).  
> المستودع: https://github.com/khaledction/rose_school_2026  
> المجلد المحلي: `C:\Users\khaledction\Desktop\new-rose`  
> الخطة: `ROSE_SCHOOL_2026_FULL_PLAN.md`  
> **الوضع:** مراحل A + 1→7 منفّذة وظيفياً تقريباً؛ 8→12 كود موجود جزئياً/غير مربوط؛ 14 أرشفة غير منفّذة.  
> **المطلوب التالي حسب الأولوية:** ربط حماية المدير + Export + Dark Mode، ثم تقوية Backup الحقيقي، ثم الأرشفة، ثم اختبار ويندوز.

---

## 📌 ملاحظات فنية للمساعد

1. Flutter غير متاح في Arena — static edits فقط؛ المستخدم يختبر على ويندوز.  
2. ارفع كل مرحلة مهمة إلى GitHub بعد إنجازها.  
3. الواجهة والتعليقات المهمة بالعربية.  
4. `school_shell_page.dart` + `school_shell_sections.dart` (part) هما قلب التطبيق — عدّل بحذر.  
5. أي مسار جديد عبر `AppStoragePathsService.instance`.  
6. لا تشارك توكنات GitHub في المحادثة.  
7. بعد التعديل المحلي: `git pull` ثم `flutter clean && flutter pub get && flutter run -d windows`.  

---

## 🎯 الأولوية القادمة المقترحة (جلسة واحدة)

### حزمة الربط (Wire-up package)
1. حماية المدير على عمليات مركز البيانات  
2. أزرار تصدير JSON/CSV من مركز البيانات  
3. Dark Mode فعّال في التطبيق  
4. فتح مجلدات ويندوز بـ explorer  
5. تحديث checklist بعد الاختبار المحلي  

بعدها: ZIP حقيقي → أرشفة → صقل UX.
