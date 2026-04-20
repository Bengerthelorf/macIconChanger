# コマンドリファレンス

## 概要

```
iconchanger <command> [options]
```

## コマンド

### `status`

現在の設定状態を表示します。

```bash
iconchanger status
```

表示内容：
- 設定されたアプリエイリアスの数
- キャッシュされたアイコンの数
- ヘルパースクリプトのステータス

---

### `list`

すべてのエイリアスとキャッシュされたアイコンを一覧表示します。

```bash
iconchanger list
```

設定済みのすべてのエイリアスとキャッシュされたアイコンエントリのテーブルを表示します。

---

### `set-icon`

アプリケーションにカスタムアイコンを設定します。

```bash
iconchanger set-icon <app-path> <image-path>
```

**引数：**
- `app-path` — アプリケーションのパス（例：`/Applications/Safari.app`）
- `image-path` — アイコン画像のパス（PNG、JPEG、ICNS など）

**例：**

```bash
# Safari にカスタムアイコンを設定
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# 相対パスも使用可能
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

カスタムアイコンを削除し、元のアイコンに戻します。

```bash
iconchanger remove-icon <app-path>
```

**例：**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

キャッシュされたすべてのカスタムアイコンを復元します。システムアップデート後やアプリがアイコンをリセットした場合に便利です。

```bash
iconchanger restore [options]
```

**オプション：**
- `--dry-run` — 変更を加えずに復元内容をプレビューします
- `--verbose` — 各アイコンの詳細な出力を表示します
- `--force` — アイコンが変更されていないように見える場合でも強制的に復元します

**例：**

```bash
# キャッシュされたすべてのアイコンを復元
iconchanger restore

# 実行内容をプレビュー
iconchanger restore --dry-run --verbose

# すべてを強制的に復元
iconchanger restore --force
```

---

### `export`

エイリアスとキャッシュされたアイコン設定を JSON ファイルにエクスポートします。

```bash
iconchanger export <output-path>
```

**例：**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

設定ファイルをインポートします。

```bash
iconchanger import <input-path>
```

インポートは新しい項目を追加するだけで、既存のエントリを置き換えたり削除したりすることはありません。

**例：**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

インポート前に設定ファイルを検証します。

```bash
iconchanger validate <file-path>
```

JSON の構造、必須フィールド、データの整合性を変更を加えずにチェックします。

**例：**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

macOS Tahoe の squircle jail から脱出します。バンドルされたアイコンをカスタムアイコンとして再適用することで、squircle の強制をバイパスし、元のアイコン形状を維持します。

```bash
iconchanger escape-jail [app-path] [options]
```

**引数：**
- `app-path` — （任意）特定の `.app` バンドルのパス。省略した場合、`/Applications` 内のすべてのアプリを処理します。

**オプション：**
- `--dry-run` — 変更を加えずに実行内容をプレビューします
- `--verbose` — 詳細な出力を表示します

**例：**

```bash
# /Applications 内のすべてのアプリで squircle jail から脱出
iconchanger escape-jail

# 実行内容をプレビュー
iconchanger escape-jail --dry-run --verbose

# 特定のアプリで squircle jail から脱出
iconchanger escape-jail /Applications/Safari.app
```

::: warning
カスタムアイコンは macOS Tahoe の Clear、Tinted、Dark アイコンモードに対応していません。静的なビットマップのままになります。
:::

---

### `completions`

タブ補完用のシェル補完スクリプトを生成します。

```bash
iconchanger completions <shell>
```

**引数：**
- `shell` — シェルの種類：`zsh`、`bash`、または `fish`

**例：**

```bash
# Zsh（~/.zshrc に追加）
source <(iconchanger completions zsh)

# Bash（~/.bashrc に追加）
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
