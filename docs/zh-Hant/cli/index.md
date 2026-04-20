---
title: CLI 安裝
section: cli
order: 1
locale: zh-Hant
---


IconChanger 包含命令列工具，適用於腳本和自動化。

## 從應用程式安裝

1. 打開 IconChanger > **設定** > **進階**。
2. 在 **命令列工具** 下點擊 **安裝**。
3. 輸入管理員密碼。

終端機中即可使用 `iconchanger` 命令。

## 手動安裝

如果需要手動安裝（如在 dotfiles 腳本中）：

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## 驗證安裝

```bash
iconchanger --version
```

## 解除安裝

從應用程式：**設定** > **進階** > **解除安裝**。

或手動：

```bash
sudo rm /usr/local/bin/iconchanger
```

## 下一步

參閱[命令參考](./commands)了解所有可用命令。
