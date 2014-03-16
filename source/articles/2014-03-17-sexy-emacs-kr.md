---
title: "emacs.sexy 한글 번역 및 OmegaT + Travis + Rake + Github Pages를 활용한 번역"
date: 2014-03-17 00:20:00 +0900
author: nacyot
---

vim.sexy의 emacs판인 emacs.sexy를 번역했습니다. 저 또한 한 명의 행복한 이맥스 사용자이기에 >_<

<blockquote class="twitter-tweet" lang="ko"><p><a href="http://t.co/NrSRaEXMWO">http://t.co/NrSRaEXMWO</a> <a href="http://t.co/3YY2lCXkLd">http://t.co/3YY2lCXkLd</a> 한국어 번역</p>&mdash; nacyot (@nacyo_t) <a href="https://twitter.com/nacyo_t/statuses/445030787130200064">2014년 3월 16일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<!--more-->

## Github

특별한 건 없습니다만, 번역과 번역 저장소 관리에 대해서 조금 이야기를 해보자면 현재 sexy.emacs.kr은 두 개의 저장소에서 관리되고 있습니다.

하나는 번역 메모리 omegat의 프로젝트를 담은 

* https://github.com/nacyot/omegat-emacs.sexy

이고, 또 하나는 omegat-emacs.sexy에서 번역한 결과를 travis로 빌드해서 자동으로 push 되도록 설정해둔 

* https://github.com/nacyot/sexy.emacs.kr

입니다.

## OmegaT

개인적으로 번역 프로젝트에는 전부 OmegaT를 사용하고 있습니다.자바로 만들어진 번역 메모리로 기능적으론 굉장히 훌륭합니다. 특히 OmegaT는 문장 단위로 번역을 진행해서, 직접 원본 파일을 번역하는 것과 달리 원문의 업데이트에 비교적 쉽게 대응할 수 있습니다. 약간 번거롭고 저장소와 호환이 안 맞아서 한참 고생을 했는데, 최근에 활용 방향이 정리가 되서 베스트 프렉티스를 정리해보는 중입니다. 이에 대한 내용은 조만간 공유해 볼 예정입니다.

## Omegat + Travis

이번에 한 가지 시도해본 건 Travis를 통해 OmegaT의 프로젝트를 빌드하는 일입니다. OmegaT에서는 원본 문서를 편집하지 않고 Segment 단위로 한 문장(혹은 한 문단) 씩 번역을 진행합니다. 따라서 여기서 빌드란 OmegaT를 통해서 번역한 결과물을 실제 파일로 출력하는 과정을 말합니다. 로컬에서 번역을 진행하고 빌드 후 저장소를 올리는 것도 어렵지 않습니다만 신경써야할 부분이 하나 더 느는 문제가 있고, 또 하나는 커밋 단위로 빌드를 하고 싶었기 때문입니다. 이는 이 블로그나 위키에서도 마찬가지로 문서를 작성하면 자동적으로 Travis에서 Middleman 어플리케이션을 빌드하고 깃허브 저장소에 올리는 것과 마찬가지입니다. 즉, 이를 통해 OmegaT를 통한 번역작업과 Github 페이지를 통한 배포 작업을 하나의 트랜젝션으로 묶을 수 있습니다.

전체 스크립트는 [여기][travis]에 있습니다. 여기서 가장 중요한 두 명령어는 아래와 같습니다.

[travis]: https://github.com/nacyot/omegat-emacs.sexy/blob/master/.travis.yml

```yaml
before_install:
  - sudo apt-get install -qq openjdk-6-jdk omegat
script:
  - /usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java -jar /usr/share/omegat/OmegaT.jar . --mode=console-translate
```

첫번째 명령어는 `apt-get`으로 openjdk-6-jdk와 omegat를 설치합니다. 아래 명령어는 실제로 프로젝트를 빌드하는 명령어입니다. OmegaT를 설치하면 `omegat` 명령어를 사용할 수 있기는 합니다만, 이 명령어는 자바 버전에 의존적이라 `java`와 `omegat` 모두 강제로 경로를 지정해서 실행하고 있습니다.

이러한 작업을 할 때 OmegaT의 프로젝트 구조를 로컬에서와 같도록 최대한 보장해줄 필요가 있습니다. 예를 들어 과거 프로젝트에서 생성한 번역 메모리를 재활용할 수 있게 도와주는 `/tm/auto` 디렉토리는 실제론 필요가 없지만, 빌드 시에 없으면 프로젝트를 인식하지 못 합니다. `target` 디렉토리는 빌드 결과가 출력되는 디렉토리인데 자동으로 생성해주지 않기 때문에, 빈 디렉토리라도 생성해두지 않으면 빌드에 실패합니다. 이 외에 `glossary`, `dictionary`, `source`도 정상적으로 프로젝트 디렉토리 안에 생성되어 있어야합니다.

