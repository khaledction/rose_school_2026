# ملخص الجلسة للمحادثة القادمة

> تاريخ التحديث: **2026-07-11**
>
> المشروع: `rose_school_2026`
>
> المستودع: https://github.com/khaledction/rose_school_2026
>
> الفرع: `main`
>
> آخر commit محلي: `bc92990` — fix: add one installment per click and stretch report grades vertically
>
> المجلد المحلي ويندوز: `C:\Users\khaledction\Desktop\new-rose`

---

## ⚠️ تنبيه أمني
إذا ظهر GitHub token في محادثة: **ألغه فورًا** من GitHub Settings → Tokens وأنشئ جديداً عند الحاجة.
**لا تلصق أي token في الشات.**

---

## 🖥️ تشغيل / مزامنة Desktop (مهم جدًا)

Arena لا تستطيع الكتابة مباشرة على Desktop. يجب مزامنة الملفات يدويًا ثم:

```powershell
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
flutter clean
flutter pub get
flutter run -d windows
```

> إذا فشل push من Arena: ارفع من جهاز ويندوز بعد نسخ الملفات أو بعد استلام bundle/zip.

### ملفات حرجة يجب أن تكون محدّثة على Desktop
- `lib/pages/school_shell_page.dart`
- `lib/pages/school_shell_sections.dart`
- `NEXT_CHAT_SUMMARY.md`
- `README.md`

حزمة نسخ سريعة (إن وُجدت): `UPDATE_TO_DESKTOP.zip`

---

## 📍 أين وصلنا؟ (ملخص تنفيذي)

تطبيق Flutter لويندوز (عربي/RTL) لإدارة **Rose School 2026** — محلي + SQLite.

### هذه الجلسة (2026-07-11) ركّزت على:
1. إصلاح crash Flutter: `_dependents.isEmpty`
2. إعادة تصميم **الجلاء المدرسي** وفق النماذج الرسمية (1-4 / 5-6 / 7-9 / ثانوي)
3. جلاء A4 عمودي + ترتيب أعمدة عربي صحيح
4. تحسين UI/UX للجلاء (شعار + اسم مدرسة + بدون تسمية مرحلة في الترويسة)
5. ملء ورقة A4: صفوف الدرجات ممدودة، والفراغ الأبيض **تحت الأسماء فقط**
6. محاسبة: أزرار أقساط برموز + إضافة **قسط واحد لكل ضغطة** بقيمة الإدارة (غير قابلة للتعديل)

---

## ✅ ما تم إنجازه بالتفصيل

### A) إصلاح crash
- الخطأ: `Failed assertion: '_dependents.isEmpty': is not true`
- السبب: `Navigator.pop` من داخل `DropdownButton.onChanged` في إدارة المواد
- الحل: أزرار بدل dropdown للإجراءات + تأخير pop + harden capture/print

### B) نماذج الجلاء حسب الحلقة/المرحلة
| النموذج | الصفوف | ملاحظات العلامات |
|---------|--------|------------------|
| الحلقة الأولى | 1-4 | مواد رسمية + دنيا 41 / عظمى 100 / مجموع 451-1100 |
| الحلقة الثانية | 5-6 | سلوك + مهارات / 460-1100 |
| إعدادي | 7-9 | عربية/أجنبية/معلوماتية… / 1780-4200 |
| ثانوي أدبي | 10-12 أدبي | تاريخ/جغرافيا/فلسفة… |
| ثانوي علمي | 10-12 علمي | رياضيات/فيزياء/كيمياء… |

- تبديل تلقائي حسب صف الطالب
- قائمة يدوية: **نموذج الجلاء / الحلقة أو المرحلة**
- المواد الرسمية فقط (بدون خلط مواد قديمة/مخصصة في ورقة الجلاء)

### C) شكل الجلاء / الطباعة
- A4 **عمودي**
- هوامش تقريبية: 10مم يمين/يسار/أعلى، هامش أسفل أكبر
- اتجاه بصري: **المادة يمين** … **المحصلة يسار**
  - ملاحظة تقنية: `Table` في Flutter LTR دائمًا؛ الأعمدة مرتبة accordingly
- الشعار + **مدرسة روز التعليمية** في الترويسة (يسار بصري)
- **لا** تُعرض تسمية المرحلة داخل ورقة الجلاء
- العمليات: محصلة فصل = (أعمال+امتحان)/2 ، نهائية = (ف1+ف2)/2
- منع تجاوز العلامة العظمى لكل مادة
- المجموع + النسبة المئوية + ناجح/راسب
- الأسماء أسفل الجلاء: مشرف القسم / المدير / الخاتم / المشرف العام
- صفوف الدرجات تتمدد لملء الصفحة؛ الفراغ الأبيض تحت التوقيعات فقط

### D) المحاسبة — الأقساط
أزرار:
- **💵 قسط عادي**
- **💵🚌 قسط مع مواصلات**
- **💵🚌🎁 قسط مع منحة مواصلات**

