# Bắt đầu nhanh

## Yêu cầu hệ thống

- macOS 13.0 (Ventura) trở lên
- Quyền quản trị viên (để thiết lập ban đầu và thay đổi biểu tượng)

## Cài đặt

### Homebrew (Khuyến nghị)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Tải xuống thủ công

1. Tải tệp DMG mới nhất từ [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Mở tệp DMG và kéo **IconChanger** vào thư mục Ứng dụng.
3. Khởi chạy IconChanger.

## Lần khởi chạy đầu tiên

Khi khởi chạy lần đầu, IconChanger sẽ yêu cầu bạn hoàn tất thiết lập quyền một lần. Điều này cần thiết để ứng dụng có thể thay đổi biểu tượng.

![Màn hình thiết lập lần đầu](/images/setup-prompt.png)

Nhấn nút thiết lập và nhập mật khẩu quản trị viên. IconChanger sẽ tự động cấu hình các quyền cần thiết (quy tắc sudoers cho tập lệnh trợ giúp).

::: tip
Nếu thiết lập tự động thất bại, hãy xem [Thiết lập ban đầu](./setup) để thực hiện thủ công.
:::

## Thay đổi biểu tượng đầu tiên

1. Chọn một ứng dụng từ thanh bên.
2. Duyệt biểu tượng từ [macOSicons.com](https://macosicons.com/) hoặc chọn tệp hình ảnh trên máy.
3. Nhấn vào biểu tượng để áp dụng.

![Giao diện chính](/images/main-interface.png)

Vậy là xong! Biểu tượng ứng dụng sẽ được thay đổi ngay lập tức.

## Bước tiếp theo

- [Thiết lập khóa API](./api-key) để tìm kiếm biểu tượng trực tuyến
- [Tìm hiểu về bí danh ứng dụng](./aliases) để có kết quả tìm kiếm tốt hơn
- [Cấu hình dịch vụ nền](./background-service) để tự động khôi phục biểu tượng
- [Cài đặt công cụ CLI](/vi/cli/) để truy cập từ dòng lệnh
