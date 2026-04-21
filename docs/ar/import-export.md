---
title: الاستيراد والتصدير
section: guide
order: 8
locale: ar
---

انسخ احتياطيًا إعدادات الأيقونات أو انقلها إلى جهاز Mac آخر.

## ما الذي يتم تصديره

يتضمن ملف التصدير (JSON):
- **الأسماء البديلة للتطبيقات** — تعيينات أسماء البحث المخصصة
- **مراجع الأيقونات المخزنة مؤقتًا** — التطبيقات التي لها أيقونات مخصصة وملفات الأيقونات المخزنة مؤقتًا

## التصدير

### من الواجهة الرسومية

انتقل إلى **Settings** > **Advanced** > **Configuration**، وانقر على **Export**.

### من سطر الأوامر

```bash
iconchanger export ~/Desktop/my-icons.json
```

## الاستيراد

### من الواجهة الرسومية

انتقل إلى **Settings** > **Advanced** > **Configuration**، وانقر على **Import**.

### من سطر الأوامر

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
الاستيراد **يضيف** عناصر جديدة فقط. لا يستبدل أو يزيل الأسماء البديلة أو الأيقونات المخزنة مؤقتًا الموجودة لديك.
:::

## التحقق من الصحة

قبل الاستيراد، يمكنك التحقق من صحة ملف الإعدادات:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

يتحقق هذا من بنية الملف دون إجراء أي تغييرات.

## الأتمتة مع ملفات Dotfiles

يمكنك أتمتة إعداد IconChanger كجزء من ملفات dotfiles الخاصة بك:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# تثبيت التطبيق
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# تثبيت أداة سطر الأوامر (من حزمة التطبيق)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# استيراد إعدادات الأيقونات
iconchanger import ~/dotfiles/iconchanger/config.json
```