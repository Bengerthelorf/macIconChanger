---
title: 빠른 시작
section: guide
order: 1
locale: ko
---

## 요구 사항

- macOS 13.0 (Ventura) 이상
- 관리자 권한 (초기 설정 및 아이콘 변경에 필요)

## 설치

### Homebrew (권장)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### 수동 다운로드

1. [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest)에서 최신 DMG를 다운로드합니다.
2. DMG를 열고 **IconChanger**를 응용 프로그램 폴더로 드래그합니다.
3. IconChanger를 실행합니다.

## 첫 실행

처음 실행하면 IconChanger가 일회성 권한 설정을 완료하라는 메시지를 표시합니다. 이는 앱 아이콘을 변경하기 위해 반드시 필요합니다.

![첫 실행 설정 화면](/images/setup-prompt.png)

설정 버튼을 클릭하고 관리자 비밀번호를 입력하세요. IconChanger가 필요한 권한(헬퍼 스크립트에 대한 sudoers 규칙)을 자동으로 구성합니다.

::: tip
자동 설정에 실패하면 [초기 설정](./setup)에서 수동 설정 방법을 확인하세요.
:::

## 첫 아이콘 변경

1. 사이드바에서 앱을 선택합니다.
2. [macOSicons.com](https://macosicons.com/)에서 아이콘을 검색하거나 로컬 이미지 파일을 선택합니다.
3. 아이콘을 클릭하여 적용합니다.

![메인 인터페이스](/images/main-interface.png)

이것으로 끝입니다! 앱 아이콘이 즉시 변경됩니다.

## 다음 단계

- [API 키 설정](./api-key)으로 온라인 아이콘 검색 활성화
- [앱 별칭 알아보기](./aliases)로 더 나은 검색 결과 얻기
- [백그라운드 서비스 설정](./background-service)으로 자동 아이콘 복원 구성
- [CLI 도구 설치](/ko/cli/)로 명령줄에서 사용