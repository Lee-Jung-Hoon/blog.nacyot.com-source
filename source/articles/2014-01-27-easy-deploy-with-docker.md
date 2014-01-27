---
title: "도커(Docker) 튜토리얼 : 깐 김에 배포까지"
date: 2014-01-27 12:00:00 +0900
author: nacyot
profile: 컨테이너 나르는 프로그래머(29)
---

클라우드와 같이 잘 짜여지고, 잘 나뉘어진 거대한 시스템에서야 그렇다 치더라도 가상 머신은 여러모로 손실이 많은 수단 중 하나입니다. 가상 머신은 격리된 환경을 구축해준다는 데서 매력적이긴 하지만, 실제 배포용으로 쓰기에는 성능 면에서 매우 불리한 도구라고 할 수 있습니다. 당연한 이야기입니다만 일단 운영체제 위에서 또 다른 운영체제를 통째로 돌린다는 것 자체가 리소스를 비효율적으로 활용할 수밖에 없습니다.

이런 가운데 가상 머신의 단점은 극복하면서 장점만을 극대화하기 위한 최적화가 계속해서 이루어지고 있습니다. 도커 역시 이런 단점을 극복하기 위해서 나온 가상화 어플리케이션입니다. 도커는 단순한 가상 머신을 넘어서 어느 플랫폼에서나 재현가능한 어플리케이션 컨테이너를 만들어주는 걸 목표로 합니다. LXC(리눅스 컨테이너)라는 독특한 개념에서 출발하는 Docker의 가상화는 기존에 운영체제를 통째로 가상화하는 것과는 접근 자체를 달리합니다. 가상 머신이라고 하기에는 격리된 환경을 만들어주는 도구라고 하는 게 맞을 지도 모릅니다.

예를 들어 보죠. 우분투에서 CentOS라는 Docker를 통해 가상 환경을 구축하는데 얼마만큼의 시간이 걸릴까요? 먼저 여기서는 Ubuntu 상에서 작업을 한다고 가정하겠습니다.

```
$ cat /etc/issue
Ubuntu 13.10 \n \l
```

실제로 도커는 LXC를 사용하기 때문에 특정 리눅스 배포판에서 사용할 수 있고, 윈도우나 맥에서는 사용이 불가능합니다. Docker가 설치되어 있다는 가정 하에 Ubuntu에서 CentOS 가상 머신을 띄우는 데는 아래 두 명령어만 실행시키면 됩니다.

```
$ docker pull centos
$ docker run -rm -i -t centos:6.4 /bin/bash
bash-4.1#
```

먼저 위의 pull 명령어를 통해서 centos 이미지를 다운로드 받습니다. 그리고 이 이미지에 쉘 명령어를 실행시킵니다. 이걸로 끝입니다. 먼저 첫번째 명령어를 실행시키는데 제 컴퓨터에서 12초 정도가
걸렸습니다. 아래 명령어를 실행시키는데 0.3초가 걸리지 않았습니다. 쉘이 실행되면 bash 쉘로 바뀐 것을 알 수 있습니다. 실제로 CentOS인지 확인해보도록 하겠습니다.

```
bash-4.1# cat /etc/issue
CentOS release 6.4 (Final)
Kernel \r on an \m
```

어떻게 이런 일이 가능할까요? 원리적인 부분은 이미 좋은 문서들이 있습니다. 한국어로 된 좋은 자료로는 Deview 2013에서 김영찬 님이 발표하신 [이렇게 배포해야 할까? - Lightweight Linux Container Docker 를 활용하여 어플리케이션 배포하기][deview] 세션과 xym 님이 쓴 [docker the cloud][xym]를 추천합니다. 하지만 분명한 건 VMWare를 사용한다고 해서 가상화 기술에 빠삭해야하는 것이 아니듯이, Docker 역시 기본적으로는 툴이라는 사실을 이해해야합니다. 제 생각에 도커의 원리를 이해하는 것도 중요하지만, 막상 이 도구를 사용하는 동안엔 컨테이너와 이미지의 차이를 이해하는 게 더 중요하고, Dockerfile을 만들어 자신만의 배포 프로세스를 저장하는 법을 익히는 게 더 중요합니다.

이 글에서는 바로 이러한 시점에서 개발 환경이자 배포 툴로써의 도커를 이해하기 위한 개념들을 소개하고 모니위키 어플리케이션을 도커로 설치하는 부분까지 다뤄보도록 하겠습니다. 각 부분에 대한 좀 더 자세한 이야기는 기회가 된다면 따로 다뤄보도록 하죠.

[deview]:http://deview.kr/2013/detail.nhn?topicSeq=45
[xym]:http://spoqa.github.io/2013/11/22/docker-the-cloud.html

## 설치

