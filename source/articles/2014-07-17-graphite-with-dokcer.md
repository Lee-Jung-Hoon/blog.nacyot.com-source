---
title: 그라파이트(Grahpite) + 그라파나(Grafana) 모니터링 시스템 구축 with Docker
author: nacyot
date: 2014-07-25 12:20:03 +0900
publshed: true
tags: 
---

시스템 [[모니터링|monitoring]]에 대해서 리뷰하거나, 직접 시스템 모니터링을 해봤다면 아래 그림과 같은 [[rrdtool]]로 만들어진 그래프를 자주 만나게 될 것입니다. rrdtool은 여전히 시스템 모니터링에 있어서 강자입니다만, 이 세계에 단지 rrdtool만 있는 것은 아닙니다. 특히 시계열 데이터 수집에 최적화된 타임시리즈 데이터베이스의 일종인 Graphite는 시스템 정보([[metrics]]) 수집에 있어 꽤나 매력적인 도구 중 하나입니다.

![rrdtool](http://i.imgur.com/egJIriw.png)
<p class="shape-title">rrdtool</p>


<!--more-->

[[Graphite]]는 기본적으로 특정한 네임스페이스에 시간과 데이터를 계속해서 쌓아가는 특수한 데이터 저장소입니다. 이것만으로는 그래프까지 그려주는 rrdtool에 비해서 그다지 메리트가 없어보입니다만, Graphite는 프로젝트 중에는 Graphite-Web이라는 모듈이 있어 API 형태로 그래프 파일을 제공하거나, 수치 데이터를 제공해줍니다. 기본적인 그래프 생성기가 그렇게 훌륭하진 않습니다만, 수치 데이터를 받을 수 잇는 API를 기반으로 다양한 대시보드 어플리케이션들이 만들어져 있습니다. 물론 오픈소스로. 사용자는 먼저 Grahpite에 데이터를 쌓아놓기만 하면, 자신의 취향에 맞는 대시보드를 골라서 자신만의 대시보드를 만들어나가면 됩니다. 그 중에서도 이 글에서 소개할 대시보드는 Grafana라는 툴입니다. [[ElasticSearch]]의 대시보드 툴로 유명한 [[Kibana]] 라는 프로젝트가 있습니다만, [[Grafana]]는 이 Kibana에서 영감을 받아 만들어진 Graphite판 Kibana라고 이해하시면 좀 더 쉽습니다.

이 글에서는 Grahphite에 대한 전반적인 소개에 걸쳐 Graphite를 구성하는 하나하나의 요소들을 시작으로 Grafana까지 [[Docker]]를 사용해 모니터링 시스템 전체를 구축해보도록하겠습니다.

# Tl;dr

```
$ docker run --name whisper nacyot/whisper
$ docker run -d -p 2003:2003 -p 2004:2004 -p 7002:7002 --volumes-from whisper -e NODE_NAME=cache nacyot/carbon-cache
$ docker run -d -p 8000:80 -e CARBONLINK_HOSTS="172.17.42.1:7002" --volumes-from whisper nacyot/graphite-web
$ docker run -d -p 9200:9200 -p 9300:9300 dockerfile/elasticsearch
$ docker run -d -p 8001:8000 nacyot/grafana
```

![Grafana](http://imgur.com/UYDytKS.png)
<p class="shape-title">Grafana</p>

예이! 참 쉽죠잉?

# Graphite

![Graphite의 모듈 구성](https://googledrive.com/host/0B5YqfYBpS__8b1pIVnNVbFNGc0U/Graphite)
<p class="shape-title">Graphite 구성도</p>

앞서 Graphite를 단순히 시계열 데이터 저장소라고 소개했습니다만, 이를 사용하기 위해서는 기본적으로 Garphite의 각 구성 요소가 어떻게 이루어지는 지를 이해할 필요가 있습니다.

위의 그림을 기준으로 간단히 설명하도록 하겠습니다. 먼저 Collector는 Graphite에 어떠한 데이터를 쌓기 위한 모듈입니다. 여기에 대한 특별한 제한은 없습니다만, 시계열 데이터베이스의 특성상 기본적으로 데이터가 저장될 **네임스페이스와 시간, 데이터** 이렇게 3가지 데이터가 필요합니다. 이러한 정보를 Graphite의 모듈인 Carbon-Cache에 보냅니다. Carbon-Cache는 Collector가 보낸 데이터를 받아 Whisper에 저장합니다. Carbon-Cache가 데이터 수집기라면 Whisper는 실제로 데이터를 파일시스템에 저장하고 읽어오는 모듈입니다. 자 이제 Whisper를 통해 데이터가 파일 시스템에 저장되었습니다. 그렇다면 이 데이터를 어떻게 가져올 수 있을까요. 이 시점에서 등장하는 게 Graphite-Web입니다. Graphite-Web은 http 프로토콜을 통해서 Whisper에 저장된 데이터를 읽어와 이미지 파일이나, 데이터 형식으로 출력합니다. Graphite-Web은 기본적으로 데이터를 제공하는 API와 대시보드 기능 두 가지를 제공하고 있습니다. 여기서 제공하는 대시보드 기능을 그냥 사용해도 무방합니다만, 기본적으로 그렇게 편리하지는 않습니다. 직접적인 Graphite 프로젝트는 아닙니다만, 이 Graphite-Web에서 대시보드를 제외하고 API 기능만을 따로 구현해둔 Graphite-api라는 모듈도 있습니다. 다른 대시보드를 사용한다면 Grahpite-Web이나 Graphite-api 어느 툴을 사용해도 무방합니다.

이렇게 보면 정말 간단하죠? 정말 간단합니다만, 이 관계를 모르고 무턱대고 Graphite를 사용해보겠다고 덤비면 Carbon은 모고 Whisper는 모고, Graphite-Web이 있는데 또 Graphite-api는 모고, 가벼운 현기증을 시작으로 멘붕을 겪을 지도 모릅니다. Graphite 하나 설치하면 마법 같이 작동하는 그런 아름다운 세계는 없습니다. 간단히 보이지만 이 기본 구성을 이해해두는 건 많은 도움이 될 것입니다. 특히 Graphite 이야기를 쫓아가다보며 statsd며, carban-relay며, diamond며, 나아가 스케일 아웃 얘기까지 나오면 이것저것 알쏭달쏭한 단어와 개념들이 쏟아져나오기 때문에 여기서 이해의 끈을 놓쳐서는 안 됩니다. 

## Graphite 시작하기

기본적을 Graphite 구성에 대해서 살펴보았으니 이제 실제로 설치해보도록 하겠습니다. 제목에서 이야기한 바대로 Docker를 기반으로 진행해나갑니다. 조금 번거로울 수도 있지만 이 글은 기본적으로 Graphite 이야기와 Docker 이야기가 혼재되어있습니다. Docker에 전혀 관심이 없으시다면 [Graphite 문서][graphite-doc]를 직접 읽으실 것을 추천해드립니다.

[graphite-doc]: https://graphite.readthedocs.org/en/latest/index.html

기본적으로 Ubuntu를 사용한다고 전제하고 이야기를 진행하도록 하겠습니다. (Docker와 연결만 되어있다면 사실 다른 운영체제라도 무방합니다.)

## Whisper

우선은 데이터가 저장될 Whisper 이야기부터 시작하도록 하겠습니다. 아래 명령어를 실행합니다.

```
$ docker pull nacyot/whisper
$ docker run --name whisper nacyot/whisper
```

### nacyot/whisper Dockerfile

사실 `nacyot/whisper` 이미지에는 아무것도 없습니다. [Dockerfile][whisper-dockerfile]을 열어보면 아래와 같이 실행되는 명령어는 전혀 없습니다.

[whisper-dockerfile]: https://github.com/nacyot/docker-graphite/blob/master/whisper/Dockerfile

```
FROM busybox
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

VOLUME /opt/graphite/storage/whisper
CMD ["/bin/sh"]
```

자세히 보면 `busybox`라는 이미지를 기반으로 단지 `/opt/graphite/storage/whisper` 디렉토리를 마운트 시키는 역할을 하고 있습니다. 정말 이것뿐입니다.

### 볼륨 컨테이너

Docker의 볼륨 컨테이너라는 개념을 이해하고 계신다면 바로 이해하실 수 있겠지만, 별안간 등장한 busybox라는 이미지가 낯설어보일지도 모릅니다. 잠깐 [[busybox]]의 정체를 짚고 넘어가죠.

```
$ docker images busybox
REPOSITORY          TAG                   IMAGE ID            CREATED             VIRTUAL SIZE
busybox             latest                a9eb17255234        6 weeks ago         2.433 MB
```

`imagse`를 명령어를 실행해보면 busybox 이미지가 놀라울 정도로 **작은** 이미지라는 것을 알 수 있습니다. busybox의 정체는 초경량 임베디드 리눅스의 일종입니다. 실제로 `naycot/whisper`가 하는 역할은 `/opt/graphite/storage/whisper`라는 디렉토리를 마운트해놓고, 관련된 모듈이 여기에 데이터를 저장하거나 읽어들이기 위한 역할만을 하는 정말로 **데이터만을 위한** 이미지입니다.

```
$ docker run --name whisper nacyot/whisper
```

눈치가 빠르신 분들은 이미 알아채셨겠지만, 이 `docker run` 명령어는 심상치 않습니다. 보통 셸을 사용하는 경우처럼 컨테이너에 직접 접속하고자 할 때는 `-it` 옵션을 사용하고, 반대로 백그라운드에서 실행시킬 때는 `-d` 옵션을 사용하는데, 여기에는 아무런 옵션이 보이질 않습니다. 실제로 이 명령어를 통해서 컨테이너는 생성되지만 실행되진 않습니다. 이렇게 **데이터만을 위한** 이미지는, **데이터만을 위한** 컨테이너로 탈바꿈합니다.

사실 이러한 볼륨 컨테이너를 사용하지 않아도 어플리케이션을 사용하는 데는 아무런 문제가 없습니다만, 볼륨 컨테이너를 사용하면 좋은 점이 있습니다. 먼저 [[AUFS]]와 같은 도커 파일 시스템 자체에 데이터를 기록하는 일은 성능 면에서 손해가 많은 편입니다. 다른 파일 시스템을 사용하는 방법도 있기는 합니다만 Volume 기능을 사용해 특정한 디렉토리를 마운트 시키면 호스트와 같은 파일 시스템으로 데이터가 기록됩니다. 이를 통해 성능 손실을 막을 수 있습니다.

또한 [[볼륨 컨테이너|volume_container]]를 통해서 실제로 작동되는 프로세스의 실행 종료와 완전히 무관하게, 볼륨 컨테이너가 삭제되지 않는 한 해당하는 컨테이너에 마운트된 데이터도 사라지지 않도록 영속성을 보장할 수 있게 해줍니다. 이를 통해 부가적으로 프로세스와 데이터의 논리적 분리를 통해서 좀 더 깔끔한 관리가 가능하게 해주며, 특히 다수의 프로세스에서 데이터를 공유할 때 특정 프로세스 컨테이너나 특정 Host의 폴더에 의존하지 않는 구조를 만들 수 있게 해줍니다.

앞서 실행한 볼륨 컨테이너를 확인해보죠. 컨테이너는 실행중인 상태가 아니므로 `-a` 옵션을 통해서 확인합니다.

```
$ docker ps -al
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS                           PORTS
45b4afcb4be2        nacyot/whisper:latest        /bin/sh                About an hour ago   Exited (0) About an hour ago                                                                              whisper
```

뭔가 아무것도 없는데 설명이 길었습니다만, 이걸로 데이터를 저장할 준비가 되었습니다.

## carbon-cache

다음은 [[Carbon]]입니다. 실질적으로 데이터를 수집해서 파일 시스템에 기록하는 모듈이 바로 [[Carbon-Cache]]입니다.

```
$ docker pull nacyot/carbon-cache
$ docker run -d -p 2003:2003 -p 2004:2004 -p 7002:7002 --volumes-from whisper -e NODE_NAME=cache nacyot/carbon-cache
```

이것도 간단하죠? 이제 바로 데이터 수집이 가능합니다.

### nacyot/carbon-base Dockerfile

먼저 carbon-cache 이미지를 살펴보기 전에 carbon-cache 이미지의 베이스가 되는 carbon-base를 살펴보겠습니다. carbon-base 실제 모듈이 아니라 carbon-cache와 [[carbon-relay]]를 위해 만들어진 중간 이미지입니다.

```
FROM nacyot/ubuntu
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

RUN apt-get -y update
RUN apt-get -y install python python-twisted

WORKDIR /usr/local/src

RUN git clone https://github.com/graphite-project/carbon.git
RUN git clone https://github.com/graphite-project/whisper.git
RUN cd whisper && git checkout master && python setup.py install
RUN cd carbon && git checkout 0.9.12 && python setup.py install
```

carbon-base 이미지에도 특별한 건 없습니다. [[python]]을 설치하고 carbon과 [[whisper]]를 설치해줍니다.

### nacyot/carbon-cache Dockerfile

다음으로 carbon-cache의 [[Dockerfile]]을 살펴보도록 하겠습니다.

```
FROM nacyot/carbon-base
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

ENV NODE_NAME cache
ENV LOCAL_DATA_DIR /opt/graphite/storage/whisper/
ENV MAX_CACHE_SIZE inf
ENV MAX_UPDATES_PER_SECOND 1000
ENV MAX_CREATES_PER_MINUTE inf
ENV LOG_UPDATES False
ENV LINE_RECEIVER_INTERFACE 0.0.0.0
ENV PICKLE_RECEIVER_INTERFACE 0.0.0.0
ENV CACHE_QUERY_INTERFACE 0.0.0.0
ENV LINE_RECEIVER_PORT 2003
ENV PICKLE_RECEIVER_PORT 2004
ENV CACHE_QUERY_PORT 7002

ADD ./config /opt/graphite/conf/
ADD ./setup_configs.sh /opt/graphite/setup_configs.sh
ADD ./run.sh /opt/graphite/run.sh
EXPOSE 2003 2004 7002

WORKDIR /opt/graphite
CMD ./setup_configs.sh && ./run.sh
```

사실 carbon은 이미 carbon-base에서 설치가 되었기 때문에 여기서 무언가를 설치하거나 실행하는 부분은 없습니다. 여기서는 우선 ENV를 통해서 기본 환경변수값들을 설정합니다. 이 환경변수들은 `carbon.conf` 파일에서 사용됩니다.

다음으로 `/config` 디렉토리를 이미지 내의 carbon 설정 디렉토리로 복사합니다. 이 디렉토리에는 `carbon.conf`와 `storage-aggregation.conf`, `storage-schemas.conf` 파일이 포함되어있습니다. 따로 만든 설정 파일을 사용한다면 이미지 실행시 `-v` 옵션으로 설정 파일이 포함된 폴더를 컨테이너에 마운트시키면 됩니다.

그리고 `setup_configs.sh`와 `run.sh`를 이미지 내부로 복사합니다. 2003 2004 7002 포트를 열어주고 WORKDIR을 설정해주고, 초기 명령어(CMD)를 설정합니다. 여기서부터는 설정파일과 복사한 쉘스크립트의 용도에 대해서 간략히 설명합니다.

### carbon.conf

먼저 `carbon.conf`를 살펴보겠습니다. 이 파일은 데이터를 수집하는 carbon 데몬에 관한 설정을 담고 있습니다.

```
[cache]
LOCAL_DATA_DIR =
MAX_CACHE_SIZE =
MAX_UPDATES_PER_SECOND =
MAX_CREATES_PER_MINUTE =
LOG_UPDATES =

LINE_RECEIVER_INTERFACE =
PICKLE_RECEIVER_INTERFACE =
CACHE_QUERY_INTERFACE =
LINE_RECEIVER_PORT =
PICKLE_RECEIVER_PORT =
CACHE_QUERY_PORT = 
```

여기서는 기본적으로 사용하는 설정들을 나열해놓았습니다. 실제로는 아무런 값도 들어가 있지않습니다. 이렇게도 실행이 가능할까요? 불가능하겠죠. 이 설정은 [[셸스크립트|shell_script]]를 통해서 환경변수로부터 자동적으로 입력됩니다. 이를 수행하는 게 `setup_configs.sh` 파일입니다.

```
#!/bin/bash

sed -i -e "s/\[cache\]/\[${NODE_NAME}\]/g" ./conf/carbon.conf
sed -i -e "s/\(LOCAL_DATA_DIR\).*$/\1 = $(printf "${LOCAL_DATA_DIR}" | sed -e 's/\//\\\//g')/g" ./conf/carbon.conf
sed -i -e "s/\(MAX_CACHE_SIZE\).*$/\1 = ${MAX_CACHE_SIZE}/g" ./conf/carbon.conf
sed -i -e "s/\(MAX_UPDATES_PER_SECOND\).*$/\1 = ${MAX_UPDATES_PER_SECOND}/g" ./conf/carbon.conf
sed -i -e "s/\(MAX_CREATES_PER_MINUTE\).*$/\1 = ${MAX_CREATES_PER_MINUTE}/g" ./conf/carbon.conf
sed -i -e "s/\(LOG_UPDATES\).*$/\1 = ${LOG_UPDATES}/g" ./conf/carbon.conf
sed -i -e "s/\(LINE_RECEIVER_INTERFACE\).*$/\1 = ${LINE_RECEIVER_INTERFACE}/g" ./conf/carbon.conf
sed -i -e "s/\(PICKLE_RECEIVER_INTERFACE\).*$/\1 = ${PICKLE_RECEIVER_INTERFACE}/g" ./conf/carbon.conf
sed -i -e "s/\(CACHE_QUERY_INTERFACE\).*$/\1 = ${CACHE_QUERY_INTERFACE}/g" ./conf/carbon.conf
sed -i -e "s/\(LINE_RECEIVER_PORT\).*$/\1 = ${LINE_RECEIVER_PORT}/g" ./conf/carbon.conf
sed -i -e "s/\(PICKLE_RECEIVER_PORT\).*$/\1 = ${PICKLE_RECEIVER_PORT}/g" ./conf/carbon.conf
sed -i -e "s/\(CACHE_QUERY_PORT\).*$/\1 = ${CACHE_QUERY_PORT}/g" ./conf/carbon.conf
```

단순 무식한 스크립트이므로 설명은 생략하겠습니다. 이를 통해서 기본적인 설정들에 대해서는 실행시에 동적으로 환경 변수를 지정해 사용할 수 있습니다. [[환경변수|environment_variable]]를 덮어쓰지 않으면 위에서 살펴본 carbon-cache Dockerfile의 ENV 값들이 사용됩니다. 단순히 하나의 노드로 실행시키고자 할 때는 기본 설정을 사용해도 무방할 것입니다. 각 설정에 대한 자세한 사항은 [Graphite 문서][graphite-doc]를 참조하시기바랍니다.

### Carbon에서 사용하는 3개의 포트 : 2003, 2004, 7002

조금만 더 설명을 보태겠습니다. 위에서 EXPOSE 지시자를 통해서 2003, 2004, 7002, 이렇게 3개의 포트를 열었습니다. 데이터 수집 데몬이라고 했는데, 은근히 포트가 많죠. 각각의 포트가 어떤 용도로 사용되는 지 정도는 알아둘 필요가 있습니다.

2003과 2004는 데이터를 받아서 저장하는 포트입니다. 먼저 2003은 plaintext protocol을 사용해 데이터를 받아들이며, 설정에서는 `LINE_RECEIVER`로 표현합니다. 한 줄 한 줄 아래와 같은 포맷을 사용합니다.

```
<metric path> <metric value> <metric timestamp>
```

실제로는 아래와 같습니다.

```
hello.graphite 3.5 1405608517
```

다음으로 2004는 pickle protocol입니다. 설정에서는 `PICKLE_RECEIVER`라고 표현합니다. 아래와 같은 형식을 사용합니다.

```
[(path, (timestamp, value)), ...]
```

하나의 네임스페이스에 대해서 다량의 정보를 수집할 때 유용합니다. 어쨌거나 대개는 라이브러리나 이미 만들어져있는 수집기를 통해서 metric을 수집하기 때문에 프로토콜까지 이해하고 직접 작성할 일은 별로 없습니다. 포트의 용도 정도만 이해하셔도 충분하다고 생각합니다.

마지막으로 7002는 쿼리 포트입니다. 실제로 이 포트는 graphite-web에서 연결합니다. 그런데 사실 graphite-web은 whisper 데이터베이스(파일)에서 직접 데이터를 읽어옵니다. 그렇다면 조금 의문이 들 지도 모릅니다. 이 carbon daemon에 쿼리를 하는 건 어떤 용도로 쓰일까요? 사실 carbon에서 받은 데이터는 whisper 데이터베이스에 실시간으로 저장되지 않습니다. carbon에서 받은 데이터는 기본적으로 메모리에 저장되고 whisper 라이브러리에 의해서 적절히 flush되어 파일에 저장됩니다. carbon-cache는 최근에 들어온 아직 파일에 쓰여지지 않은 데이터를 쿼리하는데 사용됩니다.

이것으로 3가지 포트의 수수께끼는 풀렸습니다.

### storage-aggregation.conf & storage-schemas.conf

이외에도 carbon에는 데이터를 저장할 whisper 데이터베이스의 저장방식을 지정하기 위한 설정 파일들이 있습니다.

whisper 라이브러리는 데이터값을 받는 모든 네임스페이스에 대해서 해당하는 네임스페이스의 데이터가 저장되는 `.wsp` 파일을 생성합니다. `storage-schemas.conf`는 패턴을 통해서 특정한 패턴에 해당하는 네임스페이스의 데이터베이스를 만들 때 그 구조(retention)를 정의합니다.

```
[carbon]
pattern = ^carbon\..*
retentions = 1m:31d,10m:1y,1h:5y

[highres]
pattern = ^highres.*
retentions = 1s:1d,1m:7d

[statsd]
pattern = ^statsd.*
retentions = 1m:7d,10m:1y

[default]
pattern = .*
retentions = 10s:1d,1m:7d,10m:1y
```

설정값이 `retentions = 15s:7d,1m:21d,15m:5y`이면 해당하는 네임스페이스의 데이터는 15초 간격의 데이터는 7일, 1분 간격의 데이터는 21일, 15분 간격의 데이터는 5년 치를 저장하게 됩니다. 좀 더 구체적으로 설명하면 데이터를 저장하고 8일이 지나면 이 데이터는 1분 간격으로 저장되고, 1분보다 짧은 간격의 데이터들은 소실됩니다.

그런데 이렇게 더 짧은 간격의 **데이터들**이 일부가 소실되어 긴 간격의 포인트가 된다고 한다면 여기에는 분명 어떠한 조작이 일어날 것입니다. 이를 정의하는 게 storage-aggregation.conf 파일입니다. 

```
[min]
pattern = \.min$
xFilesFactor = 0.1
aggregationMethod = min

[max]
pattern = \.max$
xFilesFactor = 0.1
aggregationMethod = max

[sum]
pattern = \.count$
xFilesFactor = 0
aggregationMethod = sum

[default_average]
pattern = .*
xFilesFactor = 0.5
aggregationMethod = average
```

이 설정도 마찬가지로 특정한 패턴에 해당하는 네임스페이스에 대해서 적용됩니다. 기본은 `average` 통해서 데이터가 집계됩니다. 쉽게 말해 15초 간격의 데이터가 10 20 10 20 이었다면 1분 간격의 데이터는 15가 됩니다. 단 여기서 굉장히 주의해야할 부분이 하나 있습니다. 15초 간격의 데이터인데, 실제로는 데이터가 이 사이에 하나밖에 없다고 해보죠. Whisper에서는 시간과 데이터만 있으면 어떠한 데이터도 저장이 되기 때문이 이런 종류의 제약은 걸려있지 않습니다만, 이 데이터를 average로 집계하면 데이터가 소실되어 버립니다. 이렇게 데이터가 소실되어 버리면 실제로는 데이터가 존재하는 데도 api에서 호출될 때는 사라지는 현상이 발생하게됩니다. 이러한 상황을 방지하기 위해서는 데이터를 간격에 맞춰(혹은 더 자주) 충실히 넣어주거나, average 대신 다른 집계 방법을 사용할 필요가 있습니다. 이는 Graphite를 처음 사용할 때 빠지기 쉬운 함정이므로 알아두면 좋습니다.

참고로 패턴 적용은 위에서부터 이루어진다는데 유의가 필요합니다. 즉 이 설정 파일들에서는 순서가 중요합니다. 예를 들어 `[default]`의 패턴 `.*`이 모든 네임스페이스에 들어맞기 때문에 이후에 어떤 설정을 넣어도 적용되지 않을 것입니다.

더 자세한 내용은 [Graphite 문서][graphite-doc]를 참조해주시기바랍니다.

## Graphite-Web

이것으로 무사히 `carbon-cache`까지 실행했습니다. 데이터를 받을 준비는 끝났습니다. 다음은 저장된 데이터를 읽어오는 Garphite-Web 모듈의 차례입니다.

```
$ docker pull naycot/graphite-web
$ docker run -d -p 8000:8000 -e CARBONLINK_HOSTS="172.17.42.1:7002" --volumes-from whisper nacyot/graphite-web
```

역시나 도커를 사용하면 간단합니다.

### nacyot/graphite-web Dockrefile

여기서부터는 좀 더 자세히 graphite-web 이미지가 어떻게 만들어졌는지 살펴보겠습니다.

```
FROM nacyot/ubuntu
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

# Install Base Packages
RUN apt-get -y update
RUN apt-get -y install supervisor nginx-light
RUN apt-get -y install python-simplejson python-memcache python-ldap python-cairo \
                       python-twisted python-pysqlite2 python-support \
                       python-pip gunicorn

# Install python packages
RUN pip install pytz pyparsing django==1.5 django-tagging==0.3.1

# Install whisper and graphite-web
WORKDIR /usr/local/src
RUN git clone https://github.com/graphite-project/whisper.git
RUN cd whisper && git checkout 0.9.12 && python setup.py install
RUN git clone https://github.com/graphite-project/graphite-web.git
RUN cd graphite-web && \
      git checkout 0.9.12 && \
      python check-dependencies.py && python setup.py install

# Setup graphite directories and environment variables
ENV GRAPHITE_STORAGE_DIR /opt/graphite/storage
ENV GRAPHITE_CONF_DIR /opt/graphite/conf
ENV PYTHONPATH /opt/graphite/webapp
ENV LOG_DIR /var/log/graphite
ENV DEFAULT_INDEX_TABLESPACE graphite

RUN mkdir -p /opt/graphite/webapp
RUN mkdir -p /var/log/graphite
RUN cd /var/log/graphite/ && touch info.log
RUN mkdir -p /opt/graphite/storage/whisper
RUN touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
RUN chown -R www-data /opt/graphite/storage
RUN chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
RUN chmod 0664 /opt/graphite/storage/graphite.db

# Copy configuration files
ADD ./config/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD ./config/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Initialize database(sqlite3)
RUN cd /opt/graphite/webapp/graphite && django-admin.py syncdb --settings=graphite.settings --noinput
RUN cd /opt/graphite/webapp/graphite && django-admin.py loaddata --settings=graphite.settings initial_data.json

# Set CMD
WORKDIR /opt/graphite/webapp
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
```

이번엔 꽤나 많은 명령어들이 늘어져있습니다만, 사실 자세히 보면 python과 [[django]] 관련 패키지 설치, 관련 폴더/파일 생성, 필요한 ENV 지정, django 앱인 graphite-web을 설치하는 과정에 불과합니다. 내용만 길 뿐이지, 읽어나가는 데 큰 어려움은 없을 것이라 생각합니다.

마지막 CMD 지시자를 통해서 `supervisord`로 `gunicorn_django`와 `nginx`를 사용해 graphite-web을 실행합니다.

supervisord.conf는 아래와 같이 구성됩니다.

```
[supervisord]
nodaemon = true

[program:nginx]
command = /usr/sbin/nginx
stdout_logfile = /var/log/supervisor/%(program_name)s.log
stderr_logfile = /var/log/supervisor/%(program_name)s.log
autorestart = true

[program:graphite-webapp]
directory = /opt/graphite/webapp
command = /usr/bin/gunicorn_django -b0.0.0.0:8000 -w2 graphite/settings.py
stdout_logfile = /var/log/supervisor/%(program_name)s.log
stderr_logfile = /var/log/supervisor/%(program_name)s.log
autorestart = true
```

실제 graphite-web 어플리케이션은 [[gunicorn]]을 통해서 실행시키고, [[nginx]]의 프록시 기능을 통해서 외부에 노출시킵니다. `nginx.conf` 일부를 살펴보면 아래와 같이 proxy하고 있는 걸 알 수 있습니다. 

```
proxy_pass                 http://127.0.0.1:8000;
proxy_set_header           X-Real-IP   $remote_addr;
proxy_set_header           X-Forwarded-For  $proxy_add_x_forwarded_for;
proxy_set_header           X-Forwarded-Proto  $scheme;
proxy_set_header           X-Forwarded-Server  $host;
proxy_set_header           X-Forwarded-Host  $host;
proxy_set_header           Host  $host;
```

이외에도 nginx를 사용하는 이유는 한 가지가 더 있습니다. 바로 외부 호스트에서 호출시 [[cors]]를 사용하기 위함입니다.

```
add_header Access-Control-Allow-Origin "*";
add_header Access-Control-Allow-Methods "GET, OPTIONS";
add_header Access-Control-Allow-Headers "origin, authorization, accept";
```

참고로 graphite-web는 단순히 데이터를 전달하는 용도 뿐만 아니라, 웹사이트 기능을 포함하고 있어서 자체 정보를 저장하는 데이터베이스를 사용합니다. 이 데이터베이스에는 사이트 설정 및 관리자 정보 같은 것들이 저장됩니다. 여기서는 편의상 sqlite을 사용해서 컨테이너 내부에서만 사용합니다. 이 예제에서는 graphite-web 대시보드를 사용하지 않습니다. grafana를 사용할 것이므로 별로 중요하지 않습니다. (참고로 기본 관리자 계정은 admin/admin 입니다)

local_settings.py에는 graphite-web 설정이 들어갑니다만, 실제 파이썬 코드를 사용하므로 바로 환경변수를 사용할 수 있습니다. 앞에서 사용한 `setup_configs.sh`처럼 쉘 스크립트를 사용할 필요가 없습니다. 파이썬 코드를 바로 사용해서 환경변수를 통해 설정을 적용할 수 있습니다. 

```
import os

LOG_DIR = '/var/log/graphite'
if os.getenv("CARBONLINK_HOSTS"):
    CARBONLINK_HOSTS = os.getenv("CARBONLINK_HOSTS").split(',')

if os.getenv("CLUSTER_SERVERS"):
    CLUSTER_SERVERS = os.getenv("CLUSTER_SERVERS").split(',')

if os.getenv("MEMCACHE_HOSTS"):
    CLUSTER_SERVERS = os.getenv("MEMCACHE_HOSTS").split(',')
```

현재 중요한 옵션은 `CARBONLINK_HOSTS`입니다. 위에서 설명한 대로 carbon에 직접 연결해서 아직 whisper에 저장되지 않은 데이터를 읽어오기 위한 용도입니다. 다시 앞선 graphite-web 실행 명령어를 살펴봅니다.

```
$ docker run -d -p 8000:8000 -e CARBONLINK_HOSTS="172.17.42.1:7002" --volumes-from whisper nacyot/graphite-web
```

이를 통해 `CARBONLINK_HOSTS`를 통해 carbon에서 직접 최신 데이터를 받아오며 `--volumes-from`을 통해서 whisper 데이터를 읽어오는 것을 알 수 있습니다.

## Graphite 정리

현재 상황을 확인해보겠습니다.

```
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS                      PORTS                                                                    NAMES
3acf95727292        nacyot/graphite-web:latest   /usr/bin/gunicorn_dj   10 minutes ago      Up 10 minutes               0.0.0.0:8000->8000/tcp                                                   thirsty_ritchie
5ec8670bef73        nacyot/carbon-cache:latest   /bin/sh -c './setup_   10 minutes ago      Up 10 minutes               0.0.0.0:2003->2003/tcp, 0.0.0.0:2004->2004/tcp, 0.0.0.0:7002->7002/tcp   tender_newton
48a012d30afb        nacyot/whisper:latest        /bin/sh                12 minutes ago      Exited (0) 12 minutes ago                                                                            whisper
```

앞서 설명했듯이 whisper는 실제로 실행중인 컨테이너가 아니므로 `-a` 옵션을 사용하지 않으면 보이지 않습니다. carbon-cache를 사용해서 whisper에 데이터를 저장하고 graphite-web에서 저장된 데이터와 carbon-cache에서 최신 데이터를 가져오도록 완벽히 세팅되었습니다.

여기까지 잘 따라오셨다면 `http://0.0.0.0:8000`에 접속해봅니다. 몇 번인가 언급했다시피 graphite-web은 api 서버이자, 대시보드 어플리케이션 역할을 합니다.

![Grphite-Web Dashboard](http://i.imgur.com/BiV7oAE.png)
<p class="shape-title">Graphite-Web 대시보드</p>r

오오, 뭔가 나오네요 >_<

아직 어떠한 데이터도 집어넣은 기억이 없으실 지도 모릅니다만, carbon은 기본적으로 데몬으로부터 간단한 데이터를 수집합니다.

# Grafana

Grafana는 Graphite나 [[influxDB]]를 백엔드로 사용하는 대시보드 툴입니다. 처음 Graphite + Grafana 조합을 보면, ElasticSearch + Kibana 조합과 뭐가 다른 건지, 대체 가능한 건지 의문이 들 지도 모릅니다. 차이가 있다고 하면 있고, 없다고 하면 없기는 합니다. 그런 알쏭달쏭한 면이 있기는 하지만,  하나 분명한 차이는 Graphite는 단지 시간과 데이터를 받는 시계열 데이터베이스고, ElasticSearch를 사용한 모니터링은 로그 수집에 가깝다는 점입니다. 결론적으로 ElasticSearch가 Graphite의 기능을 대개 커버할 수 있을지는 모르지만, 단순 시계열 데이터를 저장하는데 최적화된 플랫폼은 아닙니다. 결국에 시스템 모니터링 + 로그 시스템을 구축할 때는 Graphite + Grafana와 ElasticSearch + Kibana 두 조합 모두 사용하는 게 답이 아닌가 하고, 필요하다면 각각에 대한 대체툴을 찾아야겠죠.

어쨌건 약간 주제에서 빗겨난 이야기를 했습니다만, 다시 한 번 정리하면 Graphite는 시계열 데이터를 저장하는데 최적화되어있고, Grafana는 시계열 데이터를 보여주는데 최적화된 대시보드라고 할 수 있습니다. 아, 물론 Graphite를 기반으로 하는 대시보다 툴은 더 많이 있습니다. Garafana는 그 중에서 최근에 가장 잘 나가는 도구라고 보시면 됩니다.

## Grafana 실행하기

먼저 grafana를 실행시키기 위해서는 elasticsearch가 필요합니다.

```
$ docker pull dockerfile/elasticsearch
$ docker run -d -p 9200:9200 -p 9300:9300 dockerfile/elasticsearch
```

다음 명령어로 grafana를 실행합니다.

```
$ docker pull nacyot/grafana
$ docker run -d -p 8001:8000 nacyot/grafana
```

### Dockerfile

Grafana는 [[Angularjs]]를 기반으로 만들어진 앱어플리케이션으로 자바스크립트 프로젝트입니다. 따라서 레일스나 장고와 같은 서버 계층을 가지고 있지 않습니다. 갑자기 [[Centos]]를 사용하고 있습니다만, 이전에 작업하던 걸 기반으로 한 거라 별다른 의미이는 없습니다. 설치과정은 grafana 어플리케이션을 가져와서 적절한 위치에 설치하고 [[apache]]를 기반으로 실행합니다. 

```
FROM centos:centos6
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

RUN rpm -iUvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum update -y
RUN yum -y install httpd git
RUN cd /opt; git clone https://github.com/grafana/grafana.git
RUN cd /opt/grafana; git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

RUN rm -f /etc/localtime
RUN cp -p /usr/share/zoneinfo/Japan /etc/localtime

RUN mkdir -p /opt/grafana/src/config

ADD ./config.js /opt/grafana/src/config.js
ADD ./grafana.conf /etc/httpd/conf.d/grafana.conf
ADD ./setup_configs.sh /opt/grafana/setup_configs.sh
ADD ./run.sh /opt/grafana/run.sh

ENV ES_API_HOST 172.17.42.1
ENV ES_API_PORT 9200
ENV GRAPHITE_API_HOST 172.17.42.1
ENV GRAPHITE_API_PORT 8000

WORKDIR /opt/grafana

EXPOSE 8000
CMD ./setup_configs.sh && ./run.sh
```

일단 다른 부분들은 대체로 비슷한데, 로컬 타임 설정하는 부분이 있습니다. 기본적으로 도커 컨테이너에서는 시간이 UTC로 설정된다는 걸 이해하고 있어야합니다.

```
$ docker run -i -t ubuntu bash
root@1f27c50b400d:/# date
Fri Jul 18 01:05:48 UTC 2014
```

이는 여러모로 귀찮은 문제들을 발생시키곤 합니다. 어플리케이션 단에서 이 문제를 명시적으로 설정해서 푸는 방법도 있습니다만, 해당하는 설정이 작동하지 않는 경우 시스템 시간 설정을 바꾸는 것도 방법입니다. 여기서 시스템 시간 설정을 하는 이유는 아마 해당하는 이슈가 있었기 때문이라고 어렴풋이 떠올려봅니다만, 사실 정확히 기억나진 않습니다. 일단 여기서는 시스템 시간 설정을 바꿔줍니다.

### config.js & `setup_configs.js`

다음으로 config.js를 살펴봅니다.

```
define(['settings'],
       function (Settings) {
           "use strict";
           
           return new Settings({
               elasticsearch: "ES_API_HOST:ES_API_PORT",
               datasources: {
                 graphite: {
                   type: 'graphite',
                   url: 'GRAPHITE_API_HOST:GRAPHITE_API_PORT',
                   default: true,
                   render_method: 'GET'
                 }
               },
               default_route: '/dashboard/file/default.json',
               timezoneOffset: null,
               grafana_index: "grafana-dash",
               panel_names: [
                   'text',
                   'graphite'
               ]
           });
       });
```

Dockerfile의 아래쪼을 보면 ENV로 ElasticSearch 서버와 Garphite 서버를 설정합니다. 여기서 ElasticSerach를 사용하는 게 의아하실 지도 모릅니다만, Grafana는 기본적으로 Kibana를 베이스로 하고 있으며 대시보드 설정을 ElasticSearch에 저장하고 있습니다. 네, 단지 그 용도로 사용합니다. 데이터는 Graphite에서 가져옵니다. 환경 변수에 저장된 서버 정보는 config.js에서 치환됩니다. 이는 carbon-cache 에서 사용했던 것과 같은 기법입니다. `setup_configs.conf`를 살펴보죠.

```
#!/bin/bash

[ -f /opt/grafana/src/config/config.js ] && cp /opt/grafana/src/config/config.js /opt/grafana/src/config.js

sed -i -e "s/ES_API_HOST/${ES_API_HOST}/g" ./src/config.js
sed -i -e "s/ES_API_PORT/${ES_API_PORT}/g" ./src/config.js
sed -i -e "s/GRAPHITE_API_HOST/${GRAPHITE_API_HOST}/g" ./src/config.js
sed -i -e "s/GRAPHITE_API_PORT/${GRAPHITE_API_PORT}/g" ./src/config.js
```

우선 별도의 설정 파일을 마운트했을 경우 해당하는 config.js를 우선적으로 사용할 수 있도록 했습니다. 기본적으로 이 이미지는 ElasticSearch와 Graphite 서버에 연결할 것을 전제하고 있습니다만, Grafana는 데이터 백엔드로 여러 서버를 지정할 수도 있고 InfluxDB를 지정할 수 있습니다. 물론 다른 설정들도 필요한 경우 수정할 수 있어야하니까요. 설정에 관한 자세한 사항 [Grafana 문서][grafana-doc]를 참조해주세요.

[grafana-doc]: http://grafana.org/docs/

나머지 부분은 서버 설정을 치환하는 부분입니다.

### grafana.conf & run.sh

Apache 설정입니다. Grafana는 자체적인 웹 서버를 가지지 않으므로 nginx나 apache를 사용해서 실행해야합니다. 별 다른 내용은 없습니다.

```
Listen 80
<VirtualHost *:80>
    ServerName grafana
    DocumentRoot "/opt/grafana/src"
</VirtualHost>
```

run.sh는 아파치를 실제로 실행시키는 파일입니다. `-DFOREGROUND` 옵션은 아파치를 데몬이 아니라 포그라운드에서 띄워줍니다.

```
#!/bin/bash

/usr/sbin/httpd -d . -f /etc/httpd/conf/httpd.conf -e info -DFOREGROUND
```

## Grafana 사용하기

네, 여기까지 Grafana 실행 및 내부적으로 어떻게 실행하는 지에 대해서 설명했습니다. 앞서 실행시에 8001번 포트로 내부를 연결했습니다. 웹브라우저로 `0.0.0.0:8001`에 접속해주세요.

![Grafana](http://imgur.com/UYDytKS.png)
<p class="shape-title">Grafana Randomwalk</p>

첫 페이지에 생성되는 데이터는 [[RandomWalk]]로 생성된 시계열 그래프입니다.

앞서 Graphite-Web 에서 본 그래프는 아래와 Grafana에서는 아래와 같이 보입니다.

![Grafana](http://i.imgur.com/yY0Uoa9.png)
<p class="shape-title">Grafana Graph(Carbon 데몬이 수집한 데이터)</p>

이 글에서는 Grafana의 사용법은 기본적인 개념만 익히면 어렵지 않습니다만, 그 얘기는 또 다음 기회에...

# 소스코드

* https://github.com/nacyot/docker-graphite

이 글에서 다룬 Dockerfile의 최신 코드는 위 저장소에 있습니다.

* https://registry.hub.docker.com/u/nacyot/whisper/
* https://registry.hub.docker.com/u/nacyot/carbon-cache/
* https://registry.hub.docker.com/u/nacyot/graphite-web/
* https://registry.hub.docker.com/u/nacyot/grafana/

각각의 이미지는 Docker Hub에서 확인할 수 있습니다.

# 결론

먼 길을 돌아왔습니다. 하지만 시작에서 이야기한 대로 실행하는 것은 간단합니다.

```
$ docker run --name whisper nacyot/whisper
$ docker run -d -p 2003:2003 -p 2004:2004 -p 7002:7002 --volumes-from whisper -e NODE_NAME=cache nacyot/carbon-cache
$ docker run -d -p 8000:80 -e CARBONLINK_HOSTS="172.17.42.1:7002" --volumes-from whisper nacyot/graphite-web
$ docker run -d -p 9200:9200 -p 9300:9300 dockerfile/elasticsearch
$ docker run -d -p 8001:8000 nacyot/grafana
```

실제로 사용하시고자 할 때는 커스터마이징이 필요할 것 같긴합니다만, 테스트 용도로 사용하는 동안에는 이 이미지들을 바로 사용해도 큰 문제는 없을 것입니다. Docker를 사용하면 위에서 설명한 모든 내용이 이 명령어 5개로 압축됩니다.

사실 이 전부를 다 가지고 있는 이미지 하나를 만드는 것도 가능합니다. 실제로 Docker Hub를 뒤져보면 굉장히 많은 하나로된 Grahpite 이미지들이 있습니다. 오히려 여기서 소개한 방식으로 쪼개져있는 경우를 찾아보기 힘듭니다. 이렇게 쪼개놓은 데는 이유가 있습니다. 이 글에서는 아직 소개하지 않았습니다만, Grahpite는 기본적으로 스케일 아웃 가능하도록 설계되어있습니다. 즉 각 모듈을 조립할 수 있도록 구성해야 좀 더 쉽게 스케일 아웃이 가능해집니다. 고작 숫자라고 생각하실지도 모릅니다만, 다량의 숫자를 다수의 서버에서 동시다발적으로 수집한다면 서버에 금방 과부하가 걸릴 가능성은 매우 큽니다. 이럴 때 스케일 아웃을 통해 생각보다 훨씬 견고한 수치 수집 시스템을 만들 수 있겠죠.(이 이야기가 다음 포스트가 되면 좋겠다고 생각은 하고 있습니다만, 기약은 없습니다.)

여기서 다룬 내용은 Graphite 시작에 불과합니다. Graphite 자체에 대해서도 이해해야할 주제들이 꽤 있습니다만, Graphite는 무엇보다도 생태계가 상당히 잘 갖춰져있는 오픈소스 모니터링 툴입니다. [Collected][collectd], [Diamond][diamond], [Metricsd][metricsd], [Sensu][sensu] 같은 툴을 통해서 관리중인 모든 서버의 수치 데이터를 수집할 수도 있고, 부하가 커질 경우 위에서 말한 것처럼 스케일 아웃도 가능하고 [Statsd][statsd]를 써서 버퍼 서버로 사용할 수도 있습니다. 또한 여기서는 Grafana만을 다뤘지만 앞서 언급한대로 다양한 대시보드 툴을 사용해 자신만의 대시보드를 만들 수도 있습니다. 나아가 [Cabot][cabot] 같은 툴을 이용해 수치를 감시하다가 특정 조건에 의해 경고를 보낼 수도 있습니다.

Graphite와 함께 즐거운 모니터링의 생활화를 도모해보시길!

[collectd]: https://collectd.org/
[diamond]: https://github.com/BrightcoveOS/Diamond
[metricsd]: https://github.com/mojodna/metricsd
[sensu]: http://sensuapp.org/
[statsd]: https://github.com/etsy/statsd/
[cabot]: https://github.com/arachnys/cabot
