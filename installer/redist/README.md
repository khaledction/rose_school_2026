# VC++ Redistributable bootstrap

هذا المجلد يجب أن يحتوي عند البناء على:

```text
vc_redist.x64.exe
```

## كيف يُحضَّر؟
تلقائيًا عبر:

```powershell
.\scripts\build_release_installer.ps1
```

السكربت ينزّل الملف من Microsoft:

```text
https://aka.ms/vs/17/release/vc_redist.x64.exe
```

## لماذا؟
ليثبّت `RoseSchoolSetup.exe` مكتبات:

- `MSVCP140.dll`
- `VCRUNTIME140.dll`
- `VCRUNTIME140_1.dll`

تلقائيًا إذا كانت ناقصة على الجهاز الهدف.

> لا ترفع ملف `.exe` الكبير إلى Git (مدرج في `.gitignore`).
