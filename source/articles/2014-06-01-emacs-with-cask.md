---
title: "캐스크(Cask)로 이맥스(Emacs) 환경설정 관리하기"
date: 2014-06-01 23:30:03 +0900
author: nacyot
published: true
---

얼마 전 [Cask 공식 문서를 한국어로 번역][cask]해서 공개한 바 있다. Cask는 기본적으로 개발중인 패키지의 의존성을 관리하기 위한 툴이다.

Emacs24부터는 기본적으로 패키지 관리자가 포함되어있지만, 이를 통해서 설치되는 패키지는 전역적으로 설치된다. 이러한 방식은 편리하지만, 각각의 프로젝트에게는 섬세하지도, 적절하지도 않다. Emacs24의 기본 패키지 관리자는 루비와 비교하면 Gem에 해당한다. 루비에서 Cask의 역할은 Gem이 아니라 Bundler의 역할과 같다. Cask는 각 패키지의 의존성을 패키지 단위로 관리해주고, 패키지나 Emacs를 해당하는 의존성을 바탕으로 실행할 수 있도록 도와주는 도구이다.

<!--more-->

Cask는 이러한 의존성 관리를 크게 두 방향에서 사용할 수 있도록 해준다. 먼저 하나는 Bundler와 같이 프로젝트 단위로 자신의 의존성을 정의하고 프로젝트를 개발할 수 있는 환경을 만들어주는 역할이다. 두번째는 Emacs를 에디터로 사용하는 사람들의 입장에서 패키지들을 체계적으로 관리할 수 있게 도와준다. 이 글에서는 Cask를 통해서 Emacs 환경 설정을 관리하는 방법에 대해서 다룬다.

## Cask 설치

(참고: Cask는 Emacs24 이상에서만 사용가능하다) Cask는 아래 명령어로 설치할 수 있다. 시스템에 파이썬이 설치되어있어야한다.

```
$ curl -fsSkL https://raw.github.com/cask/cask/master/go | python
```

Mac에서 Homebrew를 사용하고 있다면 brew 명령어를 사용해서 설치하는 방법도 있다.

```
$ brew install cask
```

정상적으로 설치되었는지 확인해본다.

```
$ cask --version
0.7.0
```

## Cask 사용해보기

본적적인 `.emacs.d` 환경설정에 앞서 cask를 간단히 사용해보자. 임의의 위치에 cask를 테스트해볼 디렉터리를 만든다. 여기서는 `~/tmp/cask`를 사용한다.

```
$ cd ~/tmp/cask
```

`init` 명령어를 통해서 기본 설정을 포함한 Cask 파일 생성할 수 있다.

```
$ cask init
$ head Cask
(source gnu)
(source melpa)

(depends-on "bind-key")
(depends-on "cask")
(depends-on "dash")
(depends-on "drag-stuff")
(depends-on "exec-path-from-shell")
(depends-on "expand-region")
(depends-on "f")
...
```

`head`로 초기화된 Cask 파일을 출력해보면 위와 같은 내용이 출력된다. Cask 파일에서 사용하는 명령은 기본적으로 `source`와 `depends-on` 함수이다. 일단 `source`는 패키지를 가져오는 저장소를 의미하고 `depends-on`은 사용하는 패키지를 정의한다는 정도만 이해하고 넘어간다.

이제 `cask` 명령을 통해서 의존성을 설치한다.

```
$ cask
Wrote /home/nacyot/Dropbox/programmings/sandbox/cask/.cask/24.3.1/elpa/archives/gnu/archive-contents
Wrote /home/nacyot/Dropbox/programmings/sandbox/cask/.cask/24.3.1/elpa/archives/melpa/archive-contents
```

의존성이 정상적으로 설치되었는지 살펴본다. 의존성은 기본적으로 cask 명령어를 실행한 위치의 Caskfile을 사용해서 설치되며, 설치 위치는 명령어를 실행한 디렉터리 아래의 `.cask`가 된다.

```
$ ls .cask/24.3.1/elpa/
archives                           flycheck-cask-20140118.923        popwin-20140426.659
bind-key-20140414.1744             git-commit-mode-20140313.1504     prodigy-20140421.2359
cask-20140324.15                   git-rebase-mode-20140313.1504     projectile-20140427.251
dash-20140407.253                  htmlize-20130207.1202             s-20131223.944
diminish-20091203.1012             idle-highlight-mode-20120920.948  shut-up-20140211.521
drag-stuff-20140121.723            magit-20140416.1539               smartparens-20140414.606
epl-20140405.51                    multiple-cursors-20140418.815     smex-20140425.1314
exec-path-from-shell-20140219.104  nyan-mode-20120710.2200           use-package-20140317.1213
expand-region-20140406.324         package-build-20140422.803        web-mode-20140425.1520
f-20140220.21                      pallet-20140413.1345              yasnippet-20140314.255
flycheck-20140422.657              pkg-info-20140405.50
```

