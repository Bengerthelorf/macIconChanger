---
title: インポート＆エクスポート
section: guide
order: 8
locale: ja
---

アイコン設定をバックアップしたり、他の Mac に転送したりできます。

## エクスポートされる内容

エクスポートファイル（JSON）には以下が含まれます：
- **アプリのエイリアス** — カスタム検索名のマッピング
- **キャッシュされたアイコンの参照** — カスタムアイコンが設定されているアプリとキャッシュされたアイコンファイル

## エクスポート

### GUI から

**Settings** > **Advanced** > **Configuration** で **Export** をクリックします。

### CLI から

```bash
iconchanger export ~/Desktop/my-icons.json
```

## インポート

### GUI から

**Settings** > **Advanced** > **Configuration** で **Import** をクリックします。

### CLI から

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
インポートは新しい項目を**追加**するだけです。既存のエイリアスやキャッシュされたアイコンが置き換えられたり削除されたりすることはありません。
:::

## バリデーション

インポート前に設定ファイルを検証できます：

```bash
iconchanger validate ~/Desktop/my-icons.json
```

これはファイル構造をチェックするだけで、変更は行いません。

## Dotfiles による自動化

Dotfiles の一部として IconChanger のセットアップを自動化できます：

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# アプリのインストール
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI のインストール（アプリバンドルから）
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# アイコン設定のインポート
iconchanger import ~/dotfiles/iconchanger/config.json
```