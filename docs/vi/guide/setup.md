# Thiết lập ban đầu

IconChanger cần quyền quản trị viên để thay đổi biểu tượng ứng dụng. Khi khởi chạy lần đầu, ứng dụng sẽ đề xuất thiết lập tự động.

## Thiết lập tự động (Khuyến nghị)

1. Khởi chạy IconChanger.
2. Nhấn nút **Setup** khi được yêu cầu.
3. Nhập mật khẩu quản trị viên.

Ứng dụng sẽ tạo tập lệnh trợ giúp tại `~/.iconchanger/helper.sh` và cấu hình quy tắc sudoers để có thể chạy mà không cần nhập mật khẩu mỗi lần.

## Thiết lập thủ công

Nếu thiết lập tự động thất bại, bạn có thể cấu hình thủ công:

1. Mở Terminal.
2. Chạy lệnh:

```bash
sudo visudo
```

3. Thêm dòng sau vào cuối tệp:

```
ALL ALL=(ALL) NOPASSWD: /Users/<your-username>/.iconchanger/helper.sh
```

Thay `<your-username>` bằng tên người dùng macOS thực tế của bạn.

## Xác minh thiết lập

Sau khi thiết lập, ứng dụng sẽ hiển thị danh sách ứng dụng ở thanh bên. Nếu bạn vẫn thấy màn hình thiết lập, cấu hình có thể chưa được áp dụng đúng.

Bạn có thể xác minh thiết lập từ thanh menu: nhấn vào menu **...** và chọn **Check Setup Status**.

## Hạn chế

Các ứng dụng được bảo vệ bởi System Integrity Protection (SIP) của macOS không thể thay đổi biểu tượng. Đây là hạn chế của macOS và không thể bỏ qua.

Các ứng dụng được SIP bảo vệ phổ biến bao gồm:
- Finder
- Safari (trên một số phiên bản macOS)
- Các ứng dụng hệ thống khác trong `/System/Applications/`
