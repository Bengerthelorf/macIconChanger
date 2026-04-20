---
title: CLI 安装
section: cli
order: 1
locale: zh
---


IconChanger 包含命令行工具，适用于脚本和自动化。

## 从应用安装

1. 打开 IconChanger > **设置** > **高级**。
2. 在 **命令行工具** 下点击 **安装**。
3. 输入管理员密码。

终端中即可使用 `iconchanger` 命令。

## 手动安装

如果需要手动安装（如在 dotfiles 脚本中）：

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## 验证安装

```bash
iconchanger --version
```

## 卸载

从应用：**设置** > **高级** > **卸载**。

或手动：

```bash
sudo rm /usr/local/bin/iconchanger
```

## 下一步

参阅[命令参考](./commands)了解所有可用命令。
