# ملخص الجلسة للمحادثة القادمة

> تاريخ الجلسة: 2026-07-07
> 
> المشروع: rose_school_2026
> 
> المستودع: https://github.com/khaledction/rose_school_2026.git
> 
> الفرع: main
> 
> آخر commit: `d877ef1` — *Phase A: Unify local storage paths under Rose_School_edu*

---

## ⚠️ تنبيه مهم جداً

**تم مشاركة GitHub token في المحادثة السابقة.**
يجب **إلغاء ذلك التوكن فوراً** من GitHub Settings > Tokens, وإنشاء توكن جديد. لأن التوكن أصبح مكشوفاً في سجل الرسائل.

---

## 🎯 ما تم إنجازه في هذه الجلسة

### 1 — وضع الخطة الكاملة

تم إنشاء ملف الخطة الكاملة ورفعه إلى المستودع:

📄 **`ROSE_SCHOOL_2026_FULL_PLAN.md`**

يحتوي على 17 مرحلة متكاملة مع كل التفاصيل.

### 2 — المرحلة A: توحيد مسارات التخزين المحلي ✅ (مكتملة ومرفوعة)

تم إنشاء وتعديل 3 ملفات:

| الملف | الحالة |
|-------|--------|
| 🆕 **`lib/services/app_storage_paths_service.dart`** | جديد |
| 🔧 **`lib/services/school_database_service.dart`** | معدّل — يستخدم المسار الموحد الآن |
| 🔧 **`lib/services/local_student_file_service.dart`** | معدّل — يستخدم المسار الموحد الآن |

### 3 — بنية التخزين الجديدة

```
Documents/
└── Rose_School_edu/
    ├── data/         ← قاعدة البيانات (rose_school_2026.db)
    ├── files/        ← الصور، QR، المرفقات
    │   ├── students/ ← ملفات الطلاب
    │   ├── employees/← صور الموظفين (للمستقبل)
    │   └── school/   ← الختم، التوقيع، الشعار
    ├── backups/      ← النسخ الاحتياطية (ROSE_BACKUP_*.zip)
    ├── reports/      ← التقارير المصدرة
    └── config/       ← الإعدادات (settings.json)
```

### 4 — ما تم الاتفاق عليه من القرارات الرئيسية

- **اسم الجذر:** `Rose_School_edu`
- **الموظفون:**
  - أمانة السر تملأ الاستمارة الشخصية فقط
  - الإدارة تدخل الحقول المالية وتقرر قبول/رفض
  - بعد التفعيل، المدير يقدر يزيد/ينقص الراتب والمكافآت والخصومات
  - الحقول المالية تظهر فقط في المحاسبة والإدارة
- **الإيرادات:** أقساط + تبرعات + تصنيفات إيراد قابلة للإضافة
- **الصرفيات:** 8 تصنيفات افتراضية قابلة للإضافة
- **اجتماعات أولياء الأمور:** توثيق الحضور مع تقارير + طباعة
- **تغيير الأسماء:** الموجه ← مشرف القسم, أمين السر ← مدير المدرسة, إضافة المشرف العام
- **الخاتم والتوقيع:** صور ترفع أو مكان فارغ
- **الفرز:** صفحة منفصلة (حسب الصف + حسب الصف والشعبة مع الأعلى درجات)
- **كل الاقتراحات تمت الموافقة عليها:** Dashboard, Dark Mode, إشعارات, طباعة جماعية ذكية, أرشفة تلقائية, أقساط ذكية

---

## 📋 خريطة المراحل كاملة

| # | المرحلة | الملفات | الحالة |
|---|---------|---------|--------|
| A | توحيد مسارات التخزين | `app_storage_paths_service.dart` + تعديل ملفين | ✅ مكتمل |
| 1 | 📊 لوحة القيادة + الإشعارات | `dashboard_page.dart`, `notification_service.dart` | ⏳ التالي |
| 2 | 👥 الموظفون | `employees_page.dart`, `employee_finance_review_page.dart`, `employee_service.dart` | ⏳ |
| 3 | 💰 الإيرادات والصرفيات | `accounting_income_expenses_page.dart`, `finance_service.dart` | ⏳ |
| 4 | 📅 اجتماعات أولياء الأمور | `parent_meetings_page.dart`, `meeting_service.dart` | ⏳ |
| 5 | 📁 مركز البيانات المحلي | `local_data_center_page.dart` | ⏳ |
| 6 | 🔄 تغيير الأسماء + الخاتم والتوقيع | تعديل `school_database_service.dart`, `school_models.dart` | ⏳ |
| 7 | 🔍 فرز الطلاب المتقدم | `student_sorting_page.dart` | ⏳ |
| 8 | 💾 النسخ الاحتياطي الحقيقي | `backup_service.dart` | ⏳ |
| 9 | 📄 التصدير الحقيقي | `export_service.dart` | ⏳ |
| 10 | 🔐 حماية المدير | `admin_password_dialog.dart` | ⏳ |
| 11 | 📊 أقساط ذكية | تحسين صفحة المحاسبة | ⏳ |
| 12 | 🌙 Dark Mode | تعديل `app_theme.dart` | ⏳ |
| 13 | 🖨️ طباعة جماعية ذكية | تحسين صفحة الطباعة | ⏳ |
| 14 | 🗄️ أرشفة تلقائية | إضافة فلتر وحالة أرشيف | ⏳ |
| 15 | ✅ اختبار ويندوز شامل | — | ⏳ |

