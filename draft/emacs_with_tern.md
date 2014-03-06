이맥스(Emacs)에서 자바스크립트 코드 분석기(+ 자동 완성) Tern 사용하기

텍스트 에디터는 IDE에 비해서 매우 가볍고 편리한 기능들을 가진 도구입니다만 기능적인 면에서의 열세에 대해서 많이 이야기되곤 합니다. 특히 정적 분석을 통한 질 높은 자동 완성이 어렵다거나 하는 부분은 IDE 팬들에게서 오랫동안 질타받아온 부분이고, 사실 텍스트 에디터를 쓰는 사람 입장에서도 아쉬운 부분이기도 합니다. 이런 상황에서 텍스트 에디터를 사용하는 자바스크립트 개발자들에게 단비와 같은 프로그램이 바로 자바스크립트 코드 분석기 Tern입니다.

<!--more-->

Tern은 코드미러라는 에디터를 만들었던 Marijn Haverbeke의 또다른 작품으로 기본적로  자바스크립트 코드 분석기입니다. 하지만 이러한 코드 분석의 결과는 질높은 문법 체크 및 자동완성을 위해 사용될 수 있습니다. 특히 Tern은 특정 에디터에 종속되지 않는다는 점에서 봤을 때 마츠야마 토모히로 씨가 Emacs는 죽었다는 글에서 이야기했던 (이맥스 문화권에서 나오진 않았지만) ***외부 프로그램에 의한 잠재적인 사회적 가치를 극대화***해야한다는 사상에 정말로 잘 들어맞는 프로그램입니다. Tern은 어떤 에디터에 종속적이지 않습니다. Tern은 독자적인 서버로 실행되고, 에디터에서 보내오는 결과에 대한 적절한 분석결과를 되돌려 줄 뿐입니다. 리눅스에서 명령어들의 결과를 파이프라인으로 보내는데 익숙하다면 이러한 개념이 얼마나 합리적이고 적절히 확장 가능한지 이해할 수 있을 것입니다. 분석 결과는 에디터의 플러그인들이 적절히 처리해줍니다. 실제 Tern의 저장소에는 Emacs, Vim, Sublime Text를 플러그인으로 지원하고 있으면 Brackets과 Edge Code에서는 빌트인으로 지원하고 있다고 쓰여있습니다.

이 글에서는 그 중에서도 이맥스(Emacs)에서 Tern을 연동하고 사용하는 방법에 대해서 다루도록 하겠습니다.

## 설치

우선 Tern을 사용하기 위해서는 Tern을 설치해야할 필요가 있습니다. 먼저 npm을 사용해서 설치해보겠습니다.

```
$ npm install -g tern
npm http GET https://registry.npmjs.org/tern
npm http 200 https://registry.npmjs.org/tern
...
tern@0.5.0 /home/myhome/.nvm/v0.10.24/lib/node_modules/tern
├── acorn@0.4.2
├── glob@3.2.9 (inherits@2.0.1)
└── minimatch@0.2.14 (sigmund@1.0.0, lru-cache@2.5.0)
```

npm을 사용하는 게 가장 간단합니다만, npm을 사용할 수 없는 경우엔,

nodejs와 npm을 설치해주세요(...).

이제 그만 nodejs를 받아들이시기 바랍니다.


```
$ tern 
Listening on port 60805
```

이제 tern을 실행해보면 랜덤한 포트에서 tern이 실행되는 것을 알 수 있습니다.

## 이맥스 설정

Tern 설치가 되었다면 이제 이맥스와 연동을 해야합니다. Tern은 기본적으로 이맥스 24 이상을 지원하고 있습니다. 먼저 설치된 이맥스 버전을 확인해주시고, 필요한 경우 버전을 올려줍니다.

```
$ emacs --version
GNU Emacs 24.3.1
Copyright (C) 2013 Free Software Foundation, Inc.
GNU Emacs comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of Emacs
under the terms of the GNU General Public License.
For more information about these matters, see the file named COPYING.
```

또한 이맥스 24에는 강력한 패키지 관리자가 기본으로 포함되어있습니다.

```
M-x package-install <enter> tern <enter>
M-x package-install <enter> tern-auto-complate <enter>
```

만약 패키지를 찾을 수 없다면 `~/.emacs.d/init.el`이나 이에 해당하는 사용하고 있는 이맥스 설정 파일에 다음 내용을 추가합니다.

```lisp
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
```

다시 위로 돌아가 package-install을 하면 정상적으로 설치가 가능할 것입니다. 만약 이래도 패키지가 뜨지 않는다면 Tern 저장소의 내용을 클론해서 이맥스 디렉토리 아래의 el들을 `.emacs.d` 디렉토리 아래로 복사합니다.