각 운영체제 별 Docker의 설치 방법은 공식 홈페이지에 잘 정리되어 있습니다. 제가 사용하는 Ubuntu의 경우에는 Docker에서 제공하는 스크립트 파일 하나를 통해서 원큐에 정말 쉽게 Docker를 설치할 수 있습니다. 가상 머신에서도 설치가 가능하니, 가능하다면 Ubuntu 환경을 사용하길 권장합니다. 네, 글을 쓰는 편의상.

```
curl -s https://get.docker.io/ubuntu/ | sudo sh
```

단, 당연히 curl이 설치 되어있어야합니다.[^1] 1월 현재 12.04 / 13.10에서도 같은 방법으로 설치가 가능했습니다만, 설치 과정에 문제가 있거나 다른 운영체제를 사용하시는 경우엔 설치 문서를 꼼꼼히 읽어보시고 진행해나가시기 바랍니다. 설치가 끝나면 설치가 잘 됐나 확인해봅니다.

[^1]: `curl`이 없다면 `sudo apt-get curl`로 설치하시면 됩니다.

```
$ docker -v
Docker version 0.7.6, build bc3b2ec
```

Wow! 훌륭합니다. 필요하다면 ufw(방화벽) 설정을 통해서 도커가 사용하는 4243/tcp 포트도 열어줍니다.

```
sudo ufw allow 4243/tcp
```

기본적으로 docker의 대부분의 명령어를 실행 시 root 권한이 필요합니다. 따라서 sudo를 사용해야하는 번거로움이 따라오는데, 이를 위해 현재 유저를 docker 그룹에 포함시켜 줍니다. 

```
$ sudo groupadd docker
$ sudo gpasswd -a ${USER} docker
$ sudo service docker restart
```

명령어들을 실행하고 재로그인을 하게 되면 더 이상 sudo 명령어를 앞에 붙이지 않아도 docker 명령을 사용할 수 있습니다. 단, 이 방법을 사용할 경우엔, 공식 문서에서도 경고하고 있듯이 docker group은 root와 같은 권한 가지고 있다는 사실을 인지하고 있어야합니다.

## 이미지(Image)

설치만 끝났다면, 이제 끝이 보입니다. 대단해보이지만 정말 별 게 없습니다. 먼저 도커를 시작하면 이미지 개념을 이해할 필요가 있습니다. 처음에 보여드린 예제를 보면 centos 이미지를 다운로드 받고, 이 이미지에 shell을 실행시킵니다. 그런데 여기에 약간의 함정이 있습니다. Docker에서 실제로 실행되는 건 이미지가 아닙니다! 이미지는 추상적인 개념입니다. 실행되는 건 이미지를 기반으로 생성된 컨테이너입니다. 먼저 어떤 일이 일어나는지 확인해보도록 하겠습니다.

