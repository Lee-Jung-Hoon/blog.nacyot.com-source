---
series: Life on Shell #2
title: 페코(Peco) - 명령행 데이터 필터링 도구 / 페코를 활용한 명령어 증분 검색
date: 2015-04-15 10:30:00 +0900
author: nacyot
tags: 
published: false
---

[페코(Peco)][peco]는 셸의 강력함과 편의성을 모두 갖춘 데이터 필터링을 도와주는 간단한 명령행 도구이다. 같은 목적으로 만들어진 파이썬 기반 [Percol][percol]이라는 툴이 있었으나, 바이너리 형식으로 어디서든 쉽게 활용할 수 있도록 이를 Go로 재구현했다. 기본적으로 Peco에 파이프로 데이터를 넘겨주면, 이를 쉽게 필터링할 수 있도록 만들어진 검색 인터페이스를 사용할 수 있다. 이 글에서는 Peco의 기본적인 기능에 대해서 소개하고 몇 가지 활용법들에 대해서 소개한다.

[percol]: https://github.com/mooz/percol
[peco]: https://github.com/peco/peco

<!--more-->

## Peco 설치하기

[Peco 릴리즈 페이지][release]에서는 플랫폼 별로 실행가능한 바이너리 파일을 압축파일 형태로 제공한다. 이를 다운받아 적절한 위치에 압축을 풀어서 사용하면 된다. 예를 들어 Mac OS X를 사용하고 있다면 다음과 같이 실행한다.

[release]: https://github.com/peco/peco/releases

```
$ cd /tmp/
$ wget https://github.com/peco/peco/releases/download/v0.3.2/peco_darwin_amd64.zip
$ unzip peco_darwin_amd64.zip
$ ./peco_darwin_amd64/peco --version
peco: v0.3.2
```

이 외에도 OS X의 brew나 윈도우즈의 choco와 같은 패키지 관리자를 사용한 설치도 지원하고 있다.

```
# Mac OS X
$ brew tap peco/peco
$ brew install peco

# Windows
c:\> choco install peco
```

[release]: https://github.com/peco/peco/releases

## 기본적인 사용법

먼저 공식 저장소의 스크린샷을 살펴보자(공식 저장소에는 Peco 사용법을 보여주는 더 많은 스크린샷들이 있다.)

![Peco 스크린샷](https://camo.githubusercontent.com/6ed15cca08fd6972d12e67ee1f1fe84caa14744b/687474703a2f2f7065636f2e6769746875622e696f2f696d616765732f7065636f2d64656d6f2d70732e676966)

이 화면에서 실행한 명령어는 `ps aux | peco`이다. 셸에 익숙하다면 `ps aux`도 낯설지만은 않을 것이다. 이 명령어는 현재 컴포터에서 실행중인 모든 프로세스를 조금 자세하게 출력한다. 그리고 파이프를 통해서 `ps` 명령어에서 나온 출력을 `peco`로 넘겨준다. 그러면 `peco`이 이렇게 넘겨받은 프로세스 목록을 검색할 수 있도록 도와준다.

peco는 기본적으로 line-by-line으로 검색어에 대한 결과를 찾는다. 또한 스크린샷에서 알 수 있듯이 peco는 증분 검색을 통해서 입력에 대응하는 결과가 바로바로 보여지는 것을 알 수 있다. 더욱이 단순히 순차적인 문자열에 매치하는 것뿐만 아니라, line 상에서 어디에 글씨가 있곤 해당하는 단어들을 모두 포함한 라인을 찾아준다. 그리고 특정 항목을 선택하면 그 라인을 표준 출력으로 넘겨준다.

이러한 기본적인 활용법은 알고 있어도 peco를 활용하기에 충분하다. 프로세스 리스트를 필터링하는 것 이외에도, 텍스트 문서나 코드를 검색하고, 시스템 로그 파일을 검색하는 데도 활용할 수 있다.

## 셸과 함께 사용하기

## Peco를 활용한 디렉터리 이동 스크립트 만들기


## 기본 셸의 히스토리 검색 기능 Peco로 대체하기

### zsh 스크립트
### bash 스크립트
