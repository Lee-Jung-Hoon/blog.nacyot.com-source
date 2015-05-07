---
title: 페코(Peco) 이해하기 - Peco를 활용한 명령어 히스토리 증분 검색
date: 2015-04-15 10:30:00 +0900
author: nacyot
tags: 
published: false
---

[페코(Peco)][peco]는 데이터 필터링을 도와주는 간단한 명령행 도구이다. 같은 목적으로 만들어진 파이썬 기반 [Percol][percol]이라는 툴이 있었으나, 바이너리 형식으로 어디서든 쉽게 활용할 수 있도록 이를 Go로 재구현한 도구이다. 일반적으로 Peco에 파이프로 데이터를 넘겨주면, 이를 쉽게 필터링할 수 있도록 만들어진 검색 인터페이스를 사용할 수 있다. 이 글에서는 Peco의 기본적인 기능에 대해서 소개하고 명령어 히스토리와 연동해서 활용하는 방법에 대해서 소개한다.

[percol]: https://github.com/mooz/percol
[peco]: https://github.com/peco/peco

<!--more-->

## Peco 설치하기

Peco 릴리즈 페이지에서는 플랫폼 별로 실행가능한 바이너리 파일을 압축파일 형태로 제공한다. 이를 다운받아 적절한 위치에 압축을 풀어서 사용하면 된다. 예를 들어 Mac OS X를 사용하고 있다면 다음과 같이 실행한다.

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

## 셸과 함께 사용하기

## Peco를 활용한 디렉터리 이동 스크립트 만들기


## 기본 셸의 히스토리 검색 기능 Peco로 대체하기

### zsh 스크립트
### bash 스크립트