먼저 `docker images` 명령어로 시스템에 어떤 이미지가 있는지 확인해보죠. 

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
```

docker images 명령어는 현재 시스템에서 사용가능한 이미지 일람을 보여줍니다. 이미지가 어디서 오는지 궁금하게 느껴지실지도 모릅니다. 이미지는 크게 두 가지 방법을 통해서 추가할 수 있습니다.

하나는 처음 예제에서와 마찬가지로 `docker pull <이미지 이름>`을 통해서 가져오는 방법입니다. 바로 이 명령어를 사용하면 docker.io의 공식 저장소에서 이미지를 다운로드 받아옵니다. 쉘을 활용하는 개발자라면 이런 개념이 낯설지는 않을 것입니다. 리눅스에서 `apt-get`이나 `yum` 혹은 `gem`이나 `pip`, `cpan`, `npm` 같은 명령어를 사용해보셨다면 바로 이해하실 수 있을 겁니다. 이런 유틸리티를 사용해본 적이 없다고 하더라도 마찬가지 개념으로 docker 이미지 파일들을 관리하는 중앙 저장소가 있다고 이해하셔도 무방합니다. 독특한 점은 `intsall`이 아닌 `pull` 명령어를 사용한다는 점입니다. 이에 대해서는 개념적으로 VCS(버전 관리 시스템)을 알고 계신다면 추가적인 설명이 필요없겠습니다만, 어쨌거나 단순히 다운로드라고 이해하셔도 현재 단계에서는 무방합니다.

또 다른 방법은 Dockerfile을 통해서 기술된 과정을 거쳐 도커 이미지를 생성하는 방법입니다. 이에 대해서는 아래에서 좀 더 자세히 다룹니다. 여기서는 편의상 ubuntu 이미지를 다운로드 받아오겠습니다. 이 이미지에 대한 정보는 웹을 통해서 확인하실 수 있습니다. 공식 저장소에 있는 이미지 정보들은 https://index.docker.io에서 확인할 수 있으며 우분투 이미지에 관해서는 [이 페이지](https://index.docker.io/_/ubuntu/)에서 찾을 수 있습니다.

```
$ docker pull ubuntu
Pulling repository ubuntu
04180f9bd8a6: Download complete
1e548c932d40: Download complete
5e94ff221e91: Download complete
b750fe79269d: Download complete
3e47bae8d07a: Download complete
43461fe97ba1: Download complete
8dbd9e392a96: Download complete
511136ea3c5a: Download complete
27cf78414709: Download complete
46e4dee27895: Download complete
86f6383454b4: Download complete
7a4f87241845: Download complete
1957a8106a4c: Download complete
b74728ce6435: Download complete
```

도커가 무언가를 열심히 다운로드 받습니다. 사실 이것들 하나하나가 이미지라는 것을 이해할 필요가 있습니다. 우분투 하나를 설치했을 뿐인데, 무려 14개의 이미지를 다운로드 받았습니다. 다운로드가 전부 끝났으면 이제 다시 이미지들을 확인해봅니다.

```
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              saucy               43461fe97ba1        3 days ago          144.6 MB
ubuntu              raring              5e94ff221e91        3 days ago          133.6 MB
ubuntu              quantal             3e47bae8d07a        3 days ago          127.6 MB
ubuntu              lucid               04180f9bd8a6        3 days ago          139.6 MB
ubuntu              precise             1e548c932d40        3 days ago          125.9 MB
ubuntu              12.04               8dbd9e392a96        9 months ago        128 MB
ubuntu              latest              8dbd9e392a96        9 months ago        128 MB
ubuntu              12.10               b750fe79269d        10 months ago       175.3 MB
```

그런데 저는 위에서 다운로드 받은 것들 하나하나가 이미지라고 얘기했는데 이상하게도 다운받은 이미지수와 실제로 출력되는 이미지 수가 맞지 않습니다. 이를 확인하기 위해서는 이번엔 `-a` 플래그를 통해서 모든 이미지를 출력해보겠습니다.

```
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              saucy               43461fe97ba1        3 days ago          144.6 MB
<none>              <none>              86f6383454b4        3 days ago          0 B
ubuntu              raring              5e94ff221e91        3 days ago          133.6 MB
ubuntu              quantal             3e47bae8d07a        3 days ago          127.6 MB
<none>              <none>              1957a8106a4c        3 days ago          0 B
ubuntu              lucid               04180f9bd8a6        3 days ago          139.6 MB
<none>              <none>              7a4f87241845        3 days ago          0 B
ubuntu              precise             1e548c932d40        3 days ago          125.9 MB
<none>              <none>              46e4dee27895        5 weeks ago         0 B
<none>              <none>              b74728ce6435        5 weeks ago         0 B
<none>              <none>              511136ea3c5a        7 months ago        0 B
ubuntu              12.04               8dbd9e392a96        9 months ago        128 MB
ubuntu              latest              8dbd9e392a96        9 months ago        128 MB
ubuntu              12.10               b750fe79269d        10 months ago       175.3 MB
<none>              <none>              27cf78414709        10 months ago       175.3 MB
```

`-a`(`-a=false: show all images`) 플래그는 이미지를 빌드하는 과정에서 생성되는 모든 이미지를 보여줍니다. 자세히 보시면 저장소(Repository)가 <none>인 이미지들이 존재하는 것을 알 수 있습니다. `-a` 플러그의 설명에서 알 수 있듯이 이 이미지들은 최종적인 이미지를 생성하는 과정에서 생성되는 중간 이미지들입니다. 나머지 다수의 우분투 이미지들은 TAG에서 보시듯이 다양한 버전의 이미지가 등록된 것을 알 수 있습니다.

## 컨테이너(Container)

다시 한 번 특정 이미지의 쉘에 접근해보겠습니다.

```
$ docker run -i -t ubuntu:12.04 /bin/bash
root@8bfd70fe7392:/#
```

우분투 안에 우분투에 접속하는데 성공했습니다! 짝짝짝. 그런데 앞서 말씀드렸다싶이 **이미지에 접속했다**는 말은 함정입니다. 이 말은 마치 가상머신 ssh 프로토콜을 사용해 접근한 것과 같은 착각을 일으킵니다. 이제 새로운 명령어를 하나 배워보도록 하겠습니다. 앞서서 우리가 사용한 사용가능한 이미지들을 확인하는 명령어는 `docker images`입니다. 이번에 사용할 명령어는 현재 실행중인 컨테이너들을 출력하는 명령어 `docker ps`입니다. 별도의 쉘이나 터미널을 열고 `docker ps` 실행시켜보시기 바랍니다.

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
0fae5858c9c0        ubuntu:12.04        /bin/bash           8 seconds ago       Up 7 seconds                            sleepy_nobel
```

