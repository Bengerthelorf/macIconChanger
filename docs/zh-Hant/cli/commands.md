# 命令參考

## 概覽

```
iconchanger <命令> [選項]
```

## 命令

### `status`

顯示目前設定狀態。

```bash
iconchanger status
```

顯示內容：
- 已設定的應用程式別名數量
- 快取圖示數量
- Helper 腳本狀態

---

### `list`

列出所有別名和快取圖示。

```bash
iconchanger list
```

顯示所有已設定別名和所有快取圖示條目的表格。

---

### `set-icon`

為應用程式設定自訂圖示。

```bash
iconchanger set-icon <應用程式路徑> <圖片路徑>
```

**參數：**
- `應用程式路徑` — 應用程式的路徑（如 `/Applications/Safari.app`）
- `圖片路徑` — 圖示圖片的路徑（PNG、JPEG、ICNS 等）

**範例：**

```bash
# 設定 Safari 自訂圖示
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# 支援相對路徑
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

移除自訂圖示，還原原始圖示。

```bash
iconchanger remove-icon <應用程式路徑>
```

**範例：**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

還原所有快取的自訂圖示。適用於系統更新後或應用程式重設圖示時。

```bash
iconchanger restore [選項]
```

**選項：**
- `--dry-run` — 預覽將還原的內容，不做實際更改
- `--verbose` — 顯示每個圖示的詳細輸出
- `--force` — 強制還原，即使圖示看起來沒有變化

**範例：**

```bash
# 還原所有快取圖示
iconchanger restore

# 預覽還原動作
iconchanger restore --dry-run --verbose

# 強制還原所有
iconchanger restore --force
```

---

### `export`

匯出別名和快取圖示設定到 JSON 檔案。

```bash
iconchanger export <輸出路徑>
```

**範例：**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

匯入設定檔案。

```bash
iconchanger import <輸入路徑>
```

匯入只新增新條目，不會取代或刪除現有設定。

**範例：**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

匯入前驗證設定檔案。

```bash
iconchanger validate <檔案路徑>
```

檢查 JSON 結構、必需欄位和資料完整性，不做實際更改。

**範例：**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

逃出 macOS Tahoe 的圓角矩形監獄。透過將應用程式自身的圖示重新設定為自訂圖示，繞過系統的圓角矩形強制裁切，保持原始圖示形狀。

```bash
iconchanger escape-jail [應用程式路徑] [選項]
```

**參數：**
- `應用程式路徑` — （選填）指定 `.app` 套件的路徑。省略則處理 `/Applications` 下的所有應用程式。

**選項：**
- `--dry-run` — 預覽將執行的動作，不做實際更改
- `--verbose` — 顯示詳細輸出

**範例：**

```bash
# 為 /Applications 下的所有應用程式逃出監獄
iconchanger escape-jail

# 預覽動作
iconchanger escape-jail --dry-run --verbose

# 為特定應用程式逃出監獄
iconchanger escape-jail /Applications/Safari.app
```

::: warning
自訂圖示不支援 macOS Tahoe 的 Clear（透明）、Tinted（著色）或 Dark（深色）圖示模式，它們保持為靜態圖片。
:::

---

### `completions`

產生 Shell 自動補全腳本。

```bash
iconchanger completions <shell類型>
```

**參數：**
- `shell類型` — Shell 類型：`zsh`、`bash` 或 `fish`

**範例：**

```bash
# Zsh（加入到 ~/.zshrc）
source <(iconchanger completions zsh)

# Bash（加入到 ~/.bashrc）
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
