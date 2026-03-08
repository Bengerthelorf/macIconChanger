# 导入与导出

备份你的图标配置或迁移到另一台 Mac。

## 导出内容

导出文件 (JSON) 包含：
- **应用别名** — 自定义搜索名称映射
- **缓存图标引用** — 哪些应用有自定义图标及缓存的图标文件

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

::: tip
导入只会**添加**新条目，不会替换或删除现有的别名和缓存图标。
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
