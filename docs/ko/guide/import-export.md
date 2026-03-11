# 가져오기 및 내보내기

아이콘 설정을 백업하거나 다른 Mac으로 이전할 수 있습니다.

## 내보내기 항목

내보내기 파일(JSON)에는 다음이 포함됩니다:
- **앱 별칭** — 사용자 지정 검색 이름 매핑
- **캐시된 아이콘 참조** — 커스텀 아이콘이 설정된 앱과 캐시된 아이콘 파일

## 내보내기

### GUI에서

**설정** > **고급** > **설정 파일**로 이동하여 **내보내기**를 클릭합니다.

### CLI에서

```bash
iconchanger export ~/Desktop/my-icons.json
```

## 가져오기

### GUI에서

**설정** > **고급** > **설정 파일**로 이동하여 **가져오기**를 클릭합니다.

### CLI에서

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
가져오기는 새 항목만 **추가**합니다. 기존 별칭이나 캐시된 아이콘을 교체하거나 삭제하지 않습니다.
:::

## 유효성 검사

가져오기 전에 설정 파일의 유효성을 검사할 수 있습니다:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

이 명령어는 변경 사항을 적용하지 않고 파일 구조만 확인합니다.

## Dotfiles를 활용한 자동화

Dotfiles의 일부로 IconChanger 설정을 자동화할 수 있습니다:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# 앱 설치
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI 설치 (앱 번들에서)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# 아이콘 설정 가져오기
iconchanger import ~/dotfiles/iconchanger/config.json
```
