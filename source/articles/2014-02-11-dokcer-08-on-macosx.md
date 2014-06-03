---
title: "도커(Docker) 튜토리얼 : 0.8 맥에서 설치하기"
date: 2014-02-11 00:16:00 +0900
author: nacyot
tags: boot2docker, ubuntu, 우분투, macosx, 맥, lxc, virtual machine, 가상머신, coreos, docker, 도커
---

[도커][docker]는 리눅스 위에서 격리된 또 다른 [[리눅스|linux]] 환경을 구축할 수 있도록 해주는 가상화 어플리케이션입니다. 기존의 가상화 어플리케이션에서 하드웨어 전체를 가상화하는 것과 달리 리눅스 컨테이너를 활용하고 있는 도커는 아주 빠르고 쉽게 가상화 환경을 사용할 수 있도록 해줍니다. 이전 [도커(Docker) 소개 글][docker_introduction]을 올린 바 있습니다만, 바로 얼마 전 도커가 0.8로 업데이트되었습니다. 0.8에서 가장 큰 변화중 하나는 [[맥|macosx]]을 지원하는 부분입니다. 여기서는 어떤 방식으로 맥을 지원하는 지 알아보고 실제로 설치하는 법에서 다루도록 하겠습니다.

<!--more-->

[docker]: http://docker.io
[docker_introduction]: http://blog.nacyot.com/articles/2014-01-27-easy-deploy-with-docker/

## TL;DR, 맥에서 바로 도커 시작하기 ##

1. Virtual 박스 설치
1. docker, boot2docker 설치

```
$ brew tap homebrew/binary
$ brew install docker boot2docker
```

1. boot2docker 실행

```
export DOCKER_HOST=tcp://¶
$ ./boot2docker init
$ ./boot2docker up
```

1. 도커 컨테이너 실행

```
$ docker pull ubuntu
$ docker run -rm -i -t ubuntu:latest /bin/bash
```

## 맥에서 도커를 실행하는 원리 ##

도커는 기본적으로 리눅스 컨테이너(이하 [[lxc]])를 지원하는 운영체제만 사용할 수 있습니다. 처음에는 [[우분투|ubuntu]]만 지원을 했습니다만 현재는 좀 더 다양한 운영체제를 지원하도록 확장해나가는 과정에 있습니다. 하지만 원론적으로 lxc를 지원하고 있지 않은 윈도우나 맥에서는 도커를 사용할 수 없습니다. 

하지만 엄밀히 말하면 이전에도 맥이나 윈도우에서 도커를 사용하는 것이 불가능한 것은 아니었습니다. 그러면 어떻게 설치를 하는지, 간단히 말해 [Vagrant][vagrant]나 아예 별개의 가상화 어플리케이션을 통해서 리눅스 운영체제를 실행시키는 방식이었습니다. 이렇나 방식이 당연히 가능한 건, 아예 OS를 lxc를 지원하는 리눅스를 가상 머신으로 올려놓기 때문입니다. 물론 이렇게도 도커를 사용하는 것이 불가능한 것은 아닙니다만, VM의 성능도 성능이고 리눅스 운영체제에 비해서 '한 다리' 건너서 사용한다는 인상을 지우기는 어렵습니다.

그런데 [도커 블로그에선 0.8 발표][docker08]와 함께 맥의 공식 지원을 언급하고 있습니다.

> Today we are happy to introduce Docker 0.8, with a focus on Quality and 3 notable features: new builder instructions, a new BTRFS storage driver, and official support for Mac OSX. You can see the full Changelog on the repository, and read below for details on each feature.


그렇다면 여기서 공식으로 지원한다는 얘기는 무슨 얘기일까요? 맥이 lxc를 지원하지 않는다면 네이티브에서 도커를 실행한다는 건 근본적으로 불가능합니다. 그렇다면 여전히 근본적인 해결책은 아닙니다만, 여기서 공식지원이 의미하는 바는 기존에 VM을 사용하는 부하를 극도로 줄인 환경을 도커가 직접 제공해준다는 걸 의미합니다. 가상 머신은 여전히 올라갑니다. 이 때 사용되는 운영체제가 [boot2docker][boot2docker]라는 단지 도커만을 위한 초경량 리눅스 [Tiny Core Linux][tcl] 배포판 중 하나입니다. 이 운영체제는 RAM에서 작동하며 매우 적은 용량에 단 몇 초만에 부팅이 가능합니다(그렇다고 이야기하고 있습니다). 도커 컨테이너 만큼은 아니겠지만 매우 빠릅니다. 이러한 가상 머신 부분의 경량화와 맥 클라이언트에서 Docker 명령어를 직접 사용할 수 있게 함으로써, 맥에서 네이티브나 다름없는 도커 지원을 실현했습니다.

