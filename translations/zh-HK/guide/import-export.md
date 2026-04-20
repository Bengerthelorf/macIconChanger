# 導入與導出

備份你的圖示設定或遷移到另一台 Mac。

## 導出內容

導出檔案 (JSON) 包含：
- **應用程式別名** — 自訂搜尋名稱對應
- **緩存圖示參照** — 哪些應用程式有自訂圖示及緩存的圖示檔案

## 導出

### 透過界面

進入 **設定** > **進階** > **設定管理**，點擊 **導出**。

### 透過命令列

```bash
iconchanger export ~/Desktop/my-icons.json
```

## 導入

### 透過界面

進入 **設定** > **進階** > **設定管理**，點擊 **導入**。

### 透過命令列

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
導入只會**新增**新條目，不會取代或刪除現有的別名和緩存圖示。
:::

## 驗證

導入前可以驗證設定檔案：

```bash
iconchanger validate ~/Desktop/my-icons.json
```

檢查檔案結構但不做任何更改。

## 透過 dotfiles 自動化

可以將 IconChanger 設定整合到你的 dotfiles 中：

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# 安裝應用程式
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# 安裝 CLI
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# 導入圖示設定
iconchanger import ~/dotfiles/iconchanger/config.json
```
