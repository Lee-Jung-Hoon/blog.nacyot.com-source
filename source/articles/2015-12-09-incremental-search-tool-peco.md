---
title: 증분검색을 통한 텍스트 필터링 도구 페코(Peco) - 명령어 히스토리를 비롯한 셸(shell) 어디서나 증분검색하기
date: 2015-12-09 10:40:00 +0900
author: nacyot
tags: software, peco, shell, incremental_search, percol, zsh, bash, command_history, firefox, go
categories: software
title_image: http://i.imgur.com/XKk4660.png
published: true
---

셸(shell)은 매력적인 도구이지만, 많은 사람들에게 원시적인 도구로 오해받곤 한다. CLI의 대표적인 원시성으로는 각각의 프로그램들이 개별적으로 사용자와 대화하는 대신, 셸을 통해서만 명령이 가능하다는 점을 들 수 있다. 하지만 이러한 점은 커다란 장점이 되기도 한다. 예를 들어 프로그램들이 `STDIN`과 `STDOUT`만으로 데이터를 주고받을 수 있다. 또한 셸 인터페이스의 개선이 모든 프로그램의 사용성 개선과 직결되기도 한다. 애플리케이션의 단절을 전제로 하는 GUI에서는 이러한 장점을 누리기 어렵다.

페코(Peco)는 특히 인터페이스를 개선해주는 후자에 해당하는 도구이다. 페코는 개별적으로 사용가능한 인터렉티브 데이터 필터링 도구인 동시에, 셸과 함께 사용하면 셸의 사용성을 개선할 수 있다. 이 글에서는 페코의 기본적인 사용법과 셸의 히스토리 검색과 결합해서 사용하는 방법에 대해서 알아본다.

<!--more-->

## 페코(Peco) - CLI 증분검색도구

[페코(Peco)][peco]는 강력한 데이터 필터링 도구이다. 달리 말해서 텍스트 증분검색을 통한 필터링 도구라고 할 수도 있다. 원래 같은 목적으로 만들어진 파이썬 기반의 [Percol][percol]이라는 도구가 있었으나, 성능이나 멀티 플랫폼 지원을 위해 lestrrat 씨에 의해 고 프로그래밍 언어(Go)로 재구현되었다. 이를 통해 파이썬 없이도 바이너리를 통해 윈도우/리눅스/OSX에서 바로 사용할 수 있다.

[percol]: https://github.com/mooz/percol
[peco]: https://github.com/peco/peco

이미 익숙할 사람도 있겠지만 있지만 증분검색(Incremental Search)라는 단어가 낯설게 느껴질 수도 있다. 먼저 증분검색이 무엇인지부터 살펴보고 가자. 증분검색도 검색 방법의 하나이다. 좀 더 구체적인 사례를 들자면 증분검색은 키워드를 통해서 검색 결과를 얻는 것보다는 키워드를 입력하는 과정에서 검색엔진이 입력에 따라 보여주는 자동완성 결과가 있다. 즉, 검색어를 입력하는 과정에서 점진적으로 검색을 수행하는 방법을 이야기한다. 예를 들어 최종적으로 `apple`라는 검색을 하기 위해서 a를 먼저 입력한다. 그러면 a에 매칭이 되는 모든 단어가 검색이 된다. 다음으로 ap를 입력하면 ap에 매칭이 되는 모든 단어가 검색이 된다.

증분검색은 이미 널리 사용되고 있으며, 좋은 인터페이스의 대표적인 사례로 꼽힌다. 검색어 자동완성과 애플리케이션 런처는 물론 대부분의 웹브라우저와 텍스트 에디터들이 이러한 기능을 지원하고 있다. 웹브라우저에서는 파이어폭스가 선구적으로 이러한 기능을 지원했다. 웹 페이지 상에서 찾기 도구를 사용하면 사용자의 입력에 따라 웹 페이지에서 매치하는 모든 부분이 하이라이트된다. 이 기능이 얼마나 강력하냐면, 필자를 비롯해 단지 이러한 기능 때문에 파이어폭스를 사용하는 사람들이 있었을 정도다. 이해를 돕기 위해 간단한 예제를 보고 넘어가자.

