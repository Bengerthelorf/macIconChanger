# 명령어 레퍼런스

## 개요

```
iconchanger <command> [options]
```

## 명령어

### `status`

현재 설정 상태를 표시합니다.

```bash
iconchanger status
```

표시 내용:
- 구성된 앱 별칭 수
- 캐시된 아이콘 수
- 헬퍼 스크립트 상태

---

### `list`

모든 별칭과 캐시된 아이콘을 나열합니다.

```bash
iconchanger list
```

구성된 모든 별칭과 캐시된 아이콘 항목을 표 형태로 표시합니다.

---

### `set-icon`

앱에 커스텀 아이콘을 설정합니다.

```bash
iconchanger set-icon <app-path> <image-path>
```

**인수:**
- `app-path` — 앱 경로 (예: `/Applications/Safari.app`)
- `image-path` — 아이콘 이미지 경로 (PNG, JPEG, ICNS 등)

**예시:**

```bash
# Safari에 커스텀 아이콘 설정
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# 상대 경로도 사용 가능
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

커스텀 아이콘을 제거하고 원래 아이콘으로 복원합니다.

```bash
iconchanger remove-icon <app-path>
```

**예시:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

캐시된 모든 커스텀 아이콘을 복원합니다. 시스템 업데이트 후 또는 앱이 아이콘을 초기화했을 때 유용합니다.

```bash
iconchanger restore [options]
```

**옵션:**
- `--dry-run` — 변경 사항을 적용하지 않고 복원될 내용을 미리 봅니다
- `--verbose` — 각 아이콘에 대한 상세 출력을 표시합니다
- `--force` — 아이콘이 변경되지 않은 것처럼 보여도 강제로 복원합니다

**예시:**

```bash
# 캐시된 모든 아이콘 복원
iconchanger restore

# 실행 결과 미리 보기
iconchanger restore --dry-run --verbose

# 모든 항목 강제 복원
iconchanger restore --force
```

---

### `export`

별칭과 캐시된 아이콘 설정을 JSON 파일로 내보냅니다.

```bash
iconchanger export <output-path>
```

**예시:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

설정 파일을 가져옵니다.

```bash
iconchanger import <input-path>
```

가져오기는 새 항목만 추가합니다. 기존 항목을 교체하거나 삭제하지 않습니다.

**예시:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

가져오기 전에 설정 파일의 유효성을 검사합니다.

```bash
iconchanger validate <file-path>
```

변경 사항을 적용하지 않고 JSON 구조, 필수 필드 및 데이터 무결성을 확인합니다.

**예시:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

macOS Tahoe의 Squircle Jail을 탈출합니다. 번들된 아이콘을 커스텀 아이콘으로 다시 적용하여 원래 아이콘 형태를 유지합니다. 커스텀 아이콘은 스퀘클 강제를 우회합니다.

```bash
iconchanger escape-jail [app-path] [options]
```

**인수:**
- `app-path` — (선택 사항) 특정 `.app` 번들 경로. 생략하면 `/Applications`의 모든 앱을 처리합니다.

**옵션:**
- `--dry-run` — 변경 사항을 적용하지 않고 실행될 내용을 미리 봅니다
- `--verbose` — 상세 출력을 표시합니다

**예시:**

```bash
# /Applications의 모든 앱에 대해 Squircle Jail 탈출
iconchanger escape-jail

# 실행 결과 미리 보기
iconchanger escape-jail --dry-run --verbose

# 특정 앱에 대해 Squircle Jail 탈출
iconchanger escape-jail /Applications/Safari.app
```

::: warning
커스텀 아이콘은 macOS Tahoe의 Clear, Tinted 또는 Dark 아이콘 모드를 지원하지 않습니다. 정적 비트맵으로 유지됩니다.
:::

---

### `completions`

탭 자동 완성을 위한 셸 완성 스크립트를 생성합니다.

```bash
iconchanger completions <shell>
```

**인수:**
- `shell` — 셸 유형: `zsh`, `bash` 또는 `fish`

**예시:**

```bash
# Zsh (~/.zshrc에 추가)
source <(iconchanger completions zsh)

# Bash (~/.bashrc에 추가)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
