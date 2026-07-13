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
