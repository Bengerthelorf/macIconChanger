---
title: Tham chiếu lệnh
section: cli
locale: vi
---

## Tổng quan

```
iconchanger <command> [options]
```

## Các lệnh

### `status`

Hiển thị trạng thái cấu hình hiện tại.

```bash
iconchanger status
```

Hiển thị:
- Số lượng bí danh ứng dụng đã cấu hình
- Số lượng biểu tượng đã lưu
- Trạng thái tập lệnh trợ giúp

---

### `list`

Liệt kê tất cả bí danh và biểu tượng đã lưu.

```bash
iconchanger list
```

Hiển thị bảng gồm tất cả bí danh đã cấu hình và tất cả các mục biểu tượng đã lưu.

---

### `set-icon`

Đặt biểu tượng tùy chỉnh cho một ứng dụng.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Tham số:**
- `app-path` — Đường dẫn đến ứng dụng (ví dụ: `/Applications/Safari.app`)
- `image-path` — Đường dẫn đến tệp hình ảnh biểu tượng (PNG, JPEG, ICNS, v.v.)

**Ví dụ:**

```bash
# Đặt biểu tượng tùy chỉnh cho Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Đường dẫn tương đối cũng hoạt động
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Xóa biểu tượng tùy chỉnh và khôi phục biểu tượng gốc.

```bash
iconchanger remove-icon <app-path>
```

**Ví dụ:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Khôi phục tất cả biểu tượng tùy chỉnh đã lưu. Hữu ích sau khi cập nhật hệ thống hoặc khi ứng dụng bị đặt lại biểu tượng.

```bash
iconchanger restore [options]
```

**Tùy chọn:**
- `--dry-run` — Xem trước những gì sẽ được khôi phục mà không thực hiện thay đổi
- `--verbose` — Hiển thị thông tin chi tiết cho từng biểu tượng
- `--force` — Khôi phục ngay cả khi biểu tượng dường như chưa thay đổi

**Ví dụ:**

```bash
# Khôi phục tất cả biểu tượng đã lưu
iconchanger restore

# Xem trước kết quả
iconchanger restore --dry-run --verbose

# Bắt buộc khôi phục tất cả
iconchanger restore --force
```

---

### `export`

Xuất bí danh và cấu hình biểu tượng đã lưu ra tệp JSON.

```bash
iconchanger export <output-path>
```

**Ví dụ:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Nhập tệp cấu hình.

```bash
iconchanger import <input-path>
```

Thao tác nhập chỉ thêm các mục mới — không bao giờ thay thế hoặc xóa các mục hiện có.

**Ví dụ:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Kiểm tra tính hợp lệ của tệp cấu hình trước khi nhập.

```bash
iconchanger validate <file-path>
```

Kiểm tra cấu trúc JSON, các trường bắt buộc và tính toàn vẹn dữ liệu mà không thực hiện thay đổi.

**Ví dụ:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Thoát khỏi squircle jail của macOS Tahoe bằng cách áp dụng lại biểu tượng đi kèm dưới dạng biểu tượng tùy chỉnh. Biểu tượng tùy chỉnh bỏ qua cơ chế ép squircle, giữ nguyên hình dạng biểu tượng gốc.

```bash
iconchanger escape-jail [app-path] [options]
```

**Tham số:**
- `app-path` — (Tùy chọn) Đường dẫn đến gói `.app` cụ thể. Nếu bỏ qua, xử lý tất cả ứng dụng trong `/Applications`.

**Tùy chọn:**
- `--dry-run` — Xem trước những gì sẽ được thực hiện mà không thay đổi
- `--verbose` — Hiển thị thông tin chi tiết

**Ví dụ:**

```bash
# Thoát jail cho tất cả ứng dụng trong /Applications
iconchanger escape-jail

# Xem trước kết quả
iconchanger escape-jail --dry-run --verbose

# Thoát jail cho một ứng dụng cụ thể
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Biểu tượng tùy chỉnh không hỗ trợ các chế độ biểu tượng Clear, Tinted hoặc Dark của macOS Tahoe. Chúng vẫn là hình ảnh bitmap tĩnh.
:::

---

### `completions`

Tạo tập lệnh hoàn thành lệnh cho shell.

```bash
iconchanger completions <shell>
```

**Tham số:**
- `shell` — Loại shell: `zsh`, `bash` hoặc `fish`

**Ví dụ:**

```bash
# Zsh (thêm vào ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (thêm vào ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```