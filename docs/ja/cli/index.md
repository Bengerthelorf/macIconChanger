# CLI のインストール

IconChanger には、スクリプトや自動化のためのコマンドラインインターフェースが含まれています。

## アプリからインストール

1. IconChanger を開き、**Settings** > **Advanced** に移動します。
2. **Command Line Tool** の **Install** をクリックします。
3. 管理者パスワードを入力します。

これでターミナルから `iconchanger` コマンドが使用可能になります。

## 手動インストール

手動でインストールする場合（例：Dotfiles スクリプト内で）：

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## インストールの確認

```bash
iconchanger --version
```

## アンインストール

アプリから：**Settings** > **Advanced** > **Uninstall**。

または手動で：

```bash
sudo rm /usr/local/bin/iconchanger
```

## 次のステップ

利用可能なすべてのコマンドについては、[コマンドリファレンス](./commands)を参照してください。
