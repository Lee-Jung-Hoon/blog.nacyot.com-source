---
title: 리눅스에서 터미널과 클립보드 연동하기 - Xclip과 Tmux
author: nacyot
date: 2014-07-30 00:25:00 +0900
published: true
tags: pbcopy, xsel, xclip, copy_and_paste, terminal, tmux, software
categories: software
title_image: http://i.imgur.com/UJS03nS.jpg
---

[[터미널|terminal]] 환경과 GUI 환경은 대개 상당히 동떨어진 환경으로 이 둘을 스무스하게 연동하는 것은 작업환경을 갖추는 데 있어서 중요한 주제 중에 하나이다. 이 연결고리가 잘 연결되어있어야 작업 효율도 올라간다. 이 글에서는 [[Xclip]]를 통해서 터미널 환경의 문자열을 리눅스 GUI 환경의 클립보드로 복사하는 법과 [[Tmux]]의 복사 모드와 Xclip을 연동하는 법을 알아본다.

<!--more-->

## Xclip

### Xclip 설치

[[Ubnutu]]에서 Xclip는 아래 명령어로 설치할 수 있다.

```
$ apt-get install -y xclip
```

정상적으로 설치가 되었는지 확인해본다.

```
$ xclip -version
xclip version 0.12
Copyright (C) 2001-2008 Kim Saunders et al.
Distributed under the terms of the GNU GPL
```

버전 정보가 정상적으로 출력된다면 정상적으로 설치된 것이다.

### Xclip으로 복사하기

Xclip의 기본적인 사용법은 간단하다. 리눅스 커맨드의 출력 결과를 파이프라인으로 넘겨주면 Xclip이 그 결과를 GUI 환경의 클립보드에 저장해준다. 예를 들어 `date` 명령어를 사용하면 아래와 같이 출력된다.

```
$ date
Tue Jul 29 23:35:59 KST 2014
```

터미널 어플리케이션마다 약간의 차이는 있지만 보통 이러한 출력을 복사하기 위해서는 마우스로 문자열을 선택하고 복사를 하거나 그것도 잘 안 되면 마우스 오른쪽 버튼을 눌러서 컨텍스트 메뉴에서 복사하기를 클릭해줘야한다.

같은 상황에서 `date`의 출력을 복사할 때 xclip을 사용하면 아래의 명령어를 실행하면 된다.

```
$ date | xclip -selection clipboard
$
```

복사가 잘 되었는지 GUI 에디터에서 Ctrl + v 로 복사해보자.

