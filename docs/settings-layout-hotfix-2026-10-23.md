# Settings layout hotfix verification

Target: `v1.5.1-pre.3.fix.1`, build `5010501500301`.

The earlier compact-window review missed paragraph alignment and localized action-label truncation. This follow-up addresses the reported screenshots without increasing the 500-point settings width or changing icon operations.

## Changes

- All 14 grouped Form footers use one explicit description style: secondary callout text, leading paragraph alignment, natural vertical size, and a full-width leading frame. A leading frame alone does not specify how wrapped lines align. Configuration descriptions have consistent paragraph spacing.
- The native AppKit settings toolbar switches to icon mode when translated titles overflow. Every pane remains directly accessible, with its localized accessibility name and native tooltip. Short titles retain icon-and-label mode.
- Cache actions use native `ViewThatFits`: one row when all full labels fit, otherwise a vertical stack. Full localized action names remain visible, including the all-selected state.
- Settings use the selected language's locale and writing direction. Arabic content mirrors independently of the system language.

## Native UI verification

Opened all seven panes (Application, Icon Cache, Background, Display, Advanced, Developer, About) separately in every supported language. Captured populated cache rows, expanded background options, Display top/bottom, Advanced top/API/configuration/bottom, Developer top/bottom, aliases/folders, and About.

| Language code | Seven panes and long descriptions |
| --- | --- |
| `en` | Checked |
| `fr` | Checked |
| `de` | Checked |
| `es` | Checked |
| `pt` | Checked |
| `it` | Checked |
| `ru` | Checked |
| `nl` | Checked |
| `tr` | Checked |
| `pl` | Checked |
| `ar` | Checked |
| `th` | Checked |
| `vi` | Checked |
| `id` | Checked |
| `uk` | Checked |
| `sv` | Checked |
| `da` | Checked |
| `nb` | Checked |
| `fi` | Checked |
| `cs` | Checked |
| `hu` | Checked |
| `el` | Checked |
| `ro` | Checked |
| `hi` | Checked |
| `ms` | Checked |
| `ja` | Checked |
| `ko` | Checked |
| `zh-Hans` | Checked |
| `zh-Hant` | Checked |
| `zh-HK` | Checked |

Each language has at least 13 native-window screenshots and accompanying accessibility snapshots. All screenshots are 1000 physical pixels wide on a 2x display (500 logical points). Reviewed the resulting per-language overviews and enlarged suspect regions. Rechecked the early English/French/German/Spanish captures after the adaptive cache actions were implemented. English and French dark-mode checks include enabled Restore Selected and Clear All Cache states. Existing translations and their English fallbacks are retained; this is layout verification, not a translation-quality claim.

The UI Review bundle has a separate identifier/defaults, disposable cache fixtures, and disabled real credentials/helper/icon/login/Dock writes. Language fixtures were preset only in that bundle's defaults between launches. UI automation occasionally blocked while reading an open native language menu; a process sample showed ordinary AppKit menu tracking. The remaining locale fixtures were configured before launch to avoid that inspection limitation.

Host runtime: macOS 27.0.1, local Xcode 27.1. Runtime behavior on Ventura/Sequoia is not claimed. All new APIs are available on macOS 13, and the final CI Release build retained that minimum target.

## Candidate verification

- Local `bash tests/run.sh` passed after the footer, toolbar and cache-action changes.
- Release candidates run full regressions, a universal Release build and launch smoke test in GitHub Actions. The final candidate source, run ID and hashes are kept in the downloaded manifest and verification receipt alongside the native screenshots.
- Before promotion, verify DMG integrity, readonly-mounted layout, deep/strict code signatures, exact bundle version/build, GUI/CLI universal architectures, CLI launch and the Ed25519 update signature.
- Promote the final tested artifact through Publish Tested Release; earlier layout checkpoints are not promoted. The published version is [v1.5.1-pre.3.fix.1](https://github.com/Bengerthelorf/macIconChanger/releases/tag/v1.5.1-pre.3.fix.1).

Evidence: sibling directory `macIconChanger-audit-20261023/settings-hotfix/`, including `screenshots/`, `language-checks.json`, per-language overviews, CI/local logs and candidate verification receipt.
