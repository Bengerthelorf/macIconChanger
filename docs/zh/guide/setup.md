# 权限配置

IconChanger 需要管理员权限才能更改应用图标。首次启动时，应用会提供自动配置。

## 自动配置（推荐）

1. 启动 IconChanger。
2. 在提示时点击 **配置** 按钮。
3. 输入管理员密码。

应用会在 `~/.iconchanger/helper.sh` 创建辅助脚本，并配置 sudoers 规则使其无需每次输入密码。

## 手动配置

如果自动配置失败，可以手动配置：

1. 打开终端。
2. 运行：

```bash
sudo visudo
```

3. 在末尾添加：

```
ALL ALL=(ALL) NOPASSWD: /Users/<你的用户名>/.iconchanger/helper.sh
```

将 `<你的用户名>` 替换为你的 macOS 用户名。

## 验证配置

配置完成后，应用应该在侧边栏显示应用列表。如果仍然看到配置提示，说明配置可能未正确应用。

可以从菜单栏的 **...** 菜单中选择 **检查配置状态** 来验证。

## 限制

受 macOS 系统完整性保护 (SIP) 限制，无法更改系统应用的图标。这是 macOS 的限制，无法绕过。

常见的受 SIP 保护的应用包括：
- 访达 (Finder)
- Safari（部分 macOS 版本）
- `/System/Applications/` 中的其他系统应用
