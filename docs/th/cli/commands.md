---
title: คู่มืออ้างอิงคำสั่ง
section: cli
locale: th
---

## ภาพรวม

```
iconchanger <command> [options]
```

## คำสั่ง

### `status`

แสดงสถานะการตั้งค่าปัจจุบัน

```bash
iconchanger status
```

แสดง:
- จำนวนชื่อแทนของแอปที่กำหนดไว้
- จำนวนไอคอนที่แคชไว้
- สถานะ helper script

---

### `list`

แสดงรายการชื่อแทนและไอคอนที่แคชไว้ทั้งหมด

```bash
iconchanger list
```

แสดงตารางชื่อแทนทั้งหมดที่กำหนดไว้และรายการไอคอนที่แคชไว้ทั้งหมด

---

### `set-icon`

ตั้งค่าไอคอนกำหนดเองสำหรับแอปพลิเคชัน

```bash
iconchanger set-icon <app-path> <image-path>
```

**อาร์กิวเมนต์:**
- `app-path` — พาธไปยังแอปพลิเคชัน (เช่น `/Applications/Safari.app`)
- `image-path` — พาธไปยังไฟล์ภาพไอคอน (PNG, JPEG, ICNS ฯลฯ)

**ตัวอย่าง:**

```bash
# ตั้งไอคอน Safari กำหนดเอง
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# ใช้พาธแบบสัมพัทธ์ได้เช่นกัน
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

ลบไอคอนกำหนดเองและกู้คืนไอคอนเดิม

```bash
iconchanger remove-icon <app-path>
```

**ตัวอย่าง:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

กู้คืนไอคอนกำหนดเองที่แคชไว้ทั้งหมด มีประโยชน์หลังจากอัปเดตระบบหรือเมื่อแอปรีเซ็ตไอคอน

```bash
iconchanger restore [options]
```

**ตัวเลือก:**
- `--dry-run` — ดูตัวอย่างสิ่งที่จะถูกกู้คืนโดยไม่ทำการเปลี่ยนแปลง
- `--verbose` — แสดงรายละเอียดผลลัพธ์สำหรับแต่ละไอคอน
- `--force` — กู้คืนแม้ว่าไอคอนจะดูเหมือนไม่เปลี่ยนแปลง

**ตัวอย่าง:**

```bash
# กู้คืนไอคอนที่แคชไว้ทั้งหมด
iconchanger restore

# ดูตัวอย่างสิ่งที่จะเกิดขึ้น
iconchanger restore --dry-run --verbose

# บังคับกู้คืนทุกอย่าง
iconchanger restore --force
```

---

### `export`

ส่งออกชื่อแทนและการตั้งค่าไอคอนที่แคชไว้เป็นไฟล์ JSON

```bash
iconchanger export <output-path>
```

**ตัวอย่าง:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

นำเข้าไฟล์การตั้งค่า

```bash
iconchanger import <input-path>
```

การนำเข้าจะเพิ่มรายการใหม่เท่านั้น จะไม่แทนที่หรือลบรายการที่มีอยู่

**ตัวอย่าง:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

ตรวจสอบความถูกต้องของไฟล์การตั้งค่าก่อนนำเข้า

```bash
iconchanger validate <file-path>
```

ตรวจสอบโครงสร้าง JSON, ฟิลด์ที่จำเป็น และความสมบูรณ์ของข้อมูลโดยไม่ทำการเปลี่ยนแปลง

**ตัวอย่าง:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

หลุดจาก squircle jail ของ macOS Tahoe โดยการนำไอคอนที่มาพร้อมแอปมาใช้ใหม่เป็นไอคอนกำหนดเอง ไอคอนกำหนดเองจะข้ามการบังคับ squircle ทำให้รูปร่างไอคอนเดิมยังคงอยู่

```bash
iconchanger escape-jail [app-path] [options]
```

**อาร์กิวเมนต์:**
- `app-path` — (ไม่บังคับ) พาธไปยัง `.app` bundle เฉพาะ หากไม่ระบุ จะประมวลผลแอปทั้งหมดใน `/Applications`

**ตัวเลือก:**
- `--dry-run` — ดูตัวอย่างสิ่งที่จะทำโดยไม่ทำการเปลี่ยนแปลง
- `--verbose` — แสดงรายละเอียดผลลัพธ์

**ตัวอย่าง:**

```bash
# หลุดจาก jail สำหรับแอปทั้งหมดใน /Applications
iconchanger escape-jail

# ดูตัวอย่างสิ่งที่จะเกิดขึ้น
iconchanger escape-jail --dry-run --verbose

# หลุดจาก jail สำหรับแอปเฉพาะ
iconchanger escape-jail /Applications/Safari.app
```

::: warning
ไอคอนกำหนดเองไม่รองรับโหมดไอคอน Clear, Tinted หรือ Dark ของ macOS Tahoe จะคงเป็นภาพบิตแมปแบบนิ่ง
:::

---

### `completions`

สร้างสคริปต์ shell completion สำหรับการเติมคำสั่งอัตโนมัติด้วยปุ่ม Tab

```bash
iconchanger completions <shell>
```

**อาร์กิวเมนต์:**
- `shell` — ประเภทของ shell: `zsh`, `bash` หรือ `fish`

**ตัวอย่าง:**

```bash
# Zsh (เพิ่มใน ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (เพิ่มใน ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```