---
title: CLI 설치
section: cli
locale: ko
---

IconChanger는 스크립팅 및 자동화를 위한 명령줄 인터페이스를 포함하고 있습니다.

## 앱에서 설치

1. IconChanger > **설정** > **고급**을 엽니다.
2. **명령줄 도구** 아래에서 **설치**를 클릭합니다.
3. 관리자 비밀번호를 입력합니다.

이제 터미널에서 `iconchanger` 명령어를 사용할 수 있습니다.

## 수동 설치

수동으로 설치하려면 (예: dotfiles 스크립트에서):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## 설치 확인

```bash
iconchanger --version
```

## 제거

앱에서: **설정** > **고급** > **제거**.

또는 수동으로:

```bash
sudo rm /usr/local/bin/iconchanger
```

## 다음 단계

사용 가능한 모든 명령어는 [명령어 레퍼런스](./commands)를 참조하세요.