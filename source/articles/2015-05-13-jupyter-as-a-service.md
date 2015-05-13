---
title: "맥에서 서비스 등록하기 - 주피터(Jupyter, IPython >= 3) 노트북 서비스 등록 예제"
date: 2015-05-13 10:13:00 +0900
author: nacyot
tags: jupyter, service, osx
published: true
---

아주 자주 사용하는 프로그램은 컴퓨터가 켜져있으면 어김없이 실행된다. 그래서 사용자들은 보통 이러한 프로그램을 시작 프로그램에 등록해서 사용하곤 한다. 이러한 프로그램이 백그라운드 작업을 하는 프로그램이거나 서버 프로그램이라면 매번 터미널을 열어서 실행한다는 것이 여간 번거로운 일이 아닐 것이다. 맥 OSX에서도 이와 같은 상황을 겪을 수 있는데, 적절히 커스텀 서비스를 등록해 이러한 번거로움을 피해갈 수 있다. 이 글에서는 [Jupyter Notebook][jupyter]을 예제로 OSX 서비스 등록과 간단한 조작법에 대해서 살펴본다.

[jupyter]: http://www.jupyter.org/

<!--more-->

## Jupyter Notebook 서비스 등록 예제

이 글에서는 Jupyter(IPython) Notebook을 예제로 소개한다. IPython은 파이썬 REPL의 확장으로 웹 기반의 노트북을 지원한다. 이는 서버로 작동하는데, 데스크탑에서 사용하는 경우 매번 서버를 실행해줘야하는 번거로움이 있다. 여기서는 로컬 환경에서 실행되는 Jupyter Notebook을 서비스로 만들어서 항상 `http://localhost:8888`로 접근 가능하도록 만든다.

### Jupyter Notebook

먼저 Jupyter Notebook을 사용가능한 환경을 준비한다(기본적으로 설치된 파이썬을 이용하거나 필요하면 [pyenv] 등을 이용해 적절한 환경을 구축한다. 파이썬 > 3, 아이파이썬 > 3를 추천한다). 

[pyenv]: https://github.com/yyuu/pyenv

```
$ brew install zeromq
$ pip install ipython[notebook]
$ ipython notebook
[I 01:30:10.061 NotebookApp] Using MathJax from CDN: https://cdn.mathjax.org/mathjax/latest/MathJax.js
[I 01:30:10.117 NotebookApp] Serving notebooks from local directory: /Users/toto/Library/LaunchAgents
[I 01:30:10.118 NotebookApp] 0 active kernels
[I 01:30:10.118 NotebookApp] The IPython Notebook is running at: http://localhost:8888/
[I 01:30:10.118 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

이제 `localhost:8888`로 노트북 서버에 접근가능하다.

![Jupyter(IPython) Notebook](http://imgur.com/rbIGYXi)

### LaunchAgent 서비스 파일 준비하기

먼저 `~/Library` 디렉터리 아래에 `LaunchAgents` 디렉터리가 있는 지 확인한다. 그리고 `com.jupyter.server.plist` 파일을 생성해준다.

```
$ mkdir -p ~/Library/LaunchAgents/
$ touch com.jupyter-python3.server.plist
```

`com.jupyter.server.plist` 파일에 다음과 같이 추가한다.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>KeepAlive</key>
    <true />
    <key>RunAtLoad</key>
    <true/>
    <key>Label</key>
    <string>com.jupyter.server</string>
    <key>ProgramArguments</key>
    <array>
      <string>/your/ipython/path</string>
      <string>notebook</string>
      <string>--ip=0.0.0.0</string>
      <string>--port=8888</string>
      <string>--notebook-dir=/your/notebook/path</string>
    </array>
  </dict>
</plist>
```

이 설정에서 `/your/ipython/path`와 `/your/notebook/path`는 직접 자신이 사용하는 디렉터리로 지정해야한다. `/your/ipython/path`는 `which ipython` 명령어로 위치를 확인할 수 있고, `your/notebook/path`는 앞으로 작성하게 될 노트북을 디렉터리를 원하는 곳에 생성하고 그 경로를 지정해준다.

다음으로 서비스를 등록(load)한다.

```
$ launchctl load ~/Library/LaunchAgents/com.jupyter.server.plist
```

> 단, launchctl은 tmux와 같은 터미널 멀티플렉서 환경에서는 정상적으로 실행되지 않는 경우가 있으니, 기본 터미널에서 사용하는 것이 좋다.

여기까지 정상적으로 설정했다면 이제 시스템이 실행될 때 자동적으로 서비스를 실행할 것이다.

### 서비스 실행하기

```
$ launchctl start com.jupyter.server
```

위 설정의 경우, `RunAtLoad` 키를 통해서 로드 시에 서비스를 자동 실행한다. 필요한 경우 launchctl을 통해서 직접 서비스를 실행할 수도 있다. 서비스를 실행하면 웹페이지가 직접 기본 브라우저로 실행된다. 그렇지 않다면 웹브라우저에서 `http://localhost:8888`로 접근할 수 있다.

### 서비스 중지하기

```
$ launchctl stop com.jupyter.server
```

launchctl을 통해서 서비스를 중지할 수 있다(자동으로 실행되지 않게하려면 unload 후 파일을 삭제해야한다). 단, 위와 같이 `KeepAlive`가 설정되어 있으면 종료되도 다시 실행된다.

## 결론

이 글에서는 Jupyter Notebook을 서비스로 등록해서 사용하는 법에 대해서 살펴보았다. 하지만 서비스 파일의 기본적인 구조만 익혀둔다면, 이외에도 다양한 서비스들을 직접 정의해서 편리하게 사용할 수 있을 것이다. 더불어 OSX의 서비스는 실행 상태 유지(`<key>KeepAlive</key>`), 로드 시 실행하기(`<key>RunAtLoad</key>`), 반복 실행(`<key>StartInterval</key>`), 표준 출력(`<key>StandardOutPath</key>`), 표준 에러(`<key>StandardErrorPath</key>`) 리다이렉트 등 더 다양한 설정들도 지원한다. 자세한 내용은 다음 페이지를 참조하기 바란다.

[Apple Developer - Daemons and Services Programming Guide][daemon]

[daemon]: https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
