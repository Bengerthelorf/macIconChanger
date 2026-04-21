---
title: 權限設定
section: guide
order: 2
locale: zh-HK
---

IconChanger 需要管理員權限才能更改應用程式圖示。首次啟動時，應用程式會提供自動設定。

## 自動設定（推薦）

1. 啟動 IconChanger。
2. 在提示時點擊 **設定** 按鈕。
3. 輸入管理員密碼。

應用程式會將輔助腳本安裝到 `/usr/local/lib/iconchanger/`（由 `root:wheel` 擁有），並設定受限的 sudoers 規則使其無需每次輸入密碼。

## 安全性

IconChanger 採用多項安全措施來保護輔助管道：

- **Root 擁有的輔助目錄** — 輔助檔案存放在 `/usr/local/lib/iconchanger/`，由 `root:wheel` 擁有，防止非特權用戶修改。
- **SHA-256 完整性驗證** — 每次執行前，輔助腳本都會透過已知雜湊值進行驗證。
- **受限的 sudoers 規則** — sudoers 條目僅授予對特定輔助腳本的免密碼存取權限，而非任意命令。
- **審計日誌** — 所有圖示操作均帶有時間戳記錄，便於追溯。

## 手動設定

如果自動設定失敗，可以手動設定：

1. 打開終端。
2. 運行：

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. 加入以下內容：

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## 驗證設定

設定完成後，應用程式應該在側邊欄顯示應用程式列表。如果仍然看到設定提示，說明設定可能未正確應用。

可以從菜單列的 **...** 選單中選擇 **檢查設定狀態** 來驗證。

## 限制

受 macOS 系統完整性保護 (SIP) 限制，無法更改系統應用程式的圖示。這是 macOS 的限制，無法繞過。

常見的受 SIP 保護的應用程式包括：
- Finder
- Safari（部分 macOS 版本）
- `/System/Applications/` 中的其他系統應用程式