سلوك صحيح حاليًا:
- القيمة من إعدادات الإدارة (**قراءة فقط**)
- **كل ضغطة تضيف قسطًا واحدًا فقط**
- يظهر: المضاف / المتبقي / رقم القسط `n/max`
- زر **إضافة قسط n/max** + **إلغاء**
- لا يمكن تعديل قيمة القسط من المحاسبة
- الحد الأقصى = عدد الأقساط في الإدارة

### E) تنظيف/توثيق
- تنظيف PdfPageFormat للجلاء A4
- حماية صفحة الامتحانات إذا لا يوجد طلاب
- تحديث README + هذا الملخص

---

## 📂 ملفات محورية

| ملف | دور |
|-----|-----|
| `lib/main.dart` | دخول التطبيق RTL → SchoolShellPage |
| `lib/pages/school_shell_page.dart` | هيكل/تنقل/DB/طباعة PDF/state (`_examCycleOverride`, A4 format) |
| `lib/pages/school_shell_sections.dart` | أقسام الواجهة + الجلاء + محاسبة الأقساط |
| `lib/services/school_database_service.dart` | SQLite |
| `lib/models/school_models.dart` | نماذج البيانات |
| `NEXT_CHAT_SUMMARY.md` | **المرجع الحي** لهذه الحالة |

---

## 🧭 خريطة التنقل الحالية (مختصر)

### الإدارة
- 🏛️ الإدارة (موحّد)
- 📁 مركز البيانات المحلي
- 🔍 مراجعة الموظفين
- الهوية والاعتماد + إعدادات الأقساط/المواصلات

### أمانة السر
- طلاب / استمارة / حضور / وثائق / بطاقة / backup
- اجتماعات ومراسلات أولياء الأمور
- النقل المدرسي

### الامتحانات
- 📚 الدرجات والجلاء المدرسي (حلقات + محرر درجات + معاينة/طباعة)
- 📊 النتائج والمعدلات

### المحاسبة
- لوحة المحاسبة
- أزرار الأقساط الثلاثة + دفعة + تبرعات + مساعدات
- الإيرادات والصرفيات

---

## 🔴 فجوات معروفة / أولوية قادمة

### P0
1. التأكد أن Desktop = `origin/main` بعد push (اختبار يدوي ويندوز).
2. اختبار سلسلة الأقساط: 1 ثم 2 ثم 3… حتى max، وعدم إضافة دفعة واحدة لكل السلسلة.
3. اختبار جلاء 1-4 / 5-6 / 7-9 / ثانوي: مواد + عظمى/دنيا + ملء A4.

### P1
4. ربط `AdminPasswordDialog` فعليًا بـ backup/restore/export.
5. أزرار Export من مركز البيانات → `ExportService`.
6. Dark Mode مدمج فعليًا في `main.dart`.
7. ZIP احتياطي حقيقي.

### P2
8. جداول علامات ثانوي أدق إن توفر نموذج رسمي.
9. تحسينات UI عامة خارج الجلاء/المحاسبة.
10. منع تكرار إضافة نفس رقم القسط عند التزامن/إعادة فتح سريعة.

---

## 🧪 سيناريوهات اختبار سريعة للغد

1. **Crash**: إدارة المواد (إضافة/تعديل/حذف) بدون شاشة حمراء.
2. **جلاء صف 4**: مواد أنشطة/مهارات… دنيا 41.
3. **جلاء صف 6**: سلوك + مهارات.
4. **جلاء صف 8**: إعدادي 4200/1780.
5. **قائمة النموذج اليدوية** تبدّل المواد فورًا.
6. **طباعة/معاينة** A4 عمودي.
7. **محاسبة**: ضغطة واحدة → قسط واحد؛ المتبقي ينقص؛ القيمة ثابتة.

---

## 📦 Commits هذه الجلسة (محليًا)

```
bc92990 fix: add one installment per click and stretch report grades vertically
7d3ec38 feat: split admin installments by count and refine report footer spacing
cea65cc feat: fill A4 report rows and lock accounting installment presets
502f3e2 fix: correct exam report column order for Arabic RTL paper layout
0967980 fix: improve exam report RTL layout and header readability
15b3dcf chore: clean exam report layout and document grade-cycle sync
c080baf feat: switch exam report subjects by student grade cycle
9d95f1b feat: force exam reports to A4 portrait with print margins
5b4a5c5 feat: add official grades 1-4 exam subjects and mark scale
f407e33 feat: add official grade 5-6 exam subjects and mark scale
d5fc976 fix: use official 7-9 mark scale for max/min grades
92f05e6 feat: redesign exam report card to match official school form
ddc9dc1 fix: prevent _dependents.isEmpty crash in grades/exam reports
```

---

## ▶️ جملة بدء سريعة للجلسة القادمة

> أكمل `rose_school_2026` من `NEXT_CHAT_SUMMARY.md` (2026-07-11).  
> Desktop: `C:\Users\khaledction\Desktop\new-rose`.  
> ابدأ بـ `git reset --hard origin/main` ثم اختبار الجلاء حسب الحلقة + الأقساط (قسط واحد لكل ضغطة).

