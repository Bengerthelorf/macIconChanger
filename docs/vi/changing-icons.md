---
title: Thay đổi biểu tượng
section: guide
order: 3
locale: vi
---

## Sử dụng giao diện đồ họa

### Tìm kiếm trực tuyến

1. Chọn một ứng dụng từ thanh bên.
2. Duyệt các biểu tượng từ [macOSicons.com](https://macosicons.com/) trong khu vực chính.
3. Sử dụng menu **Style** để lọc theo phong cách (ví dụ: Liquid Glass).
4. Nhấn vào biểu tượng để áp dụng.

![Tìm kiếm biểu tượng](/images/search-icons.png)

### Chọn tệp trên máy

Nhấn **Choose from the Local** (hoặc nhấn <kbd>Cmd</kbd>+<kbd>O</kbd>) để mở hộp thoại chọn tệp. Các định dạng được hỗ trợ: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Kéo & Thả

Kéo tệp hình ảnh từ Finder trực tiếp vào khu vực biểu tượng của ứng dụng. Vùng đánh dấu màu xanh sẽ xuất hiện để xác nhận khu vực thả.

![Kéo và thả](/images/drag-drop.png)

### Khôi phục biểu tượng mặc định

Để khôi phục biểu tượng gốc của ứng dụng:
- Nhấn nút **Restore Default** (hoặc nhấn <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Hoặc nhấn chuột phải vào ứng dụng ở thanh bên và chọn **Restore Default Icon**

## Thoát khỏi Squircle Jail (macOS Tahoe)

macOS 26 Tahoe buộc tất cả biểu tượng ứng dụng vào hình squircle (hình vuông bo tròn). Những ứng dụng có biểu tượng không tuân thủ sẽ bị thu nhỏ và đặt trên nền squircle màu xám.

IconChanger có thể khắc phục điều này bằng cách áp dụng lại biểu tượng đi kèm của ứng dụng dưới dạng biểu tượng tùy chỉnh, giúp bỏ qua cơ chế ép squircle của macOS.

### Từng ứng dụng

Nhấn chuột phải vào ứng dụng ở thanh bên và chọn **Escape Squircle Jail**.

### Tất cả ứng dụng cùng lúc

Nhấn vào menu **...** trên thanh công cụ và chọn **Escape Squircle Jail (All Apps)**. Thao tác này sẽ xử lý tất cả ứng dụng chưa có biểu tượng tùy chỉnh.

::: tip
Biểu tượng tùy chỉnh được đặt theo cách này **không** hỗ trợ các chế độ biểu tượng Clear, Tinted hoặc Dark của macOS Tahoe — chúng vẫn là hình ảnh tĩnh. Đây là hạn chế của hệ thống.
:::

::: info
Dịch vụ nền sẽ tự động áp dụng lại biểu tượng sau khi cập nhật ứng dụng, giúp chúng không bị đưa trở lại squircle jail.
:::

## Biểu tượng thư mục

Bạn cũng có thể tùy chỉnh biểu tượng thư mục. Thêm thư mục qua **Settings** > **Application** > **Application Folders**, hoặc nhấn nút **+** trong phần thư mục của thanh bên.

Sau khi được thêm, thư mục sẽ xuất hiện trong thanh bên giống như ứng dụng. Bạn có thể tìm kiếm biểu tượng, kéo & thả hình ảnh hoặc chọn tệp trên máy -- cùng quy trình như khi thay đổi biểu tượng ứng dụng.

::: tip
Tên thư mục như "go" hoặc "Downloads" có thể không cho kết quả tìm kiếm tốt trên macOSicons.com. Sử dụng [bí danh](./aliases) để đặt tên dễ tìm kiếm hơn (ví dụ: đặt bí danh "Documents" thành "folder").
:::

## Bộ nhớ đệm biểu tượng

Khi bạn áp dụng biểu tượng tùy chỉnh, nó sẽ tự động được lưu vào bộ nhớ đệm. Điều này có nghĩa là:
- Biểu tượng tùy chỉnh có thể được khôi phục sau khi cập nhật ứng dụng
- Dịch vụ nền có thể áp dụng lại chúng theo lịch trình
- Bạn có thể xuất và nhập cấu hình biểu tượng

Quản lý biểu tượng đã lưu tại **Settings** > **Icon Cache**.

## Phím tắt

| Phím tắt | Hành động |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Chọn tệp biểu tượng trên máy |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Khôi phục biểu tượng mặc định |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Làm mới hiển thị biểu tượng |

## Mẹo

- Nếu không tìm thấy biểu tượng cho ứng dụng, hãy thử [đặt bí danh](./aliases) với tên đơn giản hơn.
- Bộ đếm (ví dụ: "12/15") hiển thị số biểu tượng đã tải thành công trên tổng số tìm thấy.
- Biểu tượng được sắp xếp theo mức độ phổ biến (số lượt tải) theo mặc định.