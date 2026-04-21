---
title: 快速開始
section: guide
order: 1
locale: zh-HK
---

## 系統需求

- macOS 13.0 (Ventura) 或更高版本
- 管理員權限（用於初始設定和更改圖示）

## 安裝

### Homebrew（推薦）

```bash
brew install Bengerthelorf/tap/iconchanger
```

### 手動下載

1. 從 [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) 下載最新 DMG。
2. 打開 DMG，將 **IconChanger** 拖入應用程式文件夾。
3. 啟動 IconChanger。

## 首次啟動

首次啟動時，IconChanger 會提示你完成一次性權限設定。這是更改應用程式圖示所必需的。

![首次啟動設定](/images/setup-prompt.png)

點擊設定按鈕並輸入管理員密碼。IconChanger 會自動設定所需權限（helper 腳本的 sudoers 規則）。

::: tip
如果自動設定失敗，請參閱[權限設定](./setup)進行手動設定。
:::

## 更改第一個圖示

1. 從側邊欄選擇一個應用程式。
2. 瀏覽 [macOSicons.com](https://macosicons.com/) 上的圖示或選擇本機圖片。
3. 點擊圖示即可應用。

![主界面](/images/main-interface.png)

就這麼簡單！

## 下一步

- [設定 API 密鑰](./api-key)以啟用線上圖示搜尋
- [了解應用程式別名](./aliases)以獲得更好的搜尋結果
- [設定背景服務](./background-service)以自動還原圖示
- [安裝 CLI 工具](/zh-HK/cli/)以使用命令列