---
title: Khóa API
section: guide
order: 7
locale: vi
---

Cần có khóa API từ [macosicons.com](https://macosicons.com/) để tìm kiếm biểu tượng trực tuyến. Nếu không có khóa, bạn vẫn có thể sử dụng tệp hình ảnh trên máy.

## Lấy khóa API

1. Truy cập [macosicons.com](https://macosicons.com/) và tạo tài khoản.
2. Yêu cầu khóa API từ phần cài đặt tài khoản.
3. Sao chép khóa.

![Cách lấy khóa API](/images/api-key.png)

## Nhập khóa

1. Mở IconChanger.
2. Đi tới **Settings** > **Advanced**.
3. Dán khóa API vào trường **API Key**.
4. Nhấn **Test Connection** để kiểm tra kết nối.

![Cài đặt khóa API](/images/api-key-settings.png)

## Sử dụng khi không có khóa API

Bạn vẫn có thể thay đổi biểu tượng ứng dụng mà không cần khóa API bằng cách:

- Sử dụng tệp hình ảnh trên máy (nhấn **Choose from the Local** hoặc kéo & thả hình ảnh)
- Sử dụng biểu tượng đi kèm trong ứng dụng (hiển thị trong phần "Local")

## Cai dat API nang cao

Trong **Settings** > **Advanced** > **API Settings**, ban co the tinh chinh hanh vi API:

| Cai dat | Mac dinh | Mo ta |
|---|---|---|
| **Retry Count** | 0 (khong thu lai) | So lan thu lai yeu cau that bai (0–3) |
| **Timeout** | 15 giay | Thoi gian cho cho moi lan thu |
| **Monthly Limit** | 50 | So truy van API toi da moi thang |

Bo dem **Monthly Usage** hien thi muc su dung hien tai. No tu dong dat lai vao ngay 1 hang thang hoac ban co the dat lai thu cong.

### Bo nho dem tim kiem bieu tuong

Bat **Cache API Results** de luu ket qua tim kiem vao dia. Ket qua duoc luu trong bo nho dem van duoc giu lai sau khi khoi dong lai ung dung, giam thieu viec su dung API. Su dung nut lam moi khi duyet bieu tuong de lay ket qua moi nhat.

## Khắc phục sự cố

Nếu kiểm tra API thất bại:
- Kiểm tra khóa của bạn có đúng không (không có khoảng trắng thừa)
- Xác minh kết nối internet
- API của macosicons.com có thể tạm thời không khả dụng