정상적으로 설치된 것을 알 수 있다. 이제 이러한 패키지들을 바탕으로 emacs를 실행시켜보자.

```
$ cask exec emacs
```

이렇게 Emacs를 실행하면 기존의 설정에 추가적으로 현재 Cask 파일의 의존성이 로드된다.

## Cask를 활용한 Emacs 환경설정

여기까지 이야기한 내용은 실질적으로 특정 프로젝트에서 의존성을 관리하는 방법에 가깝다. 지금부터는 전역적인 Emacs 사용자 설정을 다룰 것이다.

Emacs23 이후 버전의 환경설정은 기본적으로 `~/.emacs.d/init.el` 파일을 거쳐서 실행된다. 따라서 먼저 Cask 초기화 코드를 이 파일에 추가해준다.

```
(require 'cask "~/.cask/cask.el")
(cask-initialize)
```

먼저 첫번째 줄에서는 앞서 설치한 `cask.el`을 로드한다. 로드 경로에서도 알 수 있듯이 cask는 기본적으로 홈 디렉터리 바로 아래의 `.cask`에 설치된다(다른 위치에 설치했다면 물론 해당하는 경로를 지정한다). 다음 줄에서는 `cask-initialize` 함수를 호출해 cask를 초기화한다. 이 때 cask를 환경설정에 대해서 초기화하기 위한 Cask 파일이 필요하다. 이 파일은 `~/.emacs.d/Cask`에 위치해야한다.

## Caskfile 살펴보기

여기서는 Cask 파일을 정의한다.

```
(source gnu)
(source melpa)
(source marmalade)

(depends-on "ruby-mode")
(depends-on "rspec-mode")
(depends-on "robe")
(depends-on "rinari")
(depends-on "magit" "0.8.1")
(depends-on "ox-reveal" :git "git@github.com:yjwen/org-reveal.git")
```

앞서도 이야기했지만 Caskfile에서 사용할 수 있는 기본적인 함수는 `source`와 `depends-on`이다. 다른 함수들도 있지만 일반적으로 환경설정을 위한 용도에서는 사용하지 않는다.

### source

먼저, source 함수는 패키지를 가져올 저장소를 지정하는 명령어로 아래와 같이 사용할 수 있다.

```
(source ALIAS)
(source NAME URL)
```

실제로는 아래와 같이 사용한다.

```
(source melpa)
(source "melpa" "http://melpa.milkbox.net/packages/")
```

패키지가 인식할 수 있는 ALIAS를 사용하면 URL을 지정하지 않아도 된다. 사용할 수 있는 ALIAS는 아래와 같다.

```
gnu (http://elpa.gnu.org/packages/)
melpa (http://melpa.milkbox.net/packages/)
marmalade (http://marmalade-repo.org/packages/)
SC (http://joseito.republika.pl/sunrise-commander/)
org (http://orgmode.org/elpa/)
```

gnu, melpa, marmalade는 주로 사용하므로 지정해두는 게 좋다.

### depends-on

`depends-on`은 사용하고자 하는 패키지를 지정하는 함수이다. 예를 들어 `ruby-mode` 패키지를 사용하고자 하면 아래와 같이 사용한다.

```
(depends-on "ruby-mode")
```

위와 같이 `ruby-mode`를 지정하면 위에서 source에서 지정한 저장소에서 해당하는 패키지를 찾아 설치한다. 이 때 필요한 경우 아래와 같이 특정 버전을 강제할 수 있다.

```
(depends-on "magit" "0.8.1")
```

기본 패키지 관리자에 비해서 가장 큰 장점 중 하나는 git로 관리되는 패키지를 직접 지정할 수 있다는 점이다. 아래는는 공식 문서에서 제공하는 예시이다. Git 저장소를 지정했을 때 특정한 커밋이나 브랜치, 혹은 특정 파일들만 로드할 수 있도록 하는 법을 알 수 있다.

```
(depends-on "magit" :git "https://github.com/magit/magit.git")
(depends-on "magit" :git "https://github.com/magit/magit.git" :ref "7j3bj4d")
(depends-on "magit" :git "https://github.com/magit/magit.git" :branch "next")
(depends-on "magit" :git "https://github.com/magit/magit.git" :files ("*.el" (:exclude "magit-svn.el")))
```

## cask

필요한 패키지 설정이 모두 끝났으면 작업 디렉토리를 `~/.emacs.d`로 옮겨서 `cask` 명령을 실행한다. 이를 통해서 지정한 패키지들을 모두 설치할 수 있다. 하나 알아둬야할 점은 명시적으로 cask 명령을 emacs 외부에서 실행하지 않으면 Emacs 실행 시 해당하는 패키지가 적용되지 않는다는 점이다.

추가적으로 모든 패키지를 업데이트하고자 할 때는 `cask update` 명령어를 사용한다.

