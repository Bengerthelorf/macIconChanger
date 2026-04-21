---
title: クイックスタート
section: guide
order: 1
locale: ja
---

## 必要条件

- macOS 13.0（Ventura）以降
- 管理者権限（初期設定およびアイコン変更に必要）

## インストール

### Homebrew（推奨）

```bash
brew install Bengerthelorf/tap/iconchanger
```

### 手動ダウンロード

1. [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) から最新の DMG をダウンロードします。
2. DMG を開き、**IconChanger** をアプリケーションフォルダにドラッグします。
3. IconChanger を起動します。

## 初回起動

初回起動時に、IconChanger は一度だけ権限の設定を求めます。これはアプリがアプリケーションアイコンを変更するために必要です。

![初回起動のセットアップ画面](/images/setup-prompt.png)

セットアップボタンをクリックし、管理者パスワードを入力してください。IconChanger が必要な権限（ヘルパースクリプト用の sudoers ルール）を自動的に設定します。

::: tip
自動セットアップが失敗した場合は、[初期設定](./setup)で手動の手順を確認してください。
:::

## 最初のアイコンを変更する

1. サイドバーからアプリケーションを選択します。
2. [macOSicons.com](https://macosicons.com/) でアイコンを検索するか、ローカルの画像ファイルを選択します。
3. アイコンをクリックして適用します。

![メインインターフェース](/images/main-interface.png)

以上です！アプリアイコンがすぐに変更されます。

## 次のステップ

- [API キーを設定](./api-key)してオンラインアイコン検索を有効にする
- [アプリのエイリアス](./aliases)で検索結果を改善する
- [バックグラウンドサービスを設定](./background-service)してアイコンの自動復元を有効にする
- [CLI ツールをインストール](/ja/cli/)してコマンドラインからアクセスする