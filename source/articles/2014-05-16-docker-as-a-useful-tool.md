---
title: "도커 툴로서 사용하기"
date: 2014-05-16 23:00:03 +0900
author: nacyot
published: false
---

도커의 기본적인 혹은 최종적인 목표는 실제 어플리케이션 배포에 있습니다만, 

## Gitlab

Gitlab은 Github의 대표적인 대체 오픈소스입니다. 개인적으로 공개 돼있는 소스 코드나 업무 용도 이외의 코드는 전부 개인적으로 설치해둔 Gitlab에서 관리를 하고 있습니다. Gitlab은 매우 유용한 툴입니다만, 오래 전부터 설치가 어렵기로 유명했습니다. 기본적으로 루비 온 레일즈에 기반한 Gitlab은 프로그램의 특성상 데이터베이스는 물론 매우 다양한 라이브러리에 의존해서 만들어져있습니다. 따라서 이러한 의존성을 자신의 환경에서 완벽하게 재현한다는 것은 결코 쉬운 일이 아닙니다. 실제로 Gitlab 설치에 다룬 글도 다수 있을 뿐아니라, 설치해본 분은 이해하시겠지만 이런 설명서를 그대로 따라해도 설치가 되지 않는 경우가 다반사입니다. 지금은 그냥 방치하고 있긴 합니다만, 저 역시 매번 설치할 때마다, 그리고 업그레이드할 때마다 고생을 했던 기억이 납니다.

자, 그럼 그런 고생은 다른 분들에게 맡기고,

여기서는 도커를 사용해 이미 만들어진 sameersbn/gitlab 이미지를 실행해보겠습니다.

```sh
$ docker pull sameersbn/gitlab:latest
```

레이어가 많아서 이미지를 다운로드 받는 데는 시간이 좀 걸릴 것입니다. 빌드된 이미지가 다수 있으므로 시간을 절약하기 위해서 여기서는 `latest` 태그가 붙은 이미지만 다운로드 받습니다.

다운로드가 완료되면 이미지를 실행합니다. 여기서 `-d`는 백그라운드 실행을 의미해며, `-p`는 각각 포트 맵핑을 의미합니다. 예를 들어 `10022:22`는 도커 컨테이너 내부의 22번 포트를 도커 호스트의 10022 포트에 연결해줍니다. `-e`에는 적절한 환경 변수를 지정합니다.

```
$ docker run --name='gitlab' -d -p 10022:22 -p 10080:80 -e "GITLAB_PORT=10080" -e "GITLAB_SSH_PORT=10022" sameersbn/gitlab:latest
1e5f2425712b4336eef4ecfa9e62bc07e41c59845e11d25bb7f82d2d49024b8a
```

위와 같이 실행하면 `1e5f242...`과 같이 컨테이너의 해시값이 리턴됩니다. 이 해시값을 가지고 컨테이너의 로그를 출력해봅니다.

```sh
$ docker logs 1e5f242
User: root Password: eiSe2rei9ien
....
```

로그를 통해 임의로 생성된 ssh 비번과 gitlab 웹페이지의 기본 계정 정보를 확인할 수 있습니다.

10080포트를 통해 Gitlab에 접속합니다.

![](/images/2014-05-16-docker-as-a-useful-tool/gitlab1.png)

이런 페이지가 나오면 정상입니다. 이를 통해 Gitlab이 정상적으로 설치된 것을 확인할 수 있습니다. 아래 로그인 정보를 통해서 로그인하고 새로운 패스워드를 지정합니다.

> login.........admin@local.host

> password......5iveL!fe

실제로 Gitlab을 사용하기 위해서는 Github와 마찬가지로 SSH 공개키를 등록할 필요가 있습니다. 메뉴 상단 오른쪽의 사용자 정보(Profile settings)에 들어가 My SSH keys에서 도커 호스트 PC(혹은 네트워크 상에서 접근가능한 클라이언트)의 SSH 키를 등록합니다.

![](/images/2014-05-16-docker-as-a-useful-tool/gitlab3.png)

다음으로 상단 메뉴 오른쪽의 + 아이콘을 클릭해 아래와 같이 새 프로젝트를 생성합니다.

![](/images/2014-05-16-docker-as-a-useful-tool/gitlab2.png)

새로운 프로젝트 페이지에는 프로젝트를 Gitlab에 등록하는 법을 보여줍니다. 여기서는 Git profile 설정은 등록이 되어있다고 가정하고 새로운 프로젝트를 초기화해보겠습니다. Gitlab의 안내대로 임의의 디렉토리에서 아래 명령어들을 실행합니다.

![](/images/2014-05-16-docker-as-a-useful-tool/gitlab4.png)

```
$ mkdir sample_project
$ cd sample_project
$ git init
$ touch README
$ git add README
$ git commit -m 'first commit'
$ git remote add origin ssh://git@localhost:10022/root/sample_project.git
$ git push -u origin master
```

실행 결과는 아래와 같습니다.

```
$ mkdir sample_project
$ cd sample_project
$ git init
Initialized empty Git repository in /tmp/sample_project/.git/
$ touch README
$ git add README
$ git commit -m 'first commit'
[master (root-commit) fbabb18] first commit
1 file changed, 0 insertions(+), 0 deletions(-)
create mode 100644 README
$ git remote add origin ssh://git@localhost:10022/root/sample_project.
$ git push -u origin master
The authenticity of host '[localhost]:10022 ([127.0.0.1]:10022)' can't be established.
ECDSA key fingerprint is a1:3d:32:97:de:9c:fb:23:1a:f5:79:09:34:cc:7b:b9.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:10022' (ECDSA) to the list of known hosts.
Counting objects: 3, done.
Writing objects: 100% (3/3), 215 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://git@localhost:10022/root/sample_project.git
* [new branch]      master -> master
Branch master set up to track remote branch master from origin.
```

정상적으로 `localhost:10022`를 통해서 Git 저장소를 푸쉬할 수 있는 것을 알 수 있습니다. 위와 같이 저장소를 Push하고 아까 접속했던 프로젝트 페이지에 다시 접속하면 아래와 같이 프로젝트가 정상적으로 등록된 것을 볼 수 있습니다.

![](/images/2014-05-16-docker-as-a-useful-tool/gitlab5.png)

이걸로 Gitlab 설치와 기본적인 사용을 해보았습니다. Gitlab에서 가장 어려운 부분이 웹 인터페이스에서 Git 프로젝트 관리가 정상적으로 이루어지는지 확인하기까지의 과정인데,

허무할 정도로 쉽게 설치되고 정상적으로 작동하는 것을 알 수 있습니다.

사실 도커 환경에서 데이터 저장이나 백업, 데이터베이스 분리 등, 기타 구체적인 환경 설정 등을 다루기 위해서는 약간 다른 접근이 필요하며 거기에 대한 이해가 필요합니다. 여기에 대해서는 `sameersbn/gitlab` 문서에서 자세한 내용을 다루고 있으니 참조하기 바랍니다.

## Yobi 설치

이번에는 요비를 다뤄보도록 하겠습니다.

```
```
