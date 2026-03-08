# 命令参考

## 概览

```
iconchanger <命令> [选项]
```

## 命令

### `status`

显示当前配置状态。

```bash
iconchanger status
```

显示内容：
- 已配置的应用别名数量
- 缓存图标数量
- Helper 脚本状态

---

### `list`

列出所有别名和缓存图标。

```bash
iconchanger list
```

---

### `set-icon`

为应用设置自定义图标。

```bash
iconchanger set-icon <应用路径> <图片路径>
```

**参数：**
- `应用路径` — 应用的路径（如 `/Applications/Safari.app`）
- `图片路径` — 图标图片的路径（PNG、JPEG、ICNS 等）

**示例：**

```bash
# 设置 Safari 自定义图标
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# 支持相对路径
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

移除自定义图标，恢复原始图标。

```bash
iconchanger remove-icon <应用路径>
```

**示例：**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

恢复所有缓存的自定义图标。适用于系统更新后或应用重置图标时。

```bash
iconchanger restore [选项]
```

**选项：**
- `--dry-run` — 预览将恢复的内容，不做实际更改
- `--verbose` — 显示每个图标的详细输出
- `--force` — 强制恢复，即使图标看起来没有变化

**示例：**

```bash
# 恢复所有缓存图标
iconchanger restore

# 预览恢复操作
iconchanger restore --dry-run --verbose

# 强制恢复所有
iconchanger restore --force
```

---

### `export`

导出别名和缓存图标配置到 JSON 文件。

```bash
iconchanger export <输出路径>
```

**示例：**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

导入配置文件。

```bash
iconchanger import <输入路径>
```

导入只添加新条目，不会替换或删除现有配置。

**示例：**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

导入前验证配置文件。

```bash
iconchanger validate <文件路径>
```

检查 JSON 结构、必需字段和数据完整性，不做实际更改。

**示例：**

```bash
iconchanger validate ~/Desktop/my-icons.json
```