---

## 📂 الملفات المرجعية المهمة

| الملف | لماذا؟ |
|-------|--------|
| `ROSE_SCHOOL_2026_FULL_PLAN.md` | الخطة الكاملة بكل التفاصيل |
| `lib/services/app_storage_paths_service.dart` | قلب المسارات — أي ملف جديد يحتاجه |
| `lib/services/school_database_service.dart` | قاعدة البيانات الرئيسية |
| `lib/services/local_student_file_service.dart` | خدمة تخزين الملفات |
| `lib/pages/school_shell_page.dart` | الصفحة الرئيسية (كل الأبواب) |
| `lib/pages/school_shell_sections.dart` | كل أقسام الواجهة الحالية |
| `lib/models/school_models.dart` | الموديلز (موديل الموظفين سيضاف لاحقاً) |
| `lib/theme/app_palette.dart` | الألوان |
| `lib/theme/app_theme.dart` | الثيم (لإضافة Dark Mode) |
| `pubspec.yaml` | المكتبات |

---

## 📝 النص المقترح للمحادثة الجديدة

> افتح ملف `NEXT_CHAT_SUMMARY.md` واعتبره المرجع الأساسي.
>
> المشروع هو `rose_school_2026` على GitHub.
>
> الخطة الكاملة في `ROSE_SCHOOL_2026_FULL_PLAN.md`.
>
> المرحلة A (توحيد المسارات) مكتملة ومرفوعة.
>
> **المطلوب الآن: البدء في المرحلة التالية حسب الترتيب في الخطة — ابدأ بالمرحلة 1: لوحة القيادة (Dashboard) مع الإشعارات.**

---

## 🔧 أمر تنزيل آخر نسخة إلى اللابتوب

للحصول على آخر كود مع التعديلات:

```cmd
cd /d C:\Users\khaledction\Desktop
git clone https://github.com/khaledction/rose_school_2026.git rose-school-new
cd /d C:\Users\khaledction\Desktop\rose-school-new
flutter clean
flutter pub get
flutter run -d windows
```

---

## 📌 ملاحظات فنية مهمة للمساعد القادم

1. **Flutter غير متاح داخل Arena** — كل التعديلات هي static code edits، وأي خطوة جديدة يجب أن تُجرّب محلياً على ويندوز.

2. **`app_storage_paths_service.dart` استخدمه لأي مسار جديد** — لا تكتب `getApplicationDocumentsDirectory()` مباشرة في أي ملف جديد.

3. **الموظفون:** يحتاجون موديل جديد `employee_model.dart` في `lib/models/`، وجدول جديد في SQLite (أو مفتاح JSON منفصل).

4. **المحاسبة:** الإيرادات والصرفيات تحتاج موديلات منفصلة عن الموجودة.

5. **الاجتماعات:** تحتاج موديل جديد للاجتماع + الحضور.

6. **التزم برفع كل تعديل إلى المستودع بعد كل مرحلة أو خطوة مهمة** دون تذكير.

7. **استخدم اللغة العربية** في واجهة المستخدم والتعليقات عند الحاجة.

---

## 🎯 الأولوية القادمة

### المرحلة 1 — لوحة القيادة (Dashboard) والإشعارات

**الملفات المطلوبة:**
- `lib/pages/dashboard_page.dart`
- `lib/services/notification_service.dart`
- `lib/models/notification_model.dart`

**المحتوى المطلوب:**
- إحصائيات حية: عدد الطلاب، الموظفين، المستخدمين
- إجمالي الإيرادات/الصرفيات/صافي الشهر
- آخر الإشعارات
- رسم بياني بسيط
- أيقونة جرس في أعلى التطبيق مع قائمة منسدلة
- إضافة صفحة الإشعارات إلى أقسام `school_shell_sections.dart`

**بعدها:**
- المرحلة 2: الموظفون (Employees)
