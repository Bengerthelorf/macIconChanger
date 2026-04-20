---
title: 快速开始
section: guide
order: 1
locale: zh
---


## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- 管理员权限（用于初始配置和更改图标）

## 安装

### Homebrew（推荐）

```bash
brew install Bengerthelorf/tap/iconchanger
```

### 手动下载

1. 从 [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) 下载最新 DMG。
2. 打开 DMG，将 **IconChanger** 拖入应用程序文件夹。
3. 启动 IconChanger。

## 首次启动

首次启动时，IconChanger 会提示你完成一次性权限配置。这是更改应用图标所必需的。

![首次启动配置](/images/setup-prompt.png)

点击配置按钮并输入管理员密码。IconChanger 会自动配置所需权限（helper 脚本的 sudoers 规则）。

:::callout[tip]{kind="info"}
如果自动配置失败，请参阅[权限配置](./setup)进行手动配置。
:::

## 更改第一个图标

1. 从侧边栏选择一个应用。
2. 浏览 [macOSicons.com](https://macosicons.com/) 上的图标或选择本地图片。
3. 点击图标即可应用。

![主界面](/images/main-interface.png)

就这么简单！

## 下一步

- [配置 API 密钥](./api-key)以启用在线图标搜索
- [了解应用别名](./aliases)以获得更好的搜索结果
- [配置后台服务](./background-service)以自动恢复图标
- [安装 CLI 工具](/zh/cli/)以使用命令行
