# Thiết lập ban đầu

IconChanger cần quyền quản trị viên để thay đổi biểu tượng ứng dụng. Khi khởi chạy lần đầu, ứng dụng sẽ đề xuất thiết lập tự động.

## Thiết lập tự động (Khuyến nghị)

1. Khởi chạy IconChanger.
2. Nhấn nút **Setup** khi được yêu cầu.
3. Nhập mật khẩu quản trị viên.

Ứng dụng sẽ cài đặt tập lệnh trợ giúp vào `/usr/local/lib/iconchanger/` (thuộc sở hữu của `root:wheel`) và cấu hình quy tắc sudoers giới hạn để có thể chạy mà không cần nhập mật khẩu mỗi lần.

## Bảo mật

IconChanger sử dụng nhiều biện pháp bảo mật để bảo vệ đường ống trợ giúp:

- **Thư mục trợ giúp thuộc sở hữu root** — Các tệp trợ giúp nằm trong `/usr/local/lib/iconchanger/` với quyền sở hữu `root:wheel`, ngăn chặn việc sửa đổi trái phép.
- **Xác minh tính toàn vẹn SHA-256** — Tập lệnh trợ giúp được xác minh so với hash đã biết trước mỗi lần thực thi.
- **Quy tắc sudoers giới hạn** — Mục sudoers chỉ cấp quyền truy cập không cần mật khẩu cho tập lệnh trợ giúp cụ thể, không phải các lệnh tùy ý.
- **Nhật ký kiểm toán** — Tất cả các thao tác biểu tượng được ghi lại kèm dấu thời gian để truy vết.

## Thiết lập thủ công

Nếu thiết lập tự động thất bại, bạn có thể cấu hình thủ công:

1. Mở Terminal.
2. Chạy lệnh:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Thêm dòng sau:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Xác minh thiết lập

Sau khi thiết lập, ứng dụng sẽ hiển thị danh sách ứng dụng ở thanh bên. Nếu bạn vẫn thấy màn hình thiết lập, cấu hình có thể chưa được áp dụng đúng.

Bạn có thể xác minh thiết lập từ thanh menu: nhấn vào menu **...** và chọn **Check Setup Status**.

## Hạn chế

Các ứng dụng được bảo vệ bởi System Integrity Protection (SIP) của macOS không thể thay đổi biểu tượng. Đây là hạn chế của macOS và không thể bỏ qua.

Các ứng dụng được SIP bảo vệ phổ biến bao gồm:
- Finder
- Safari (trên một số phiên bản macOS)
- Các ứng dụng hệ thống khác trong `/System/Applications/`