## 기타 

### pallet 패키지(Emacs 안에서 패키지 관리)

> **주의** : pallet 명령어 사용시 Cask 파일이 변경되는 경우가 있다. 이 때 git 저장소를 지정해둔 정보가 삭제될 가능성이 있다. [Cask.diff][Cask.diff] 참조.

pallet 패키지와 함께 사용하면 좀 더 편리하게 사용할 수 있다. 예를 들어 `M-x pallet init` 명령어를 실행하면 현재 `package.el`로 설치된 패키지들을 Cask 파일에 입력해준다. 앞서 Cask 파일은 `cask install` 명령을 실행하지 않으면 바로 반영이 되지 않는다고 하였는데, pallet 패키지를 사용하면 Cask 파일을 수정하고, `M-x pallet-install` 명령어를 실행하면 바로 패키지가 설치된다. 또한 `M-x package-install`이나 `M-x list-packages` 명령어로 설치한 패키지들을 자동을 Cask 파일로 옮겨준다.

[Cask.diff]: https://gist.github.com/nacyot/2387fd61e203b30e5f57

### init-loader를 활용한 Emacs 초기화

앞서 이야기한 바와 같이 Emacs 초기화는 기본적으로 `init.el`을 거쳐가며 대부분의 설정파일은 여기에서 이루어진다. Cask 사용 시에도 Cask를 초기화하고, Cask를 통해 읽어들인 각 패키지에 대한 설정은 `init.el`파일에서 하면 된다. 하지만 이 역시 설정할 내용이 많을 때는 `init.el` 파일이 매우 복잡해지기 때문에 init-loader를 사용해 좀 더 편리하게 관리할 수 있다.

init-loader 패키지를 사용하려면 먼저 Cask 파일에 추가해준다.

```
(depends-on "init-loader")
```

`init.el`에는 아래 내용을 추가한다.

```
(init-loader-load "~/.emacs.d/init-loader/")
```

`init-loader-load`는 초기화 파일들을 위치시킬 디렉터리를 지정한다. 여기서는 `~/.emacs.d/init-loader`를 지정했으면 원하는 디렉터리를 지정하면 된다. 위와 같이 설정하면 init-loader은 해당하는 폴더 아래의 숫자 2개로 시작하는 모든 파일을 로드한다.

```
00_util.el
01_ik-cmd.el
21_javascript.el
99_global-keys.el
```

위와 같이 적절히 초기화 설정을 분리하면 된다. 일반적으로는 패키지 단위로 설정을 관리하는 게 좋다.

### 설정 파일 컴파일 하기

일반적으로 패키지는 설치과정에서 컴파일된다. 하지만 다른 설정 파일이 많아질 수록 Emacs 시작시간도 길어진다. 필요하다면 init-loader 폴더나 설정 파일을 보관하는 다른 폴더는 아래 명령어로 컴파일 해두는 게 좋다.

```
C-u 0 M-x byte-recompile-directory
```

## 결론

Emacs를 사용하기 어렵게 만드는 것 중 하나는 언제나 환경설정이었다. Emacs는 정말 방대한 툴이고, 그만큼 사람에 따라서 수십에서 심지어는 수백개 패키지를 사용하는 것도 이상하지 않다. 일반적으로 Emacs를 잘 사용한다는 데는 단순히 단축키를 수십개 더 외우고 있느냐 보다 이런 다양한 패키지들을 얼마나 잘 정리하고 활용하는 지가 중요하다. Cask 공식 문서를 보면 아마 대부분의 Emacs 사용자가 겪어왔을 기존의 패키지 관련 툴들에 관한 이야기가 나온다. El-get이 있었고, Emacs24에서 공식으로 포함된 package.el 같은 툴도 있었고, 그리고 저장소의 서브 모듈을 사용하는 방법이나 의존 패키지를 통째로 패키지에 포함해서 의존성을 정의하는 방법도 사용해왔다. 필자도 대부분의 방법을 경험했지만 결국엔 두손두발 다 놓게 만드는 게 Emacs 설정이다. elisp도 잘 모르고, 한 번 아무리 공을 들여서 설정해봤자, 시간이 지나면 역시 관리는 안 된다.

그런 와중에 Cask는 Emacs 사용자에게 단비와 같은 패키지이다. 아마.

## 참고자료

* [Cask 공식 문서][cask]
* [Cask - naoyaのはてなダイアリー][naoya]
* [Pallet][pallet]
* [netpyoung/.emacs.d][netpyoung]
* [nacyot/.emacs.d][nacyot]

[cask]: http://cask.emacs.kr/
[naoya]: http://d.hatena.ne.jp/naoya/20140424/1398318293
[netpyoung]: https://github.com/netpyoung/netpyoung.emacs.d
[nacyot]: https://github.com/nacyot/.emacs.d
