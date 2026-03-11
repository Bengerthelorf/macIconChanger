# Cài đặt CLI

IconChanger bao gồm giao diện dòng lệnh dành cho viết script và tự động hóa.

## Cài đặt từ ứng dụng

1. Mở IconChanger > **Settings** > **Advanced**.
2. Trong phần **Command Line Tool**, nhấn **Install**.
3. Nhập mật khẩu quản trị viên.

Lệnh `iconchanger` giờ đã sẵn sàng sử dụng trong terminal.

## Cài đặt thủ công

Nếu bạn muốn cài đặt thủ công (ví dụ: trong tập lệnh dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Xác minh cài đặt

```bash
iconchanger --version
```

## Gỡ cài đặt

Từ ứng dụng: **Settings** > **Advanced** > **Uninstall**.

Hoặc gỡ thủ công:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Bước tiếp theo

Xem [Tham chiếu lệnh](./commands) để biết tất cả các lệnh có sẵn.
