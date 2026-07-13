# Rose School 2026

نظام إدارة مدرسي محلي لويندوز — Flutter + SQLite (عربي / RTL).

## التشغيل (تطوير)

```cmd
cd C:\Users\khaledction\Desktop\new-rose
git fetch origin
git reset --hard origin/main
git clean -fd
flutter clean
flutter pub get
flutter run -d windows
```

## المستودع

https://github.com/khaledction/rose_school_2026

## الوثائق الحية

| ملف | الغرض |
|-----|--------|
| `NEXT_CHAT_SUMMARY.md` | المرجع الحي — آخر حالة + الأولوية التالية |
| `README.md` | تشغيل سريع + بناء تنفيذي |

## بناء ملف تنفيذي لويندوز (Release)

على جهاز فيه Flutter + Visual Studio (Desktop development with C++):

```cmd
cd C:\Users\khaledction\Desktop\new-rose
flutter clean
flutter pub get
flutter build windows --release
```

المخرجات:

```text
build\windows\x64\runner\Release\
```

انسخ مجلد `Release` كاملًا إلى الجهاز الآخر وشغّل:

```text
rose_school.exe
```

> مهم: انسخ المجلد كاملًا (لا exe وحده) لأنه يحتوي DLLs وdata.

## ملاحظات الحجم

- التطبيق موجّه لويندوز أساسًا.
- مجلدات `android/ios/macos/linux/web` باقية كدعم Flutter متعدد المنصات، ويمكن حذفها لاحقًا إذا أردت Windows-only صارم.
