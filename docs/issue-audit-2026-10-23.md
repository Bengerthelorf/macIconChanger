# 开放问题审计 2026 年 10 月 23 日

本轮围绕应用与用户选定文件夹的图标更换、恢复、后台自动化和原生 macOS 界面处理实际缺陷。兼容目标为 macOS 13 及以上，包括 Sequoia；交付限于本地 DMG。全局系统资源替换、递归批改文件类型、公开发布和 GitHub 发帖均不在本轮范围。

问题依据为 2026 年 10 月 23 日取得的 GitHub API 快照 `issues-open.json` 与 `issue-comments.json`，位于仓库旁的 `macIconChanger-audit-20261023` 目录。快照含 **17 个开放 issue 和 1 个开放 PR**，均已按内容逐项评估；标签仅作为背景，不用于排除问题。下表中的“已实现”描述当前源码能力，不代表原报告机器已复测，也不代表 GitHub 问题已关闭。

## 逐项结论

| 问题 | 判定 | 当前行为与处理边界 |
| --- | --- | --- |
| [#11 误移除启动台图标](https://github.com/Bengerthelorf/macIconChanger/issues/11) | 历史功能已移除，已有防护 | 报告询问误操作后的恢复。当前界面已移除不可逆 Launchpad 数据库删除入口，并有 [回归检查](../tests/no-launchpad-mutation.sh) 防止重新暴露；不追加 Launchpad 数据库修复工具，也不声称能恢复报告者历史删除的数据。 |
| [#12 1.1.3 替换无反应](https://github.com/Bengerthelorf/macIconChanger/issues/12) | 古旧版本报告，当前未复现 | 报告针对 1.1.3、macOS 15.4.1，缺少当前版本日志和可复现步骤。当前权限检查、失败提示、文件路径与写入状态均有针对性验证，但不能据此判定该机器的问题已解决；未确认需要独立的新修复。 |
| [#21 1.1.5 被系统移入废纸篓](https://github.com/Bengerthelorf/macIconChanger/issues/21) | 旧签名与安全环境问题，保留原机验证 | 报告日志明确出现签名无效，且与机器安全策略变化同时发生。本轮本地 DMG 的临时签名与结构验证通过，不能替代 Developer ID、公证、Gatekeeper 信任或原报告安全环境复测；不声称历史问题已解决。 |
| [#24 按外观切换图标](https://github.com/Bengerthelorf/macIconChanger/issues/24) | 已部分实现，保留平台边界 | 已有浅色与深色图片配对、外观监测、自动应用和缓存恢复；需启用切换并配置完整的一对图片。监测的是系统界面 Light/Dark，不是 Tahoe 独立的图标 Clear/Tinted 等选择；也未实现原请求的四种模式及每种空值回退。见 [IconAppearance.swift](../IconChanger/Services/IconAppearance.swift)、[IconAppearancePolicy.swift](../IconChanger/Services/IconAppearancePolicy.swift)。 |
| [#30 无法配置权限](https://github.com/Bengerthelorf/macIconChanger/issues/30) | 已有针对性处理 | 已区分受保护 helper、有效 sudo 授权与 App Management 权限；企业机未加载 drop-in 时提供手动模式和明确的受管兼容模式。不能凭 drop-in 文件存在判成功，也不能保证覆盖企业管理策略。与 #40、#42 共同验收。见 [IconManager.swift](../IconChanger/Services/IconManager.swift)、[SetupHealth.swift](../IconChanger/Services/SetupHealth.swift)。 |
| [#32 任何图标都无法更改](https://github.com/Bengerthelorf/macIconChanger/issues/32) | 多原因历史报告；已有修复，本轮加强失败判断 | 该线程混有授权、外部磁盘、无声失败及 Sophos 报告。请求缓存已迁入标准 `~/Library/Caches/com.zhuhaoyu.IconChanger/`，历史与收藏使用 Application Support；旧目录迁移已存在。缓存迁移不能证明杀毒软件兼容性已获原机复测。本轮增加图标写入后状态验证，避免 helper 成功退出却未留下自定义图标时保存成功记录。见 [AppPaths.swift](../IconChanger/Utilities/AppPaths.swift)、[IconInteractionPolicy.swift](../IconChanger/Services/IconInteractionPolicy.swift)。 |
| [#35 隐藏启动不检查配置](https://github.com/Bengerthelorf/macIconChanger/issues/35) | 已实现 | `AppDelegate` 在每次启动调用共享 `SetupMonitor`，不依赖主窗口出现；菜单栏状态随健康状态更新，隐藏启动缺少配置或已健康配置退化时可通知。通知仍取决于系统通知授权。见 [AppDelegate.swift](../IconChanger/App/AppDelegate.swift)、[SetupMonitor.swift](../IconChanger/Services/SetupMonitor.swift)、[BackgroundService.swift](../IconChanger/Services/BackgroundService.swift)。 |
| [#36 API 配额与历史重复](https://github.com/Bengerthelorf/macIconChanger/issues/36) | 已实现 | 已有 `Auto-load` 开关，关闭后选择应用不自动查询；手动 Load/Refresh 仍可用。本地改图标不会触发查询；从历史应用图片不会再增加历史。默认自动加载仍开启，用户可自行关闭。见 [ChangeView.swift](../IconChanger/Views/ChangeView.swift)、[IconInteractionPolicy.swift](../IconChanger/Services/IconInteractionPolicy.swift)、[HistoryImageView.swift](../IconChanger/Views/ImageView/HistoryImageView.swift)。 |
| [#37 全局默认文件夹图标](https://github.com/Bengerthelorf/macIconChanger/issues/37) | 范围外 | 产品支持用户选定的文件夹；系统范围默认文件夹资源替换是不同能力。本轮修复普通文件夹入口，不追加系统资源替换。 |
| [#38 更新应用后不自动恢复](https://github.com/Bengerthelorf/macIconChanger/issues/38) | 本轮确认并修复新缺陷 | 原有定时器与版本比较之后，仍存在同一进程内 `Bundle` 元数据缓存导致读不到磁盘新版本的问题。改为直接读取 `Contents/Info.plist`；真实临时 `.app` fixture 覆盖原地改版本、同路径整体替换、短版本回退、损坏与缺失 plist。更新恢复批次还改为逐项捕获失败，避免一个失败阻断后续应用，并按实际成功数通知。见 [IconCache.swift](../IconChanger/Services/IconCache.swift)、[app-version-metadata.swift](../tests/app-version-metadata.swift)、[background-restore.swift](../tests/background-restore.swift)。 |
| [#40 企业机授权失败及列表持续刷新](https://github.com/Bengerthelorf/macIconChanger/issues/40) | 已有针对性处理 | 线程后续已报告授权恢复，同时指出每隔数秒刷新使浏览不可用。当前 setup 重检保留已有可浏览状态，相同健康状态不重复发布；缺少永久授权时仍可手动操作，后台恢复暂停。受管 sudo 配置的处理与 #42 共用。尚无原企业机端到端复测。见 [SetupMonitor.swift](../IconChanger/Services/SetupMonitor.swift)、[ContentView.swift](../IconChanger/App/ContentView.swift)。 |
| [#41 首开显示 Helper Files Missing](https://github.com/Bengerthelorf/macIconChanger/issues/41) | 已改善引导与状态同步 | 真正未安装 helper 时当前界面提供安装动作并说明管理员授权；安装后重新检查。重叠检查会排队取新状态，避免较早检查覆盖安装后的结果。不能把新机器确实缺少 helper 的状态伪装成 Ready；未声称复现了报告者的全部首次启动时序。见 [ContentView.swift](../IconChanger/App/ContentView.swift)、[SetupCheckQueue](../IconChanger/Services/SetupHealth.swift)。 |
| [#42 权限修复回滚与旧规则循环](https://github.com/Bengerthelorf/macIconChanger/issues/42) | pre.2 已有修复；显式保留异常规则边界 | 已先移除候选配置中的旧兼容块，再探测 drop-in 是否有效，防止旧主文件规则产生假阳性；必要时要求明确选择受管兼容模式。标准历史规则可清理，`helper.shd` 等未知变体会回滚并提示管理员检查，不猜测或宽泛改写 sudoers。见 [IconManager.swift](../IconChanger/Services/IconManager.swift)、[sudoers-repair.py](../tests/sudoers-repair.py)；修复已在 [301cec6](https://github.com/Bengerthelorf/macIconChanger/commit/301cec6289a092aba3e713fff59b59c196edd69c) 中进入 pre.2 源码。 |
| [#44 Arc 启动后恢复自选图标](https://github.com/Bengerthelorf/macIconChanger/issues/44) | 第三方应用自行管理图标；保留限制 | 报告中 Finder 已显示新图标，Arc 打开后又恢复其设置中的图标，属于运行时覆盖。重启 Dock 能刷新缓存，不能禁止 Arc 自己重写图标；本轮不增加进程注入、反复争抢或强制改包。写入后的即时验证也不能保证将来启动时不被覆盖。 |
| [#45 IconChanger 自身缺深色图标](https://github.com/Bengerthelorf/macIconChanger/issues/45) | 资源设计需求，延后 | 这是应用自己的 AppIcon 资源适配，与 #24 为目标应用配置浅深色图片不同。本轮聚焦工作流程缺陷，不自行设计一套深色应用图标。 |
| [#46 按扩展名扫描并批量改文件图标](https://github.com/Bengerthelorf/macIconChanger/issues/46) | 范围外 | 递归扫描用户目录和扩展名规则会扩大目标、权限及恢复语义；不纳入应用与选定文件夹的当前工作流程。报告中的 macOS 27.2 Beta 也不作为本轮运行时兼容结论。 |
| [#47 Apple 应用均更换失败](https://github.com/Bengerthelorf/macIconChanger/issues/47) | 系统保护限制；错误提示需准确 | 不能把所有 Apple 应用一概视为可写，也不能把系统保护或只读卷失败统一引导成“修复 helper”。本轮按目标路径与实际错误区分系统保护、普通权限和其他失败，不承诺绕过 SIP、SSV 或 OCLP 配置。见 [IconAppearancePolicy.swift](../IconChanger/Services/IconAppearancePolicy.swift)、[IconManager.swift](../IconChanger/Services/IconManager.swift)。 |
| [PR #43 补充 refresh-dock 文档](https://github.com/Bengerthelorf/macIconChanger/pull/43) | 仅文档，单独保留 | 当前 CLI 已有 `refresh-dock`，两次重启 Dock；当前命令文档仍未列出它。PR 的意图是补齐文档，不是新增命令或核心工作流程修复。本轮不合并 PR、不发送评论。见 [IconChangerCLI.swift](../IconChangerCLI/IconChangerCLI.swift)、[命令文档](cli/commands.md)。 |

## 本轮补充的实际缺陷

除 #38 外，检查当前工作流程还确认了以下问题：

- 后台 Dock 和菜单栏开关需要立即生效，且必须至少保留一个重新进入应用的入口。`BackgroundVisibilityPolicy` 保证关闭最后一个入口时保留另一个；自定义时间间隔限制在一年内，并规范化已保存的极大值，避免整型换算溢出。见 [BackgroundSchedulePolicy.swift](../IconChanger/Services/BackgroundSchedulePolicy.swift)、[BackgroundService.swift](../IconChanger/Services/BackgroundService.swift)。
- README 已承诺选定文件夹图标，但受保护 helper 明确只允许 `.app`。普通文件夹的设置、移除、单项缓存恢复与撤销改用当前用户权限下的公开 `NSWorkspace.setIcon`，操作期平衡 security scope；保留 helper 对应用包和特权目标的限制，不增加文件夹 sudo 回退。真实临时文件夹 fixture 已通过两轮应用与移除，并验证拒绝符号链接。单项目标不再依赖应用 helper 检查；整个缓存批次仍先验证应用 helper，这是现有批量自动化的边界。见 [folder-icon.py](../tests/folder-icon.py)。
- helper 的退出状态不能独自证明图标写入生效。新增后置检查确认设置后存在自定义图标位、移除后该位清除，再提交缓存；该检查不比较图像内容，因此不能证明已有自定义图标已替换成指定图片，也不能保证第三方应用后续不覆盖它。
- 文件路径曾对 `URL.path` 再做一次百分号解码，可能把名称中的字面 `%20` 变成空格、`%2F` 变成目录分隔符，导致操作定位到不同目标。`universalPath()` 现在直接使用已解码的 `URL.path`；回归覆盖字面百分号、空格、中文、无效转义及编码 file URL，旧实现失败、修复后通过。见 [URL+Universal.swift](../IconChanger/Extensions/URL+Universal.swift)、[file-paths.swift](../tests/file-paths.swift)。
- 后台更新恢复已逐项继续执行，失败、无可用缓存和成功分开计数；只有实际恢复成功才刷新 Dock。定时与手动批量恢复通知也保留成功、未安装跳过和失败数量，不再在部分失败后显示“全部成功”。回归执行生产恢复循环与通知方法，并以隔离依赖覆盖首项失败、后续成功、无可用图标及空批次。见 [background-restore.sh](../tests/background-restore.sh)。
- Dock 操作、复制版本号和敏感输入使用原生 `Button` / `SecureField`，保留 macOS 13 的兼容写法。双架构构建及当前主机隔离界面检查已通过；不会因此宣称已在全部 macOS 版本运行测试。

## 验证记录与交付边界

2026 年 10 月 23 日已验证通过的针对性检查：

| 检查 | 所支持的结论 |
| --- | --- |
| `bash tests/app-version-metadata.sh` | 同一进程读取磁盘更新及同路径替换后的真实 app plist 版本。 |
| `bash tests/background-schedule.sh` | 可见入口不同时关闭；极大或非法间隔被拒绝或规范化；后台计划使用已保存执行时间。 |
| `bash tests/background-interval-observers.sh` | 保留真实 Combine `@Published` 包装与生产 observer，三个属性各覆盖 `Int.max`、0、17；归一化后只持久化一次、重排一次，不接触主机偏好设置。 |
| `bash tests/setup-health.sh` | 健康状态、通知条件、手动模式暂停后台自动化及重叠检查队列策略。 |
| `bash tests/icon-interactions.sh` | 按需查询策略、历史复用不重复记录、查询设置备份一致及缺失 API key 的处理。 |
| `python3 tests/sudoers-repair.py` | 使用隔离的 sudo、visudo 和文件夹 fixture，验证旧兼容块、异常旧规则、普通 drop-in 与回滚分支；未改动本机 sudoers。 |
| `python3 tests/folder-icon.py` | 提取生产文件夹路由，使用真实临时文件夹验证重复设置与移除、自定义图标位变化、符号链接拒绝，并确保未调用管理员 helper。 |
| `bash tests/background-restore.sh` | 执行生产更新恢复循环及通知方法；单项失败不阻断后续任务，通知报告真实结果，无成功时不重启 Dock。 |
| `tests/file-paths.swift` | `universalPath()` 对字面 `%xx` 文件名及编码 file URL 仅解码一次；修复前失败、修复后通过。 |

最终集成验收已通过：

| 验收 | 结果与证据 |
| --- | --- |
| 完整回归 | `bash tests/run.sh` 最终退出码为 0，包含真实 `@Published` observer 的九个场景。 |
| Release 构建 | GUI 与 CLI 均构建为 arm64 / x86_64 通用二进制；`vtool` 检查两种架构的最低系统版本均为 13.0。 |
| 隔离界面检查 | 当前源码的独立 UI app 已验证 Dock 原生按钮选择、主界面与设置的浅深色外观、About 原生版本按钮、Dock/菜单栏入口互保、极大间隔禁止保存、8760 小时可保存、Escape 取消，以及预览失败后可重试或取消。截图位于 [审查目录](../../macIconChanger-audit-20261023/ui/screenshots)。 |
| 本地 DMG | 只读挂载后验证 Applications 链接、应用结构、版本 `1.5.1-pre.3`、构建号 `5010501500300` 通过；临时签名加 hardened runtime 的 `codesign --deep --strict` 验证通过。未公开发布。 |

交付文件：`/Users/snaix/Downloads/IconChanger-1.5.1-pre.3-local-20261023-universal.dmg`，大小 **8,579,151 字节**。

SHA-256：`1d9f580c4eae5130c8a24be49bdef8a58cb7a934f3da35dd90fae9f6051bbfb6`。

运行时界面验证主机为 macOS 27.0.1，当前没有 Ventura 或 Sequoia 运行环境；二进制的最低系统版本 13.0 不能替代这些系统上的实际运行验证。临时文件夹检查不等于用户已有目录或外部卷的端到端验收。原报告的企业管理、Sophos、OCLP、签名信任与 Arc 环境仍需各自原机复测；本轮不会以本地通过结果自动关闭这些 issue。
