# 权限配置

IconChanger 需要管理员权限才能更改应用图标。首次启动时，应用会提供自动配置。

## 自动配置（推荐）

1. 启动 IconChanger。
2. 在提示时点击 **配置** 按钮。
3. 输入管理员密码。

应用会将辅助脚本安装到 `/usr/local/lib/iconchanger/`（由 `root:wheel` 拥有），并配置受限的 sudoers 规则使其无需每次输入密码。

## 安全性

IconChanger 采用多项安全措施来保护辅助管道：

- **Root 拥有的辅助目录** — 辅助文件存放在 `/usr/local/lib/iconchanger/`，由 `root:wheel` 拥有，防止非特权用户修改。
- **SHA-256 完整性验证** — 每次执行前，辅助脚本都会通过已知哈希值进行验证。
- **受限的 sudoers 规则** — sudoers 条目仅授予对特定辅助脚本的免密码访问权限，而非任意命令。
- **审计日志** — 所有图标操作均带有时间戳记录，便于追溯。

## 手动配置

如果自动配置失败，可以手动配置：

1. 打开终端。
2. 运行：

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. 添加以下内容：

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## 验证配置

配置完成后，应用应该在侧边栏显示应用列表。如果仍然看到配置提示，说明配置可能未正确应用。

可以从菜单栏的 **...** 菜单中选择 **检查配置状态** 来验证。

## 限制

受 macOS 系统完整性保护 (SIP) 限制，无法更改系统应用的图标。这是 macOS 的限制，无法绕过。

常见的受 SIP 保护的应用包括：
- 访达 (Finder)
- Safari（部分 macOS 版本）
- `/System/Applications/` 中的其他系统应用