8초전에 만들어진 컨터이너가 실행되고 있는 것을 알 수 있습니다. 여기서 우리가 실행한 컨터이너 정보를 알 수 있습니다. 우리는 `ubuntu:12.04` 이미지로부터 컨테이너를 생성했고, 이 컨테이너에 `/bin/bash`라는 쉘을 실행시켰습니다. 그 외에도 맨 앞의 컨테이너 아이디는 앞으로 Docker에서 컨테이너를 조작할 때 사용하는 컬럼이기 때문에 필수적으로 알아둘 필요가 있습니다. 물론 외우실 필요는 전혀 없습니다만.

유난처럼 느껴질지도 모릅니다만, 이미지와 컨테이너를 정확하게 짚고 넘어갈 필요가 있습니다. 하지만 그렇다고 이미지와 컨테이너 개념은 아주 헷갈리는 개념인 것은 아닙니다. 단지 이미지는 추상적인 존재라는 것을 이해하실 필요가 있습니다. 위의 예제에서는 직접 명령어를 넘겨서 이미지를 컨테이너로 실행시켰습니다만, 보통 이미지들은 자신이 실행할 명령어들을 가지고 있습니다. 예를 들어 레디스, 마리아DB, 루비 온 레일즈 어플리케이션을 담고 있는 이미지라면, 각각의 어플리케이션을 실행하는 스크립트를 실행하게되겠죠. 컨테이너는 독립된 환경에서 실행됩니다만, 컨테이너의 기본적인 역할은 이 미리 규정된 명령어를 실행하는 일입니다. 이 명령어가 종료되면 컨테이너도 종료 상태(Exit)에 들어갑니다. 이러한 죽은 컨테이너의 목록까지 확인하려면 `docker ps -a` 명령어를 사용하면 됩니다. 실제로 쉘을 종료하고 컨테이너 목록을 확인해보겠습니다.

```
root@d02cd092f62d:/# exit
exit
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
e2af61348652        ubuntu:12.04        /bin/bash           2 minutes ago       Exit 0                                  nostalgic_fermi  
```

상태(Status) 컬럼에서 확인할 수 있듯이 컨테이너가 임종하셨습니다. 이번엔 `restart` 명령어를 통해 이미지를 되살려보겠습니다. 

```
$ docker restart e2af613
e2af613
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
e2af61348652        ubuntu:12.04        /bin/bash           4 minutes ago       Up 6 seconds                            nostalgic_fermi  
```

컨테이너가 되살아났습니다! 하지만 쉘이 실행되지는 않습니다. 컨테이너 속으로 들어가기 위해서는 `attach` 명령어를 사용할 필요가 있습니다.

```
$ docker attach e2af613
root@e2af61348652:/#
```

다시 docker 컨테이너 안으로 들어왔습니다! WoW! 부활의 기적입니다. 여기까지 도커 컨테이너의 생명 주기를 보았습니다. 도커 컨테이너를 실행시키는 `run`부터 실행이 종료되었을 때 다시 실행하는 `restart`를 배웠습니다. 이 외에도 실행을 강제로 종료시키는 `stop` 명령어도 있으며, 종료된 컨테이너를 영면으로 이끌어주는 `rm` 명령어도 있습니다. 잠시 기억을 더듬어 올라가 이 글의 아주 처음에 `run` 명령어와 함께 사용한 `-rm` 플래그는 컨테이너가 종료 상태로 들어가면 자동으로 삭제를 해주는 옵션입니다.

네, 다시 한 번 이야기합니다. 이미지에는 접속한다는 개념이 없습니다. 실제로 실행되는 **가상 머신**은 항상 컨테이너입니다. 네, 분명 저는 '명령어'를 실행시킨다고 했습니다만, 컨테이너는 격리된 환경에서 특정한 명령을 실행시켜주는 가상 머신과 같은 무언가입니다. 그렇다면 쉘을 실행시키지 않았을 때 이 가상 머신을 조작할 수 있는 방법이 있을까요? 이게 참 애매모호합니다. 분명히 불가능한 것은 아닙니다. 이 부분에 대해서 여기선 다루지 않습니다만, 직접 파일 시스템을 조작할 수도 있고, 리눅스 컨테이너를 조작해 특정 컨테이너에 대해 쉘을 실행시킬 수도 있습니다. 하지만 좀 더 올바른 방법은 조작이 필요한 컨테이너에 ssh 서비스를 올려서 ssh 프로토콜로 접근하는 방법입니다. 실제 도커로 서비스를 운영하면 필요할 날이 오겠지만, 일단은 그렇구나 하고 넘어가셔도 무방합니다.

## 버전 관리 시스템과 도커

다시 이미지로 돌아가겠습니다. 한 가지 질문을 던져보죠. 좋습니다. 이미지와 컨테이너는 다릅니다. 근데 그렇다면 이 컨테이너를 지지고 볶고 삶고 데치고 하면 이미지는 어떻게 될까요?