![Copy & Paste](http://i.imgur.com/FPZg8Fy.png)
<p class="shape-title">Copy & Paste</p>

정상적으로 출력되는 것을 알 수 있다. 표준 출력의 내용을 파이프로 넘겨주기만 하면 복사가 이뤄지므로 훨씬 더 다양한 활용이 가능하다. 예를 들어 시스템 정보를 출력해서 바로 클립보드로 보낼 수도 있고, `cat`과 함께 사용하면 아주 킨 파일을 바로 클립보드로 보낼 수도 있다.

```
$ cat /var/log/syslog | xclip -selection clipboard
```

클립보드가 훨씬 더 강력해질 것이다.

계속 긴 옵션을 사용하는 것은 귀찮은 일이므로 alias를 사용하면 더 편리하게 사용할 수 있다. 필요한 경우 alias 셸 설정(~/.zshrc 등)에 포함시킨다.

```
$ alias copy='xclip -selection clipboard'
$ cat /var/log/syslog | copy
```

#### Xclip 함정(?)

몇몇 예제에서는 `-selection clipboard` 옵션 없이 xclip을 사용하기도 하는데 이렇게 사용할 때는 조심할 필요가 있다. X11의 클립보드는 하나가 아니다. 분명 위의 옵션을 명시적으로 주지 않아도 복사는 일어난다.

```
$ date | xclip
$
```

분명히 정상적으로 복사되었지만 아마 일반적으로 Ctrl + v 키로 복사한 내용을 가져오지 못 할 것이다. 이렇게 복사한 경우 마우스 가운데 버튼을 통해서 복사한 내용을 가져올 수 있다.

### Xclip으로 붙여넣기

GUI 클립보드의 내용을 표준 출력에 출력하는 것은 아래 명령어로 가능하다.

```
$ xclip -o
Tue Jul 29 23:35:59 KST 2014
```

## Tmux와 연동하기

Tmux는 다수의 셸을 동시에 띄워놓고 사용할 수 있는 도구이다. Tmux를 사용하면 세션을 통한 프로젝트 관리 등 더 많은 일을 할 수 있지만, 여기서는 간단히만 이해하고 넘어가자. Tmux에서는 터미널 어플리케이션의 스크롤 기능이 자체적인 출력 관리를 수행하며, Copy Mode를 통해서 이렇나 출력들에 대해서 이동하고 복사까지 할 수 있다.

먼저 복사 모드를 설명하기에 앞서 Tmux에서는 [[vi]]나 [[emacs]] 모드를 통해서 키 설정을 사용할 수 있다. 이 설정은 `~/.tmux.conf` 파일에 아래 옵션을 통해서 설정할 수 있다.

vi 모드를 사용하고자 하면 아래와 같이 설정한다.

```
set-window-option -g mode-keys vi
```

emacs 모드를 사용하고자 하면 아래와 같이 설정한다.

```
set-window-option -g mode-keys emacs
```

이제 복사모드를 사용해보자. Tmux 내에서 복사 모드는 `^b [` 키로 시작하고, `^b ]`로 종료한다. 복사 모드 내에서도 vi나 emacs 모드에 따라서 아래의 단축키들을 사용할 수 있다.

```
Function                vi             emacs
Back to indentation     ^              M-m
Clear selection         Escape         C-g
Copy selection          Enter          M-w
Cursor down             j              Down
Cursor left             h              Left
Cursor right            l              Right
Cursor to bottom line   L
Cursor to middle line   M              M-r
Cursor to top line      H              M-R
Cursor up               k              Up
Delete entire line      d              C-u
Delete to end of line   D              C-k
End of line             $              C-e
Goto line               :              g
Half page down          C-d            M-Down
Half page up            C-u            M-Up
Next page               C-f            Page down
Next word               w              M-f
Paste buffer            p              C-y
Previous page           C-b            Page up
Previous word           b              M-b
Quit mode               q              Escape
Scroll down             C-Down or J    C-Down
Scroll up               C-Up or K      C-Up
Search again            n              n
Search backward         ?              C-r
Search forward          /              C-s
Start of line           0              C-a
Start selection         Space          C-Space
Transpose chars                        C-t
```

여기까지는 좋으나, 여기서의 복사 기능은 GUI 환경의 클립보드를 의미하지 않는다. 이를 다시 옮기는 일은 번거로우므로 간단한 설정을 추가해 tmux의 복사를 자동적으로 클립보드로 옮겨줄 수 있다. 아래의 설정을 `~/.tmux.conf`에 추가해준다.

```
bind-key -t emacs-copy M-w copy-pipe "xclip -i -selection clipboard"
```

설정을 추가했으면 설정 파일을 아래와 같이 리로드하거나 tmux 서버를 재실행한다.

```
$ tmux source-file ~/.tmux.conf
```

이제 (Emacs 모드에서) Ctrl+Space로 필요한 영역을 선택한 후 M-w를 누르면 해당영역이 복사되고, 자동적으로 클립보드에도 복사된다.

## 정리

터미널 환경과 GUI 환경의 클립보드를 통합하면 매우 편리하다. 그리고 위에서는 간단히만 이야기했지만, 표준 출력으로 넘길 수 있는 모든 것이 클립보드에 복사될 수 있으므로 단순히 클립보드를 통합한다는 이상의 의미를 지닌다. 이는 셸에서 활용할 수 있는 다양한 스크립트와 출력들을 큰 어려움 없이 GUI 환경에 그대로 복사해 갈 수 있음을 의미한다. 또한 Tmux를 사용해 셸 화면을 직접 선택해 복사하는 방법도 보다 편리하게 사용할 수 있다. 

P.S. xclip과 비슷한 툴로는 xsel이 있으며, OSX에서는 pbcopy, pbpaste라는 명령어를 사용한다.