![docker2boot](https://github-camo.global.ssl.fastly.net/fd2fda3c0d55a0a63873f4221ddbe2f1dda145c5/687474703a2f2f692e696d6775722e636f6d2f68497775644b332e676966)

네이티브 환경에 비하면 약간의 불만족은 남아있겠습니다만, 그럼에도 불구하고 개발환경을 구축하는 데는  손색이 없습니다. 

[vagrant]: http://www.vagrantup.com/
[docker08]:  http://blog.docker.io/2014/02/docker-0-8-quality-new-builder-features-btrfs-storage-osx-support/
[boot2docker]: https://github.com/steeve/boot2docker
[tcl]: http://tinycorelinux.net/

## 맥에서 boot2docker를 활용한 도커 설치 ##

네, 그렇다면 실제로 설치를 해보도록 하겠습니다. 

먼저 docker2boot를 사용하기 위해서는 [VirtualBox][virtual_box]를 설치해야합니다. 공식 사이트에서 MacOSX용 dmg 파일을 다운로드 받아 설치 과정을 진행해주시기 바랍니다.

도커 공식 사이트에서는 [맥에서 설치를 위한 문서][docker_install_on_mac]를 제공하고 있으니 참조하시기 바랍니다. 먼저 [[boot2docker]]를 다운로드 받고 실행권한을 추가해줍니다.

```
$ mkdir ~/bin
$ cd ~/bin
$ curl https://raw.github.com/steeve/boot2docker/master/boot2docker > boot2docker
$ chmod +x boot2docker
```

다음으로 도커를 다운로드 받고 실행권한을 추가해줍니다. 이 때 DOCKER_HOST를 추가하는 가상 머신의 도커에 접속하기 위함입니다.

```
$ curl -o docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
$ chmod +x docker
$ export DOCKER_HOST=tcp://
$ sudo cp docker /usr/local/bin/
```

도커와 boot2docker 설치 과정은 [[homebrew]]를 통해서도 진행이 가능합니다.

```
$ brew tap homebrew/binary
$ brew install docker boot2docker
```

다음으로 boot2docker를 실행시킵니다. 이 과정을 거치기 전에 [[VirtualBox]]를 설치했는지 꼭 확인하시기 바랍니다.

```
$ ./boot2docker init
$ ./boot2docker up
[2014-02-10 23:40:41] Starting boot2docker-vm...
[2014-02-10 23:41:01] Started.
```

맥북 에어에서 실제로 걸린 시간은 이미지 다운로드하는데 30여초, 기동하는데 20여초가 걸렸습니다. 설치는 끝이났습니다. 이제 설치가 잘 되었는지 버전 출력을 해보도록 하겠습니다.

```
$ docker version
Client version: 0.8.0
Go version (client): go1.2
Git commit (client): cc3a8c8
Server version: 0.8.0
Git commit (server): cc3a8c8
Go version (server): go1.2
```

[virtual_box]: https://www.virtualbox.org/wiki/Downloads
[docker_install_on_mac]: http://docs.docker.io/en/latest/installation/mac/

## 도커 실행 테스트 ##

그렇다면 정말로 가상머신이 잘 올라간 상태로 도커가 사용 가능한지 테스트해보도록 하겠습니다.

```
$ docker pull ubuntu
Pulling repository ubuntu
eb601b8965b8: Download complete
9cc9ea5ea540: Download complete
9f676bd305a4: Download complete
9cd978db300e: Download complete
5ac751e8d623: Download complete
511136ea3c5a: Download complete
f323cf34fd77: Download complete
1c7f181e78b9: Download complete
6170bb7b0ad1: Download complete
321f7f4200f4: Download complete
7a4f87241845: Download complete
```

이미지 pull도 한 번 해보고,

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              13.10               9f676bd305a4        6 days ago          178 MB
ubuntu              saucy               9f676bd305a4        6 days ago          178 MB
ubuntu              13.04               eb601b8965b8        6 days ago          166.5 MB
ubuntu              raring              eb601b8965b8        6 days ago          166.5 MB
ubuntu              12.10               5ac751e8d623        6 days ago          161 MB
ubuntu              quantal             5ac751e8d623        6 days ago          161 MB
ubuntu              10.04               9cc9ea5ea540        6 days ago          180.8 MB
ubuntu              lucid               9cc9ea5ea540        6 days ago          180.8 MB
ubuntu              12.04               9cd978db300e        6 days ago          204.4 MB
ubuntu              latest              9cd978db300e        6 days ago          204.4 MB
ubuntu              precise             9cd978db300e        6 days ago          204.4 MB
```

pull 해온 이미지 리스트도 한 번 보고, 컨테이너 리스트도 출력해보죠.

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS             PORTS               NAMES
```

오오 pull도 되고 images 명령어도 먹는 걸 볼 수 있습니다. 아직 실행한 컨테이너는 없으니 아무것도 뜨지 않습니다. 일단 작동하고 있는 것 같습니다. 마지막으로 컨테이너를 올려보겠습니다.

```
$ docker run -rm -i -t ubuntu:latest /bin/bash
root@e616c4c3fd53:/# 
```

컨테이너 안의 쉘이 실행된 화면을 바로 확인하실 수 있습니다.

## 트러블 슈팅 ##

```
export DOCKER_HOST=tcp://¶
```

명령어를 통해 DOCKER_HOST를 반드시 설정해줘야합니다. 이 설정을 하지 않으면

```
$ docker images
2014/02/10 23:48:19 dial unix /var/run/docker.sock: no such file or directory
```

와 같은 에러가 발생합니다. 이는 도커가 기본적으로 로컬 머신 상의 /var/run/docker.sock를 통해서 작동하기 때문입니다. 이를 가상 머신에서 가동중인 docker와 바로 연동할 수 있도록 `tcp://`로 연결하도록 설정해주는 것입니다. 같은 의미로 `export DOCKER_HOST=localhost`를 실행해도 됩니다.

또한 `./boot2docker` 명령어를 통해서 

```
$ ./boot2docker
Usage ./boot2docker {init|start|up|pause|stop|restart|status|info|delete|ssh|download}
```

boot2docker를 재실행하거나 멈추는 작업을 수행할 수 있습니다.

## 정리 ##

이제 무거운 가상 머신 없이도 맥에서 도커를 부담없이 설치하고 사용해볼 수 있습니다 >_<