![파이어폭스 - 에 증분검색](http://i.imgur.com/MrqjF6Y.png)

![파이어폭스 - 에서 증분검색](http://i.imgur.com/EyPs1BM.png)

이러한 검색 방법은 디지털 매체에서 글을 읽는 방법 자체를 바꿔놓을 정도로 강력하다. Peco는 바로 이러한 증분검색을 통한 텍스트 검색과 필터링을 셸에서 사용하도록 지원해준다.

그럼 이제 직접 설치하고, 사용해보자.

## 설치

[Peco 릴리즈 페이지][release]에서는 플랫폼 별로 실행가능한 바이너리 파일을 압축 파일 형태로 제공한다. 이를 다운받아 적절한 위치에 압축을 풀어서 사용하면 된다. 예를 들어 Mac OS X를 사용하고 있다면 다음과 같이 설치한다(어디서든 경로 지정없이 실행하고 싶다면 `$PATH` 상의 디렉터리로 적절히 복사하거나 링크를 걸어야한다).

[release]: https://github.com/peco/peco/releases

```
$ cd /tmp/
$ wget https://github.com/peco/peco/releases/download/v0.3.5/peco_darwin_amd64.zip
$ unzip peco_darwin_amd64.zip
```

이 외에도 OS X의 brew나 윈도우즈의 choco와 같은 패키지 관리자를 사용한 설치도 지원하고 있다.

```
# Mac OS X
$ brew tap peco/peco
$ brew install peco

# Windows
c:\> choco install peco
```

설치가 정상적으로 끝났다면, 명령어가 있는지 확인해보자.


```
$ peco --version
peco: v0.3.5
```

## 기본적인 사용법

페코는 표준 출력을 넘겨받아서 증분검색을 해준다. 예를 들어 OSX의 시스템 로그를 출력해서 페코에 넘겨줄 수 있다.

```
$ cat /var/log/systom.log | peco
```

실행하면 다음과 같은 화면을 볼 수 있다. 이 상태에서 글자를 입력하면 증분검색을 해나간다. 다음과 같이 글자를 완성해나감에 따라 조금씩 검색이 되는 것을 볼 수 있다.

![Peco 실행](http://i.imgur.com/M99a3Av.png)

![Peco - fi 검색](http://i.imgur.com/egjdr3n.png)

![Peco - firefox 검색](http://i.imgur.com/PVjNj8Q.png)

여러 키워드를 동시에 검색하는 것도 가능하다.

![Peco - 다중 키워드 검색](http://i.imgur.com/bAcyPpH.png)

또한 ctrl + r 키로 검색 모드를 바꿀 수 있다. 검색 모드로는 IgnoreCase, CaseSensitive, SmartCase 등을 지원하며, Regexp 모드에서는 정규표현식을 사용할 수 있다.

![Peco - 정규표현식 검색](http://i.imgur.com/uvvaPUh.png)

이런 식으로 로그를 빠르고 쉽게 필터링할 수 있으며, 최종적으로 원하는 결과를 선택하면 표준출력으로 출력해준다.

## ps로 프로세스 찾아서 종료하기

peco로 필터링된 결과를 다른 프로세스의 표준입력으로 넘겨줄 수 있다. 이를 통해서 다양한 작업이 가능하다. 다음 예제는 peco로 원하는 프로세스를 찾아서 프로세스 ID를 출력하는 예제이다.

```
$ ps -ef | peco | awk '{ print $2 }'
```

![Peco - 프로세스 탐색](http://i.imgur.com/8JzE1AO.png)

chorme 프로세스들을 검색해본다.

![Peco - chrome 검색](http://i.imgur.com/4n5caT3.png)

ctrl + space로 다중 선택을 할 수 있다.

![Peco - 다중 선택](http://i.imgur.com/dVh3BFd.png)

다중 선택이 된 상태에서 엔터를 누른다.

![Peco - 실행 결과](http://i.imgur.com/Sbz1kgS.png)

다음과 같이 선택한 프로세스 ID 값들이 출력된 것을 알 수 있다. 그럼 프로세스 종료까지 하려면 어떻게 해야할까? 이렇게 선택한 값들을 `kill` 명령어의 인자로 넘겨주면 된다.

```
$ ps -ef | peco | awk '{ print $2 }' | xargs kill
```

## 페코를 통한 명령어 히스토리 검색

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">bash에서 Ctrl-R을 누르면 이전에 입력했던 명령어 중에 prefix 검색을 할 수 있다. 이거 알고 나서 삶이 많이 편해졌음</p>&mdash; Taeho Kim (@needkoolquality) <a href="https://twitter.com/needkoolquality/status/662967984093200385">2015년 11월 7일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">In bash, &#39;ctrl-r&#39; searches your command history as you type (여태 이걸 몰랐다.)</p>&mdash; Park Jinwoo (@park_jinwoo) <a href="https://twitter.com/park_jinwoo/status/486780447951572992">2014년 7월 9일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">bash &lt;CTRL-R&gt; 이 좋은 걸 이제 알다니..</p>&mdash; Namhoon Kim (@yanhkim) <a href="https://twitter.com/yanhkim/status/480955791931752449">2014년 6월 23일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">유닉스 사용자를 위한 팁 : bash 에서 ctrl + R 을 누르면 command를 history에서 인터랙티브하게 찾을 수 있다. reverse-i-search 라고 함. 진작에 알았으면 좋았을 걸 -_-</p>&mdash; Park, SeongHoon (@replicax) <a href="https://twitter.com/replicax/status/22244837325">2010년 8월 27일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">유닉스 터미널에서 ctrl+r하니까 신세계가!</p>&mdash; 의심의 눈 (@Daliot) <a href="https://twitter.com/Daliot/status/508955885838675969">2014년 9월 8일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

`reverse-i-search`가 좋다는 간증은 여기저기서 볼 수 있습니다만... 페코는 더더더더 개에에엥장합니다.

ctrl + r 기본 기능 대신에 페코로 명령어 히스토리를 검색에 사용하고, 선택한 명령어를 바로 실행할 수 있다.

### OSX zsh에서 페코로 명령어 히스토리 검색하고 실행하기

여기서는 [uchiko 님의 스크립트](http://qiita.com/uchiko/items/f6b1528d7362c9310da0)를 사용한다. 이 스크립트는 zsh과 oh-my-zsh을 지원한다. 다음 스크립트를 `source`에 넘겨주면 작동한다. (셸에 익숙하지 않은 사람들을 위해 좀 더 친절하게 설명하자면, 아래 스크립트를 `~/.zsh/peco-history.zsh`로 저장한다음 `~/.zshrc` 파일 마지막에 `source ~/.zsh/peco-history.zsh`을 추가하고 셸을 재실행하면 적용될 것이다)

```
# from http://qiita.com/uchiko/items/f6b1528d7362c9310da0 by uchiko

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history
```

이제 ctrl + r을 누르면 단순 prefix 검색 대신 이전에 사용했던 명령어를 필터링할 수 있는 peco가 실행된다. 이 글을 작성하면서 입력했던 명령어들이 보인다.

![](http://i.imgur.com/lk83q8j.png)

나는 머리가 나빠서 docker 같이 긴 명령어는 못 외운다. 적당히 기억을 더듬어 이전에 실행했던 redis 이미지 사용법을 증분검색해본다(이 화면은 뜨지 않을 것입니다. 이 명령어는 제가 이전에 실행을 했던 명령어입니다)

![](http://i.imgur.com/sPl6nA5.png)

빙고! 이걸 선택하면 이 명령어를 바로 실행할 수 있다.

![](http://i.imgur.com/7ck36vT.png)

멋져라!

### OSX bash에서 명령어 히스토리 검색하고 실행하기

bash에서는 [yungsang 님의 스크립트](http://qiita.com/yungsang/items/09890a06d204bf398eea)를 사용하면 편리하다. zsh과 마찬가지로 정상 작동되는 것으로 확인 완료.

```
# from http://qiita.com/yungsang/items/09890a06d204bf398eea by yungsang

export HISTCONTROL="ignoredups"
peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi

    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}
bind '"\C-r":"peco-history\n"'
```

### 셸 히스토리 설정에 대한 작은 팁

페코와 명령어 히스토리의 조합은 명령어 암기보다 느슨한 연상을 통한 점진적 학습을 도와준다. 여러 명령어를 활용하고, 시도하고, 공부하는 동안에 명령어나 옵션을 완전히 외우지 않더라도 증분검색을 통해서 내가 입력했던 명령어들을 찾아갈 수 있는 것이다. 이러한 접근을 지원하기 위헤서 미리 셸 히스토리 저장 개수를 늘려놓으면 좋다. zsh에서는 `~/.zshrc`에 다음 두 행을 추가한다.

```
HISTSIZE=100000000
SAVEHIST=100000000
```

bash에서는 `~/.bashrc`에 다음 두 행을 추가한다.

```
export HISTFILESIZE=
export HISTSIZE=
```

## 결론

<blockquote class="twitter-tweet" lang="ko"><p lang="ko" dir="ltr">한국어로 된 percol 소개 문서가 하나도 없다니!</p>&mdash; nacyot (@nacyo_t) <a href="https://twitter.com/nacyo_t/status/476909836181835777">2014년 6월 12일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

(percol/peco 글을 쓰려고 한지 1년 넘게 걸린 것 같은... 기분 탓)

개인적으로 증분검색 인터페이스를 정말 좋아한다. 파이어폭스의 검색 기능도 정말 충격적이었고, OSX의 스팟라이트를 비롯한 다양한 런처들, 그리고 Emacs의 명령어 인터페이스 확장(anything, helm)들은 한 번 써보면 절대로 버릴 수 없다. 그 이유는 이러한 인터페이스가 정확한 기억에 의존하기보다 지속적인 학습을 통한 느슨한 연상을 활용하기 때문이다. 사람마다 다르겠지만 Emacs 사용자라고 단축키 수백개씩 외우거나 하진 않는다. 오히려 이런 인터페이스가 없는 GUI 도구들이 훨씬 더 정확한 기억에 의존한다. Peco는 이러한 이 매력적인 증분검색 인터페이스를 셸 위에서 사용할 수 있도록 구현한 도구이다. 

이 글에서는 Peco의 정말 간단한 사용법만을 소개했다. 그럼에도 그 강력함이 충분히 전달되었을 것이다(희망사항). [peco/peco](https://github.com/peco/peco)에 가면 더욱 다양한 예제와 기능들에 대한 설명을 찾아볼 수 있다. Peco는 기본적으로 표준 입출력을 활용한 도구이기 때문에 파이프라는 셸의 철학에도 잘 부합하고 입출력을 주고받는 곳에서라면 어디에서라도 활용 방법은 무궁무진하다.
