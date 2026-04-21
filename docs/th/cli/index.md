---
title: การติดตั้ง CLI
section: cli
locale: th
---

IconChanger มีอินเทอร์เฟซบรรทัดคำสั่งสำหรับการเขียนสคริปต์และระบบอัตโนมัติ

## ติดตั้งจากแอป

1. เปิด IconChanger > **Settings** > **Advanced**
2. ภายใต้ **Command Line Tool** คลิก **Install**
3. ป้อนรหัสผ่านผู้ดูแลระบบ

คำสั่ง `iconchanger` พร้อมใช้งานใน Terminal ของคุณแล้ว

## ติดตั้งด้วยตนเอง

หากคุณต้องการติดตั้งด้วยตนเอง (เช่น ในสคริปต์ dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## ตรวจสอบการติดตั้ง

```bash
iconchanger --version
```

## ถอนการติดตั้ง

จากแอป: **Settings** > **Advanced** > **Uninstall**

หรือถอนการติดตั้งด้วยตนเอง:

```bash
sudo rm /usr/local/bin/iconchanger
```

## ขั้นตอนถัดไป

ดู[คู่มืออ้างอิงคำสั่ง](./commands)สำหรับคำสั่งทั้งหมดที่ใช้ได้