OmegaT의 경우 `apt-get`으로 설치하면 상당히 구버전이 설치됩니다. 저 같은 경우는 번역에 3버전을 사용하고 있는데, 빌드 과정에서 특별한 문제점은 없었습니다. 만약 `apt-get`으로 설치하는 버전을 사용하기가 어렵다면 별도로 프로젝트에 OmegaT를 집어넣거나, wget으로 소스포지에서 다운로드해야합니다.

<blockquote class="twitter-tweet" lang="ko"><p><a href="https://twitter.com/marocchino">@marocchino</a> 아... 빌드에서 사용할 파일 따로 가져올 방법이 없어서 압축해서 포함시키려고 했는데 100mb 넘는다고 안 들어가더군요 ㅎㅎ. 좋은 접근은 아니었죠 ㅜ</p>&mdash; nacyot (@nacyo_t) <a href="https://twitter.com/nacyo_t/statuses/444838462277967873">2014년 3월 15일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

이건 비밀입니다만(...) 처음에는 직접 OmegaT의 최신 버전을 프로젝트에 집어넣고 빌드 과정에서 압축을 풀어 사용하려고 했습니다. 하지만 Github 저장소에는 100mb 이상의 파일을 넣을 수 없다는 사실을 처음 알았습니다.

이렇게 100mb 넘는 파일을 추가하고 Github에 올리기 위해선 커밋 히스토리 자체를 삭제할 필요가 생기는데 아래 명령어를 사용할 수 있습니다.

```
git filter-branch --tree-filter 'rm -rf path/to/your/file' HEAD
```

## Rake

빌드 과정에서 몇 가지 rake 작업이 이루어집니다. OmegaT를 사용한 번역에서는 원본 파일을 직접 수정하지 않고, 문장들만을 번역합니다. 따라서 원칙적으로 원본 파일은 건드리지 않고 작업을 하기 위해서 빌드된 결과물을 rake  스크립트를 통해서 편집해줍니다. `rewrite_cname`은 CNAME 파일이 `sexy.emacs.kr`(실제 배포될 URL)을 가리키도록 합니다.  `add_link`는 별도로 관리중인 [한국어 링크를 정리한 json 파일][links]에서 링크를 가져와 문서의 아래 쪽에 추가해줍니다. 마지막으로 `add_link_to_translator`는 번역자 정보를 문서에 추가해줍니다.

[links]: https://github.com/nacyot/omegat-emacs.sexy/blob/master/data/sites.json

## Github Pages

빌드 과정의 마지막에는 이렇게 생성된 번역 결과를 sexy.emacs.kr 깃허브 저장소에 push하도록 되어있습니다. 깃허브에서는 gh-pages 브랜치를 이용해 저장소의 내용을 배포할 수 있습니다. 특별한 건 없습니다만, Github Pages에서 커스텀 도메인으로 배포 가능하도록 DNS A record를 지정해야하는 ip 주소가 최근에 바뀐 듯 합니다. [깃허브 Help 사이트][help]에서는 `192.30.252.153`과 `192.30.252.154`를 지정해야한다고 이야기하고 있으며, 예전 ip도 업데이트를 권장하고 있었습니다.

[help]: https://help.github.com/articles/setting-up-a-custom-domain-with-pages

## Travis

[Travis의 빌드 결과][build]는 여기서 확인할 수 있습니다. 이를 통해서 빌드가 어떤 식으로 이루어지는지 감이 오실 거라고 생각합니다.

[build]: https://travis-ci.org/nacyot/omegat-emacs.sexy

아시는 분은 이미 아시리라고 생가합니다만, 공개 프로젝트를 운영하신다면 tarvis는 둘도 없는 강력한 빌드 서비스입니다. 어떤 자원을 사용하건 자원에 대한 대가를 치루는 거는 꽤나 번거롭고 관리가 드는 일입니다만, 공개 프로젝트에 한해서 Travis는 이러한 부담이 전혀 없이 무료로 사용할 수 있습니다. 위에서 보셨다시피 커밋에 대응한 자동 빌드 및 심지어 빌드 성공시 깃헙 페이지에 자동 배포하는 역할까지 수행하고 있습니다.

## 결론

이 프로젝트의 경우는 번역할 절대 양이 많지도 않고 업데이트가 크게 많다고 생각되지 않기 때문에 조금 오버를 했다는 느낌도 없지 않습니다만, 예전부터 생각해오던 것을 직접 적용해서 작은 번역 프로젝트를 하나 진행해 보았습니다. 좀 더 큰 프로젝트에서라면 번역에만 집중할 수 있는 이러한 워크플로우가 꽤나 도움이 될 것이라고 기대하고 있습니다.

