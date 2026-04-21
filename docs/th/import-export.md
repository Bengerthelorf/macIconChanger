---
title: นำเข้าและส่งออก
section: guide
order: 8
locale: th
---

สำรองการตั้งค่าไอคอนของคุณหรือโอนไปยัง Mac เครื่องอื่น

## สิ่งที่ถูกส่งออก

ไฟล์ส่งออก (JSON) ประกอบด้วย:
- **ชื่อแทนของแอป** — การกำหนดชื่อค้นหากำหนดเองของคุณ
- **ข้อมูลอ้างอิงไอคอนที่แคชไว้** — แอปใดมีไอคอนกำหนดเองและไฟล์ไอคอนที่แคชไว้

## การส่งออก

### จาก GUI

ไปที่ **Settings** > **Advanced** > **Configuration** แล้วคลิก **Export**

### จาก CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## การนำเข้า

### จาก GUI

ไปที่ **Settings** > **Advanced** > **Configuration** แล้วคลิก **Import**

### จาก CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
การนำเข้าจะ**เพิ่ม**รายการใหม่เท่านั้น จะไม่แทนที่หรือลบชื่อแทนหรือไอคอนที่แคชไว้ที่มีอยู่
:::

## การตรวจสอบความถูกต้อง

ก่อนนำเข้า คุณสามารถตรวจสอบความถูกต้องของไฟล์การตั้งค่า:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

วิธีนี้จะตรวจสอบโครงสร้างไฟล์โดยไม่ทำการเปลี่ยนแปลงใดๆ

## ระบบอัตโนมัติกับ Dotfiles

คุณสามารถทำให้การตั้งค่า IconChanger เป็นส่วนหนึ่งของ dotfiles ได้โดยอัตโนมัติ:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# ติดตั้งแอป
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# ติดตั้ง CLI (จาก app bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# นำเข้าการตั้งค่าไอคอนของคุณ
iconchanger import ~/dotfiles/iconchanger/config.json
```