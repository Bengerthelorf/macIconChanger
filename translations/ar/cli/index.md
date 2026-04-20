# تثبيت أداة سطر الأوامر

يتضمن IconChanger واجهة سطر أوامر للبرمجة النصية والأتمتة.

## التثبيت من التطبيق

1. افتح IconChanger > **Settings** > **Advanced**.
2. تحت **Command Line Tool**، انقر على **Install**.
3. أدخل كلمة مرور المسؤول.

أصبح أمر `iconchanger` متاحًا الآن في الطرفية.

## التثبيت اليدوي

إذا كنت تفضل التثبيت يدويًا (مثلًا في سكربت dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## التحقق من التثبيت

```bash
iconchanger --version
```

## إلغاء التثبيت

من التطبيق: **Settings** > **Advanced** > **Uninstall**.

أو يدويًا:

```bash
sudo rm /usr/local/bin/iconchanger
```

## الخطوات التالية

راجع [مرجع الأوامر](./commands) لجميع الأوامر المتاحة.
