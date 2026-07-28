---
title: 导入与导出
section: guide
order: 8
locale: zh
---


备份你的图标配置或迁移到另一台 Mac。

## 导出内容

导出文件 (JSON) 包含：
- **应用别名** — 自定义搜索名称映射
- **普通缓存图标** — 图标数据及对应的应用路径
- **浅色/深色图标** — 两个外观槽位（未配齐的组合也会备份）
- **设置** — 显示、后台恢复、更新、语言与 API 行为设置

明文 JSON 不会包含 API key 或其他钥匙串密钥。在图形界面中设置可选密码，
可以生成加密的 `.icconfig`，并在加密文件中包含这些密钥。导出文件仅允许当前用户读取。

## 导出

### 通过界面

进入 **设置** > **高级** > **配置管理**，点击 **导出**。

### 通过命令行

```bash
iconchanger export ~/Desktop/my-icons.json
```

## 导入

### 通过界面

进入 **设置** > **高级** > **配置管理**，点击 **导入**。

### 通过命令行

```bash
iconchanger import ~/Desktop/my-icons.json
```

:::callout[tip]{kind="info"}
导入只会**添加**缺少的别名或图标槽位，不会替换或删除已有的图标选择；
备份中的设置会被恢复。加密文件需要通过图形界面导入。
:::

## 验证

导入前可以验证配置文件：

```bash
iconchanger validate ~/Desktop/my-icons.json
```

检查文件结构但不做任何更改。

## 通过 dotfiles 自动化

可以将 IconChanger 配置集成到你的 dotfiles 中：

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# 安装应用
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# 安装 CLI
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# 导入图标配置
iconchanger import ~/dotfiles/iconchanger/config.json
```
