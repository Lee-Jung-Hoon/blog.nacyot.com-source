도커(Docker) 깐 김에 배포까지
=============================

클라우드와 같이 잘 짜여지고, 잘 나뉘어진 거대한 시스템에서야 그렇다 치더라도 가상 머신은 여러모로 손실이 많은 수단 중 하나입니다. 격리된 환경이고 독자적인 환경이라는 데서 아무 매력적이긴 하지만(!), 실제 배포용으로 쓰기에는 성능 면에서 매우 불리한 도구라고 할 수 있습니다. 당연한 이야기입니다만 일단 운영체제 위에서 또 다른 운영체제를 통째로 돌린다는 것 자체가 리소스를 비효율적으로 활용할 수밖에 없습니다.

이런 흐름 속에서 가상 머신의 단점은 극복하면서 장점만을 극대화하기 위한 최적화는 끊임없이 이루어지고 있습니다. Docker 역시 이러한 단점을 극복하기 위해 나온 Docker는 쉽게 얘기하면 배포를 위한 아주 가벼운 가상 머신입니다. LXC(리눅스 컨테이너)라는 독특한 개념에서 출발하는 Docker의 가상화는 기존에 운영체제를 통째로 가상화하는 것과는 접근 자체를 달리하는 방법입니다. 가상 머신이라기보다는 격리된 환경을 만들어주는 도구로 보는 게 좀 더 정확합니다.

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

먼저 위의 pull 명령어를 통해서 centos 이미지를 다운로드 받습니다. 그리고 이 이미지에 쉘 명령어를실행시킵니다. 끝입니다. 먼저 첫번째 명령어를 실행시키는데 제 컴퓨터에서 12초 정도가
걸렸습니다. 아래 명령어를 실행시키는데 0.3초가 걸리지 않았습니다. 쉘이 실행되면 bash 쉘로 바뀐 것을 알 수 있습니다. 실제로 CentOS인지 확인해보도록 하겠습니다.

```
bash-4.1# cat /etc/issue
CentOS release 6.4 (Final)
Kernel \r on an \m

```

어떻게 이런 일이 가능할까요? 글쎄요. 저도 이 부분에 대한 이해가 깊지는 않습니다. 이 부분에 관해서는 공식 문서를 비롯해 이미 다양한 리소스들이 있으니 검색해보면 좋은 글들을 금방 찾을 수 있을 것 같습니다. 한국어로 된 좋은 자료로는 Deview에서 @@@ 들이 있습니다. 하지만 분명한 건 VMWare를 사용한다고 해서 가상화 기술에 빠삭한 건 아니듯이, Docker 역시 기본적으로는 툴이라는 사실을 이해해야합니다. 제 생각에 정말로 중요한 건 도커의 인사이드를 이해하는 것도 중요하지만, 실상 이 도구를 사용해보면  컨테이너와 이미지의 차이를 이해하는 게 더 중요하고, Dockerfile을 만들어 자신만의 배포 프로세스를 저장하는 법을 익히는 게 중요합니다.

이 글에서는 바로 이러한 시점에서 개발 환경이자 배포 툴로서 도커를 이해하기 위한 개념들을 소개하고 실제로 간단한어플리케이션을 배포하는 부분까지 다뤄보도록 하겠습니다. 좀 더 자세한 이야기는 다른 글에서 진행하도록 하겠습니다.

## 설치

각 운영체제 별 Docker의 설치 방법은 공식 홈페이지에 잘 정리되어 있습니다. 제가 사용하는 Ubuntu의 경우에는 Docker에서 제공하는 스크립트 파일 하나를 통해서 원큐에 정말 쉽게 Docker를 설치할 수 있습니다. 가상 머신에서도 설치가 가능하니, 가능하다면 Ubuntu 환경을 사용하길 권장합니다. 네, 글을 쓰는 편의상.

```
curl -s https://get.docker.io/ubuntu/ | sudo sh
```

물론 curl이 설치 되어있어야합니다. 1월 현재 12.04 / 13.10에서도 같은 방법으로 설치가 가능했습니다만, 설치 과정에 문제가 있거나 다른 운영체제를 사용하시는 경우엔 설치 문서를 꼼꼼히 읽어보시고 진행해나가시기 바랍니다. 설치가 끝나면 설치가 잘 됐나 확인해봅니다.

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

## 이미지

설치만 끝났다면, 이제 끝이 보입니다. 대단하지만 정말 별 게 없습니다. 먼저 도커를 시작하면 이미지 개념을 이해할 필요가 있습니다. 처음에 보여드린 예제를 보면 centos 이미지를 다운로드 받고, 이 이미지에 shell을 실행시킵니다. 그런데 여기에 약간의 함정이 있습니다. Docker에서 실제로 실행되는 건 이미지가 아닙니다! 이미지는 추상적인 개념입니다. 실행되는 건 이미지를 기반으로 생성된 컨테이너입니다. 먼저 어떤 일이 일어나는지 확인해보도록 하겠습니다.

먼저 `docker images` 명령어로 시스템에 어떤 이미지가 있는지 확인해보죠. 

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
```

docker images 명령어는 현재 시스템에서 사용가능한 이미지 일람을 보여줍니다. 이미지가 어디서 오는지 궁금하게 느껴지실지도 모릅니다. 이미지는 크게 두 가지 방법을 통해서 추가할 수 있습니다.

하나는 처음 예제에서와 마찬가지로 `docker pull <이미지 이름>`을 통해서 가져오는 방법입니다. 바로 이 명령어를 사용하면 docker.io의 공식 저장소에서 이미지를 다운로드 받아옵니다. 너무 생소하게 받아들이시지 않아도 리눅스에서 `apt-get`이나 `yum` 혹은 `gem`이나 `pip`, `cpan`, `npm` 같은 명령어를 사용해보셨다면 바로 이해하실 수 있을 겁니다. 이런 유틸리티를 사용해본 적이 없다고 하더라도  마찬가지 개념으로 docker 이미지 파일들을 관리하는 중앙 저장소가 있다고 이해하셔도 무방합니다. 독특한 점은 `intsall`이 아닌 `pull` 명령어를 사용한다는 점입니다. 이에 대해서는 개념적으로 VCS(버전 관리 시스템)을 알고 계신다면 추가적인 설명이 필요없겠습니다만, 어쨌거나 다운로드라고 이해하셔도 현재 단계에서는 무방합니다.

또 다른 방법은 Dockerfile을 통해서 이ㅜ

이번에는 편의상 ubuntu 이미지를 다운로드 받아오겠습니다. 이 이미지에 대한 정보는 웹을 통해서 확인하실 수 있습니다. 공식 저장소에 있는 이미지 정보들은 https://index.docker.io에서 확인할 수 있으며 우분투 이미지에 관해서는 [이 페이지](https://index.docker.io/_/ubuntu/)에서 찾을 수 있습니다.

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

무언가를 열심히 다운로드 받습니다. 사실은 이것들 하나하나가 이미지라는 것을 이해할 필요가 있습니다. 다운로드가 전부 끝났으면 이제 다시 이미지들을 확인해봅니다.

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

`-a`(`-a=false: show all images (by default filter out the intermediate images used to build`) 플래그는 이미지를 빌드하는 과정에서 생성되는 모든 이미지를 보여줍니다. 


## 이미지



## 컨테이너

## 








## 이미지에 쉘을 실행시키기

## 이미지를 수정하고 저장하기

## Git스러운 도커



## 컨테이너에 ssh로 접속하기

## 