네. 이미지에는 아무런 변화도 생기지 않습니다. 아주 세속적인 예를 들어보면 윈도우 CD로 윈도우를 설치해서 사용한다고 해서 설치한 윈도우 CD에 어떤 변화가 생기지는 않는 것과 같은 이치입니다. 이미지는 어디까지나 고정된 이미지입니다. 도커에서 이미지는 불변(Immutable)하는 저장 매체입니다. 그런데 도커에서는 이미지는 불변이지만 이 이미지 위에 무언가를 더해서 새로운 이미지를 만들어내는 일이 가능합니다. 좀 더 정확히 말하면 컨테이너는 변경가능(Mutabe)합니다. 특정한 이미지로부터 생성된 컨테이너에 어떤 변경사항을 더하고, 이 변경된 상태를 이미지로 만들어내는 것이 가능합니다.

앞서 실행한 컨테이너 Git을 설치해보겠습니다. 위에 실행된 쉘에서 다음과 같은 명령어를 입력합니다.

```
root@e2af61348652:/# apt-get install -y git
...
root@e2af61348652:/# git --version
git version 1.7.9.5
```

우분투의 패키지 관리자인 apt-get을 통해서 버전 관리 시스템인 `Git`을 설치했습니다. 도커는 마치 자신이 VCS인양, 어떤 컨테이너와 이 컨테이너의 부모 이미지 간의 파일의 변경사항을 확인할 수 있는 명령어를 제공합니다. 마치 `git diff` 명령어르 프로젝트의 변경사항을 확인하듯이, 컨테이너 쉘 바깥에서 `docker diff` 명령어로 부모 이미지와 여기서 파생된 컨테이너의 파일 시스템 간의 변경사항을 확인할 수 있습니다. 

```
$ docker diff e2af61
A /.bash_history
A /.wh..wh.plnk/310.4862541
A /.wh..wh.plnk/93.4862548
C /bin
A /bin/less
...
C /var/log/alternatives.log
C /var/log/apt
A /var/log/apt/history.log
A /var/log/apt/term.log
C /var/log/dpkg.log
```

이제 기본 우분투 12.04 이미지에 Git를 설지한 새로운 이미지를 생성해보도록 하겠습니다. 이 작업도 VCS와 매우 비슷합니다. 도커에서는 이 작업을 `commit`이라고 합니다.

```
$ docker commit e2af61 ubuntu:git
5ff1d6b1c5db272c3f1a88c96f78146ed48d18848f0a10e6aefa066b462ff5ee
$ docker images | grep git
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              git                 5ff1d6b1c5db        About a minute ago   222.3 MB
```

이미지 만들기 정말 쉽죠? 단지 커밋을 하고 뒤에 이름을 붙여주면 바로 새로운 도커 이미지가 생성됩니다. 이미지로부터 컨테이너를 실행시키고 이 컨테이너의 수정사항을 통해서 새로운 이미지를 만들었습니다. 그렇다면 정말로 이 이미지를 통해서 컨테이너를 실행시키면(`run`) git가 잘 들어가 있을까요? 직접 확인해보죠.

```
$ docker run -i -t ubuntu:git /bin/bash
root@27d4e3090750:/# git --version
git version 1.7.9.5
```

너무 감동적이라 눙물이 나올 것 같습니다 TT.

하지만 이 이미지는 별로 필요가 없군요. 저는 공은 공 사는 사, 낭비라하면 물 한 방울 용서하지 않는 냉혈한올시다. 필요없는 이미지는 삭제해버리겠습니다. 하나 알아두셔야 하는 중요한 사항은, 이미지에서 (종료상태를 포함한) 파생된 컨테이너가 하나라도 있다면 이미지는 삭제할 수 없습니다. (처음에 이 부분을 정확히 이해하지 못 해 한참을 해맸던 기억이 납니다. 흙) 따라서 먼저 컨테이너를 종료하고, 삭제까지 해주어야합니다. `docker rm`은 컨테이너를 삭제하는 명령어입니다. `docker rmi`는 이미지를 삭제하는 명령어입니다. 이 두 명령어를 혼동하지 않아야합니다.

먼저 컨테이너를 지우고, 이미지를 삭제해보겠습니다.

```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
27d4e3090750        ubuntu:git          /bin/bash           4 minutes ago       Exit 0                                  silly_heisenberg
$ docker rm 27d4e
27d4e
$ docker rmi ubuntu:git
Untagged: 5ff1d6b1c5db272c3f1a88c96f78146ed48d18848f0a10e6aefa066b462ff5ee
Deleted: 5ff1d6b1c5db272c3f1a88c96f78146ed48d18848f0a10e6aefa066b462ff5ee
```

