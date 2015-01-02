---
title: "우분투(Ubuntu) 14.04에서 도커(Docker) 설치 및 사용하기"
date: 2014-04-19 00:15:32 +0900
author: nacyot
tags: ubuntu, 우분투, ubuntu 14.04, 도커, docker, tugboat, 디지털 오션, digital ocean, apt-get
---

드디어 우분투 14.04 LTS가 정식 릴리즈되었습니다. 이 글에서는 우분투 14.04에서 도커(Docker)를 설치하고 사용하는 법을 다룹니다. 이 글에서는 테스트 용으로 디지털 오션에 우분투 14.04 이미지를 사용해 인스턴스를 만들고 도커를 설치하겠습니다. 

<!--more-->

아래 리스트에서 확인할 수 있듯이 디지털 오션에서는 이미 우분투 14.04 이미지를 지원하고 있습니다. (이 외에도 디지털 오션에서는 도커나 도쿠가 설치된 이미지도 기본적으로 지원하고있습니다.)

```sh
$ tugboat images --global

Global Images:
...
Wordpress on Ubuntu 13.10 (id: 3135725, distro: Ubuntu)
Ruby on Rails on Ubuntu 12.10 (Nginx + Unicorn) (id: 3137635, distro: Ubuntu)
Redmine on Ubuntu 12.04 (id: 3137903, distro: Ubuntu)
Dokku-v0.2.1 on Ubuntu 13.04 (id: 3140202, distro: Ubuntu)
Ubuntu 14.04 x32 (id: 3229615, distro: Ubuntu)
Ubuntu 14.04 x64 (id: 3229624, distro: Ubuntu)
```

디지털 오션 인스턴스를 실행합니다.

```sh
$ tugboat create UbuntuDocker -s 66 -i 3229624 -r 6-k <ssh_key_id>
```

각각의 인자는 `-s` 인스턴스 종류(66은 제일 작은 인스턴스), `-i` 이미지(3229624 = Ubuntu 14.04 x64), `-r` 지역(6은 싱가폴)을 의미하면 마지막의 `-k`에는 자신의 ssh_key id를 넣어줍니다.

우선 인스턴스가 정상적으로 실행됐는 지 확인합니다.

```sh
$ tugboat droplets
UbuntuDocker (ip: 111.222.211.112, status: active, region: 6, id: 100000)
```

정상적으로 실행이 되면 인스턴스에 접속합니다.

```sh
ssh root@111.222.211.112
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-24-generic x86_64)

* Documentation:  https://help.ubuntu.com/

System information disabled due to load higher than 1.0

Last login: Fri Apr 18 07:12:05 2014 from 123.98.184.24
root@UbuntuDocker:~#
```

ssh 접속 안내메시지를 통해서 우분투 14.04임을 확인할 수 있습니다. 우분투 14.04(Trusty)부터는 도커를 별다른 설정없이 패키지 관리자 `apt-get`을 통해서 공식 저장소로부터 바로 설치할 수 있습니다. 먼저 패키지 정보를 확인해봅니다.

```sh
$ apt-cache show docker.io
Package: docker.io
Priority: optional
Section: universe/admin
Installed-Size: 21726
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Original-Maintainer: Paul Tagliamonte <paultag@debian.org>
Architecture: amd64
Version: 0.9.1~dfsg1-2
...
```

패키지명이 docker가 아니라는 점에 주의합니다. `apt-get`으로 설치합니다.

```
$ apt-get install docker.io
```

설치가 끝나면 정상적으로 설치되었는지 확인합니다.

```
$ docker.io version
docker.io version
Client version: 0.9.1
Go version (client): go1.2.1
Git commit (client): 3600720
Server version: 0.9.1
Git commit (server): 3600720
Go version (server): go1.2.1
Last stable version: 0.10.0, please update docker
```

정상적으로 설치된 것을 확인할 수 있습니다. 단 아래의 안내에서 확인할 수 있듯이 현재 Docker의 최신버전은 0.10입니다. 공식 저장소의 패키지는 시스템에 비교적 안정적인 버전이긴 합니다만 Docker의 경우 1.0을 계속 안정성 문제를 잡고 있는 상황이라 별도로 최신버전을 설치하는 게 좋을 수도 있습니다.

또한 패키지 관리자로 설치한 도커의 서비스 명도 docker.io라는 점에 주의해야합니다.

```
$ service docker.io status
docker.io start/running, process 2841
```

공식적으로 지원되는 패키지가 있느냐 없느냐는 어떤 도구를 처음 사용할 때 큰 장벽 중 하나입니다. 우분투 14.04 LTS가 나오면서 도커의 접근성은 한층 더 높아졌다고 할 수 있습니다.

관심 있으신 분들은 꼭 시도해보세요 >_<
