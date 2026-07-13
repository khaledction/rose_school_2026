# Rose School 2026

نظام إدارة مدرسي محلي لويندوز — Flutter + SQLite (عربي / RTL).

## التشغيل

```cmd
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
flutter clean
flutter pub get
flutter run -d windows
```

> بعد أي `push` من Arena: نفّذ الأوامر أعلاه على Desktop حتى يصبح المجلد المحلي = `origin/main`.

## المستودع

https://github.com/khaledction/rose_school_2026

## الوثائق

| ملف | الغرض |
|-----|--------|
| `NEXT_CHAT_SUMMARY.md` | **المرجع الحي** — آخر حالة + الأولوية التالية |
| `ROSE_SCHOOL_2026_FULL_PLAN.md` | الخطة الكاملة |
| `WINDOWS_FULL_IMPLEMENTATION_PLAN.md` | خطة ويندوز |
| `WINDOWS_TEST_CHECKLIST.md` | اختبارات يدوية |

## آخر حالة (2026-07-13) — تنظيف ومزامنة

- حذف نسخ `.bak` المكررة من `lib/pages/`
- حذف مجلد `tmp_updates/` (نسخ قديمة أقدم من `lib/pages`)
- حذف `lib/pages/README.md` و`lib/pages/NEXT_CHAT_SUMMARY.md` (مكررات)
- حذف `PHASE_2_VISUAL_SHOWCASE.html` (نسخة مطابقة لـ `FULL_PROJECT_DEMO.html`)
- تعزيز `.gitignore` ضد النسخ المؤقتة والأسرار

## الجلاء المدرسي (2026-07-11 / 12)

- A4 عمودي مع هوامش طباعة رسمية.
- النماذج حسب الحلقة/المرحلة: 1-4 / 5-6 / 7-9 / ثانوي أدبي–علمي.
- رأس الجدول بالنموذج الرسمي + مدير المدرسة فوق مشرف القسم.
- بطاقات إنجاز المواد + ذكور/إناث في الشريط العلوي.

## المحاسبة

- أزرار الأقساط: 💵 / 💵🚌 / 💵🚌🎁
- **قسط واحد لكل ضغطة** بقيمة الإدارة (قراءة فقط).

## أمان

- لا تلصق GitHub token في المحادثات.
- إن ظهر token: ألغِه فورًا من GitHub Settings → Developer settings → Personal access tokens.
