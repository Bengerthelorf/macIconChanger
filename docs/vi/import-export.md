---
title: Nhập & Xuất
section: guide
order: 8
locale: vi
---

Sao lưu cấu hình biểu tượng của bạn hoặc chuyển sang Mac khác.

## Nội dung được xuất

Tệp xuất (JSON) bao gồm:
- **Bí danh ứng dụng** — ánh xạ tên tìm kiếm tùy chỉnh của bạn
- **Tham chiếu biểu tượng đã lưu** — ứng dụng nào có biểu tượng tùy chỉnh và các tệp biểu tượng đã lưu

## Xuất

### Từ giao diện đồ họa

Đi tới **Settings** > **Advanced** > **Configuration**, và nhấn **Export**.

### Từ dòng lệnh

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Nhập

### Từ giao diện đồ họa

Đi tới **Settings** > **Advanced** > **Configuration**, và nhấn **Import**.

### Từ dòng lệnh

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Thao tác nhập chỉ **thêm** các mục mới. Nó không bao giờ thay thế hoặc xóa bí danh hay biểu tượng đã lưu hiện có.
:::

## Kiểm tra tính hợp lệ

Trước khi nhập, bạn có thể kiểm tra tệp cấu hình:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Lệnh này kiểm tra cấu trúc tệp mà không thực hiện bất kỳ thay đổi nào.

## Tự động hóa với Dotfiles

Bạn có thể tự động hóa thiết lập IconChanger như một phần của dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Cài đặt ứng dụng
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Cài đặt CLI (từ gói ứng dụng)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Nhập cấu hình biểu tượng
iconchanger import ~/dotfiles/iconchanger/config.json
```