브라보! 이번에는 도커 이미지의 생명주기를 배웠습니다. 도커 이미지를 `pull`로 받아오고 `commit`
으로 파생된 이미지를 만들고 `rmi` 명령어로 삭제까지 해보았습니다. 컨테이너와 이미지의 생명주기만 이해하고 나면 도커의 80%는 마스터한 거나 다름 없습니다. 도커를 통해서 하는 일은 거의 다 이 이미지와 컨테이너 개념으로 커버가 가능합니다. 이제 남은 일은 자신에게 필요한 **이미지**를 만들고 이 이미지를 통해서 컨테이너(가상 머신)을 실행하는 일입니다. 물론 이제 기본적인 개념들을 배웠으니 오픈된 중앙 저장소격에 해당하는 [Docker Index](https://index.docker.io/)에서 이미 만들어져있는 다양한 이미지들을 활용할 수도 있습니다. 도커의 모토를 잊지 마시기 바랍니다. 거짓말 조금 보태서(?!) 완성된 이미지는 언제 어디에 서라 도  가동 가능합니다.

## Dockerfile로 이미지 생성하고 어플리케이션 실행시키기

멀리 돌아왔습니다. 앞서서 도커 이미지를 추가하는 방법은 크게 세 가지가 있다고 이야기했습니다. 먼저 `pull`을 사용하는 방법은 이미 앞에서 다룬 바 있습니다. 그리고 컨테이너의 변경사항으로부터 이미지를 만드는 법에 대해서도 소개했습니다. 이러한 방법들은 매우 좋기는 하지만, 어딘가 2% 부족합니다. 이를 보완해주는 Dockerfile이라고 불리는 도커 이미지 생성용 배치 파일이 있습니다.

Dockerfile은 특정한 이미지를 출발점으로 새로운 이미지 구성에 필요한 일련의 명령어들을 저장해놓는 파일입니다. 미리 만들어둔 docker-moniwiki라는 프로젝트를 통해서 간단히 Dockerfile을 설명하고, 실제로 모니위키 어플리케이션을 가진 이미지를 생성하고 컨테이너를 통해서 실행시켜보도록하겠습니다. 먼저 프로젝트를 clone 받습니다.

```
git clone https://github.com/nacyot/docker-moniwiki.git
```

이 프로젝트에는 3개의 파일이 있습니다만, 실질적으로 Dockerfile 하나밖에 없다고 보셔도 무방합니다. 전체 파일 내용은 다음과 같습니다.

```
FROM ubuntu:12.04
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>

# Run upgrades
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# Install basic packages
RUN apt-get -qq -y install git curl build-essential

# Install apache2
RUN apt-get -qq -y install apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN a2enmod rewrite

# Install php
RUN apt-get -qq -y install php5
RUN apt-get -qq -y install libapache2-mod-php5

# Install Moniwiki
RUN apt-get install rcs
RUN cd /tmp; curl -L -O http://dev.naver.com/frs/download.php/8193/moniwiki-1.2.1.tgz
RUN tar xf /tmp/moniwiki-1.2.1.tgz
RUN mv moniwiki /var/www/
RUN chown -R www-data:www-data /var/www/moniwiki
RUN chmod 777 /var/www/moniwiki/data/ /var/www/moniwiki/
RUN chmod +x /var/www/moniwiki/secure.sh
RUN ./var/www/moniwiki/secure.sh

EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
```

보시는 바와 같이 Dockerfile은 모니위키를 설치하는 일련의 과정과 서버를 실행하는 명령어로 구성되어 있습니다. 각각의 부분을 간략히 살펴보겠습니다.

```
FROM ubuntu:12.04
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>
```

먼저 맨 위에 정의된 `FROM`은 어떤 이미지로부터 새로운 이미지를 생성할 지를 지정합니다. 다음으로 MAINTAINER는 이 Dockerfile을 생성-관리하는 사람을 입력해줍니다.

```
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
```

`RUN`은 직접 쉘 명령어를 실행하는 명령어입니다. 이 때 바로 뒤에 명령어를 입력하게 되면 쉘을 통해서 명령어가 실행됩니다. 위의 두 줄은 패키지 관리자 `apt-get`에 저장소를 추가하고 저장소 정보를 갱신하는 명령어입니다.

```
# Install basic packages
RUN apt-get -qq -y install git curl build-essential

# Install apache2
RUN apt-get -qq -y install apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN a2enmod rewrite

# Install php
RUN apt-get -qq -y install php5
RUN apt-get -qq -y install libapache2-mod-php5
```

다음 부분에서는 모니위키 설치에 필요한 패키지들과 apache2 서버, php 프로그램을 설치 및 설정해줍니다. 아파치 설치 과정에서 나오는 `ENV`를 통해 환경 변수를 지정할 수 있습니다.

```
# Install Moniwiki
RUN apt-get install rcs
RUN cd /tmp; curl -L -O http://dev.naver.com/frs/download.php/8193/moniwiki-1.2.1.tgz
RUN tar xf /tmp/moniwiki-1.2.1.tgz
RUN mv moniwiki /var/www/
RUN chown -R www-data:www-data /var/www/moniwiki
RUN chmod 777 /var/www/moniwiki/data/ /var/www/moniwiki/
RUN chmod +x /var/www/moniwiki/secure.sh
RUN ./var/www/moniwiki/secure.sh
```

이제 실제로 모니위키를 설치합니다. 여기서는 모니위키를 curl을 통해서 다운로드 받고, 압축을 풀고 모니위키 실행에 필요한 권한 관련 설정을 해주고 있습니다.

```
EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
```

이제 마지막입니다. `EXPOSE`는 가상 머신에 오픈할 포트를 지정해줍니다. 마지막줄의 `CMD`는 컨테이너에서 실행될 명령어를 지정해줍니다. 이 글의 앞선 예에서는 `docker run`을 통해서 `/bin/bash`를 실행했습니다만, 여기서는 아파치 서버를 `FOREGROUND`에 실행시킵니다.

자 기다리고 기다리던 대망의 순간이 왔습니다. 직접 이 Dockerfile을 빌드할 차례입니다.

```
$ docker build -t nacyot/moniwiki .
Uploading context 71.68 kB
Uploading context
Step 1 : FROM ubuntu:12.04
---> 8dbd9e392a96
Step 2 : MAINTAINER Daekwon Kim <propellerheaven@gmail.com>
---> Running in a2af31ca9d62
---> c42835b9308b
Step 3 : RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
---> Running in d305ce1fea04
---> f4cb16c39b0e
Step 4 : RUN apt-get update
...
---> c63d093aacfb
Step 21 : EXPOSE 80
---> Running in cee6a6048c83
---> 7436a638e52c
Step 22 : CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
---> Running in 2f251c355290
---> 0a148bb4de2f
Successfully built 0a148bb4de2f
```

`docker build` 명령어는 `-t` 플래그를 사용해 이름과 태그를 지정할 수 있습니다. 그리고 마지막에 `.`은 빌드 대상 디렉토리를 가리킵니다. 이 때 알아두면 좋은 게 하나 있습니다. 위에서 정의한 `RUN` 명령 하나 하나는 명령 하나마다 이미지가 됩니다. 기본적으로 이 빌드를 통해서 생성되는 최종 이미지는 `nacyot/moniwi`가 됩니다만, `docker images -a`를 통해서 살펴보면 이름없는 도커 이미지들이 다수 생성되는 것을 알 수 있습니다.


```
$ docker images -a
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
<none>              <none>              c63d093aacfb        4 minutes ago       670.4 MB
<none>              <none>              7436a638e52c        4 minutes ago       670.4 MB
nacyot/moniwiki     latest              0a148bb4de2f        4 minutes ago       670.4 MB
<none>              <none>              49825025193f        4 minutes ago       670.4 MB
<none>              <none>              5b374f859553        4 minutes ago       670.4 MB
<none>              <none>              c8afe13ab509        4 minutes ago       670.4 MB
<none>              <none>              bb65aa482123        4 minutes ago       663.1 MB
<none>              <none>              fa7f2059c9ba        4 minutes ago       655.8 MB
<none>              <none>              1a18589e4d9a        4 minutes ago       648.5 MB
<none>              <none>              fdd759b53314        4 minutes ago       646.1 MB
<none>              <none>              786c8ad1df43        4 minutes ago       610.5 MB
<none>              <none>              14e8b032683a        4 minutes ago       610.5 MB
<none>              <none>              6be08754c2ae        4 minutes ago       547.9 MB
<none>              <none>              67e17f5a39f1        4 minutes ago       547.9 MB
<none>              <none>              55ec9487188b        4 minutes ago       547.9 MB
<none>              <none>              88a61604a1d0        4 minutes ago       547.9 MB
<none>              <none>              7edabbb84352        4 minutes ago       547.9 MB
<none>              <none>              78e9afc826cd        4 minutes ago       503 MB
<none>              <none>              8066398c160f        5 minutes ago       272.5 MB
<none>              <none>              f4cb16c39b0e        6 minutes ago       128 MB
<none>              <none>              c42835b9308b        6 minutes ago       128 MB
```

이미지 아이디가 빌드 과정에서 출력되는 아이디와 같은 것을 알 수있습니다. 필요한 경우 중간 이미지에 접근하거나 직접 중간 이미지로부터 다른 이미지를 생성하는 것도 가능합니다. 정말 좋은 소식은 도커는 이러한 빌드 순서를 기억하고 각 이미지를 보존하기 때문에 같은 빌드 과정에 대해서는 캐시를 사용해 매우 빠르게 빌드가 가능하다는 점입니다. 실제로 Docker 파일을 만드는 과정에서는 많은 시행 착오를 겪게되는데, 중간에 빌드가 실패하더라도 성공했던 명령어까지는 거의 시간 소모 없이 빠르게 진행되도록 설계되어있습니다.

빌드 자체는 꽤나 번거로운 일입니다. 도커의 가상화가 굉장히 빠르다고 해도 어플리케이션 실행환경을 구축하는 일은 상당히 시간도 많이 걸립니다. 더욱이 빌드 자체는 완벽히 '재현 가능'하지 않습니다. 하지만 이렇게 Dockerfile을 통해서 배치화를 시켜두면 Dockerfile이라는 정말 작은 파일 하나로 어플리케이션 배포 환경을 구축할 수 있다는 장점이 있으며, 또한 쉽게 유연하게 사용할 수 있습니다. 아주 흥미로운 이야기를 하나 해드리자면 Docker 생태계에 있는 오픈소스 어플리케이션들은 아예 Dockerfile을 프로젝트에 포함하고 있습니다. 대표적으로 도커 모니터링 툴인 [Shipyard](https://github.com/shipyard/shipyard)가 있습니다. 여기서 제공하는 Dockerfile을 빌드해서 이미지를 만들고, 이 이미지로 컨테이너를 가동하면 바로 shipyard 어플리케이션을 사용할 수 있습니다. 전율이 느껴지시나요?

Dockerfile은 단순히 어플리케이션 설치를 스크립트로 만들어주는 게 아니라, 배포환경 구축까지 한꺼번에 해주는 역할을 합니다. 오래전 제로보드나 테터툴즈 한 번 설치해보겠다고 `<? phpinfo() ?>` 찍어가며 php랑 aphche랑 잘 붙었나 안 붙었나 확인해보고 안 되면 이유도 못 찾아 혼자 서러워했던 적이 있는 분이라면(어라?) 이해하리라 믿습니다. 다른 예를 들어볼까요? 설치가 까다로운 걸로 악명높은 오픈소스 웹 어플리케이션 중에 [Gitlab](http://gitlab.org/)이라는 어플리케이션이 있습니다. [gitlab-docker](https://github.com/crashsystems/gitlab-docker)에서 제공하는 `Dockerfile` 하나면 이제 Gitlab도 두렵지 않습니다. 그저 `Build`하고 `Run`하면 Gitlab이 뜹니다.

네, 얘기가 길어졌네요. 다시 모니위키로 돌아갑니다. 빌드가 끝났으니 실행을 해보겠습니다.

```
$ docker run -d -p 9999:80 nacyot/moniwiki
746443ad118afdb3f254eedaeeada5abc2b125c7263bc5e67c2964b570166187
```

다시 `docker run` 입니다. 이번에는 `-d`와 `-p` 플래그를 사용합니다. 앞서서 자세히 설명하진 않았습니다만, `-d` 플래그는 `-i` 플래그의 반대 역할을 하는 플래그로, 컨테이너늘 백그라운드에서 실행시켜줍니다. `-p`는 포트포워딩을 지정하는 플래그입니다. `:`을 경계로 앞에는 외부 포트, 뒤로는 내부 포트입니다. 참고로 컨테이너 안에서 아파치가 80포트로 실행됩니다. 따라서 여기서는 localhost에 9999로 들어오는 연결을 여기서 실행한 컨테이너의 80포트로 보내도록합니다.

이제 정말 마지막입니다. 로컬의 9999 포트에 접근해 정말로 모니위키가 실행되는지 보도록 하겠습니다.

```
http://127.0.0.1:9999/moniwiki/
```

![모니위키 설치 페이지](/images/2014-01-27-easy-deploy-with-docker/moniwiki.png)

올레! 잘 돌아가네요. 

## 정리

도커의 활용가능성은 무궁무진합니다. 당연히 실제 배포에도 사용할 수 있고, 유연하고 날렵한 격리된 환경을 활용해 실험적인 개발을 진행할 수도 있습니다. Vagrant보다도 훨씬 빠른 가상 환경을 활용할 수 있으며 접근 방법은 다르지만 서버환경을 자동적으로 구성할 수도 있습니다. 미리 만든 이미지를 자신의 저장소(registry)에 등록해 여러대의 머신에 컨테이너들을 자동적으로 배포할 수도 있고, 오픈소스 프로젝트에서 Dockerfile을 제공해 설치를 색다른 방법으로(?) 지원할 수도 있습니다. [Dokku](https://github.com/progrium/dokku)를 사용하면 정말 쉽게 mini-heroku와 같은 PaaS 플랫폼을 구축해 볼 수도 있습니다.

단순히 생산성을 넘어, 도커의 매력은 상상력을 자극한다는 점입니다. 특히나 서버 자동화가 화두인 요즘에 인프라스트럭쳐가 **코드**로 변해버리는 묘한 체험을 하게 해줍니다. 인프라스트럭쳐가 코드가 되면 뭔가 신기한 일들이 벌어집니다. 이런 상황에서 아직까지 낯설게 느껴질지도 모르는 개념이고 툴입니다만 직접 설치하고  이것저것 해보다보면 저처럼 분명 반하실 거라 생각합니다 :)
