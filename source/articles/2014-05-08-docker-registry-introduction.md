---
title: "도커 레지스트리(Docker Registry) 설치하기 + S3 연동"
date: 2014-05-08 10:00:03
author: nacyot
---

도커의 장점 중 하나는 도커에서 빌드한 이미지를 쉽게 공유할 수 있다는 점입니다. 이러한 장점은 오픈소스 커뮤니티 위에서 공적인 공유로 그 장점이 극대화됩니다. 실제로 도커에서는 도커에서 생성한 이미지를 공유할 수 있는 [공식 저장소][index]를 제공하고 있습니다. 공식 저장소에는 프론트엔드 어플리케이션과 데이터베이스와 같은 백엔드 어플리케이션 등 이미 많은 도커 이미지들이 공유되고 있습니다. 물론 도커의 가장 큰 장점은 경량화된 가상화(격리)를 통한 어플리케이션 배포에 있습니다만, 이러한 열린 공간을 통해서 오픈소스 어플리케이션을 공유하는 새로운 장을 열어놓고 있습니다. 나아가 몇몇 프로젝트에서는 좀 더 적극적으로 직접 Dockerfile을 제공해 어플리케이션을 도커 이미지로 빌드하는 걸 지원하고 있습니다.

[index]: http://index.docker.io

<!--more-->

개인적으로는 이미 개발용으로 오픈소스 어플리케이션을 설치할 때는 거의 전면적으로 도커를 활용하고 있습니다. 일견 납득하기 어려울 지도 모릅니다만, 어떤 어플리케이션을 설치하기 위해 서버를 어떤 상태로 만드는 것보다, 서버의 상태와 무관하게 특정 어플리케이션의 컨테이너를 실행시키는 게 훨씬 쉽고 신뢰높은 전략입니다. 예를 들어서 설치하기 어려운 오픈소스 어플리케이션으로 프라이빗 Git 저장소인 Gitlab이 유명합니다만, 도커에서는 명령어 하나면 됩니다. 물론 구체적인 설정이나 실 배포환경에서 사용하는 건 각자의 선택에 달렸겠습니다만.

## 설치

도커 이미지의 공적인 공유에 대한 자세한 얘기는 언젠가 기회가 되면 하기로 하고...

공개된 이미지를 활용해보신 분들이라면 사적인 자신만의 이미지를 공유하는 공간을 가지고 싶어질 것입니다. 이 글에서는 사적인 이미지 공유를 위한 도커 레지스트리에 대해서 소개하고자 합니다. 위에서 이야기한 바의 연장입니다만, 도커 레지스트리 역시 빌드를 위한 Dockerfile을 Github 저장소에서 제공하고 있으며, 도커 공식 저장소에서 빌드된 이미지도 제공되고 있습니다. 여기서는 공식 저장소에서 제공하는 이미지를 통해서 도커 레지스트리를 실행하도록 하겠습니다.

### 도커 설치

여기서는 도커가 이미 설치되어있다고 가정하겠습니다. 설치되어있지 않다면, Ubuntu 14.04 LTS 기준으로 아래 명령어로 도커를 설치해주세요.

```sh
$ apt-get install docker.io
```

### 도커 레지스트리 설치

먼저 `docker pull` 명령어로 공식 저장소에서 registy 이미지의 최신 버전을 받아옵니다.

```sh
$ docker pull registry:latest
Pulling repository registry
2930bc3d8f1e: Download complete
511136ea3c5a: Download complete
77917256cf11: Download complete
f10485646326: Download complete
...
```

이미지를 받아왔으면 `images` 명령어로 이미지가 정상적으로 저장됐는지 확인합니다.

```sh
$ docker images | grep "registry.*latest"
(표준 입력):3:registry             latest              2930bc3d8f1e        12 days ago         454.8 MB
```

## 실행

이미지가 정상적으로 받아졌으면 실행은 간단합니다. 여기서 `--name`은 이름을 지정하는 플래그이며, `-d`는 백그라운드에서 실행, `-p {host_port}:{container_port}`는 포트 노출을 위한 맵핑을 의미합니다. 마지막 `registry`는 실행하고자하는 이미지의 이름입니다. 좀 더 정확히는 `registry` 다음에 컨테이너에 대해서 실행하고자 하는 명령어를 입력합니다만, 이미지 내부에 기본 실행 명령이 지정되어 있으므로 생략해도 무방합니다.

```sh
$ docker run --name personal-registry -d -p 5000:5000 registry
8fa28faf47f3cacce64aeb63b5a6c7e1388b5470340f6feb342b03d4fad4352c
```

registry 이미지로 도커를 실행하면 `8fa28fa`로 시작하는 컨테이너 아이디를 볼 수 있습니다. (컨테이너 아이디는 그 때 그 때 다릅니다.) 컨테이너가 정상적으로 실행됐는지 확인하기 위해 `ps -l` 명령어를 실행합니다. `-l` 플래그는 가장 최근에 실행한 컨테이너를 보여줍니다.

```sh
$ docker ps -l
CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS              PORTS                    NAMES
8fa28faf47f3        registry:0.6.8           /bin/sh -c 'cd /dock   2 seconds ago       Up 2 seconds        0.0.0.0:5000->5000/tcp   personal-registry
```

정상적으로 실행했다면 위와 비슷한 화면을 볼 수 있습니다.

위의 설정대로라면 컨테이너의 5000번 포트가 호스트의 5000번 포트로 노출됩니다. 도커 레지스트리는 도커 명령어를 통해서 사용하는 게 기본입니다만, 5000번 포트를 통해 http로 기본적인 API를 제공하고 있습니다. 이를 통해서 서버가 정상적으로 실행되었는지 확인해보겠습니다.

```sh
$ curl "http://0.0.0.0:5000"
"docker-registry server (dev) (v0.6.8)"
```

이를 통해 도커 레지스트리(Docker registry)의 실행환경과 버전을 확인할 수 있습니다. 이걸로 도커 레지스트리가 정상적으로 설치되었습니다.

## 사용하기

아무것도 설정하지 않았다면 도커 레지스트리는 기본적으로 로컬에 데이터를 저장합니다. [`config_sample.yml`][config_sample]을 참조해주세요.

[config_sample]: https://github.com/dotcloud/docker-registry/blob/master/config/config_sample.yml

### 사용자 도커 이미지 만들기

기본적으로 사적인 저장소는 자신이 직접 빌드한 이미지를 저장하기 위해서 사용합니다. 이미 가지고 있는 이미지를 사용해도 무방합니다만 여기서는 간단한 이미지를 하나 생성하겠습니다. 임의의 디렉토리에 아래 내용을 복사해 `Dockerfile`을 만듭니다.

```
FROM ubuntu:12.04
MAINTAINER Daekwon Kim <propellerheaven@gmail.com>
CMD echo 'Hello, Docker!'
```

`Dockerfile`을 만들었으면 이 파일을 빌드해서 새로운 이미지를 생성하겠습니다. 아래 내용을 참고해서 빌드합니다. 여기서 `-t` 플래그를 통해서 이미지의 이름을 지정할 수 있습니다. 여기선 이미지 이름으로 `nacyot/hello_docker`을 사용했습니다.

```sh
$ pwd
/home/nacyot/src/hello_docker
$ ls
Dockerfile
$ docker build -t nacyot/hello_docker .
Uploading context  2.56 kB
Uploading context
Step 0 : FROM ubuntu:12.04
---> c0fe63f9a4c1
Step 1 : MAINTAINER Daekwon Kim <propellerheaven@gmail.com>
---> Running in 166e22a298bd
---> dfaa95be184e
Step 2 : CMD echo 'Hello, Docker!'
---> Running in 677b5b6260a2
---> 677a7d6fbf49
Successfully built 677a7d6fbf49
Removing intermediate container 166e22a298bd
Removing intermediate container 677b5b6260a2
```

이미지가 정상적으로 빌드되었는지 `images` 명령어로 확인해봅니다.

```sh
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
nacyot/hello_docker   latest              677a7d6fbf49        2 minutes ago       231.1 MB
```

이미지가 정상적으로 빌드되었으니 실행해보도록하겠습니다. 간단히 `run`에 이미지 이름을 넘겨줍니다.

```sh
$ docker run nacyot/hello_docker
Hello, Docker!
```

Dockerfile을 유심히 보셨다면 눈치채셨겠지만, `Hello, Docker!`를 출력하는 훌륭한 이미지를 만들었습니다. 위와 같은 결과가 나온다면 이미지가 정상적으로 작동하는 것을 확인할 수 있습니다. 중요한 점은 `echo` 명령어는 실행하자마자 종료되는 process이기 때문에 `docker ps`에서 이 컨테이너를 확인할 수 없다는 점입니다. 컨테이너에서는 자신에게 주어진 주 프로세스가 종료되면 컨테이너도 따라 종료됩니다. 이를 확인하기 위해서 `-a` 플래그를 사용합니다. 

```sh
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS                     PORTS                    NAMES
d01aea6f8332        nacyot/hello_docker:latest   /bin/sh -c 'echo 'He   2 minutes ago       Exited (0) 2minutes ago                            prickly_fermat
```

### 도커 레지스트리에 푸시(Push)하기

이미지가 정상적으로 작동하는 것을 확인했으니 이제 이미지를 도커 레지스트리에 집어넣어보겠습니다. 먼저 이미지를 도커 레지스트리에 넣기 위해서는 이미지에 적당한 이름을 붙여줄 필요가 있습니다. `docker tag` 명령어로 이미지에 새로운 이름을 부여하겠습니다.

```sh
$ docker tag nacyot/hello_docker 0.0.0.0:5000/hello_docker
```

`tag` 명령어가 정상적으로 실행됐으면 같은 이미지에 새로운 이름이 부여됩니다. `images` 명령어로 확인해봅니다.

```sh
$ docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
nacyot/hello_docker         latest              677a7d6fbf49        10 minutes ago      231.1 MB
0.0.0.0:5000/hello_docker   latest              677a7d6fbf49        10 minutes ago      231.1 MB
...
```

`IMAGE ID`에서 확인할 수 있듯이 열거된 두 이미지는 이름만 다른 같은 이미지입니다. 이렇게 `/` 앞에 도커 레지스트리의 주소를 지정해 이름을 부여하고(앞에서 간단히 사용해보았듯이 이 글에서 사용하는 도커 레지스트리의 주소는 `0.0.0.0:5000`입니다) `push`하면 해당하는 도커 레지스토리에 이미지가 업로드됩니다.

```sh
$ docker push 0.0.0.0:5000/hello_docker
The push refers to a repository [0.0.0.0:5000/hello_docker] (len: 1)
Sending image list
Pushing repository 0.0.0.0:5000/hello_docker (1 tags)
511136ea3c5a: Image successfully pushed
6170bb7b0ad1: Image successfully pushed
79fdb1362c84: Image successfully pushed
c0fe63f9a4c1: Image successfully pushed
dfaa95be184e: Image successfully pushed
677a7d6fbf49: Image successfully pushed
Pushing tag for rev [677a7d6fbf49] on {http://0.0.0.0:5000/v1/repositories/hello_docker/tags/latest}
```

출력 마지막의 주소를 통해서 실제 도커 레지스트리 서버에 이미지가 정상적으로 올라갔는지 확인해봅니다.

```sh
$ curl 'http://0.0.0.0:5000/v1/repositories/hello_docker/tags/latest'
"677a7d6fbf492ff63e9c7bd2fcbff5ea952b0c32c417d1251786a559a6b0af7a"
```

이미지 ID에서 확인할 수 있듯이 로컬의 `0.0.0.0:5000/hello_docker:latest`(`nacyot/hello_docker:latest`)와 도커 레지스트리의 `hello_docker:latest`는 같은 이미지입니다.

### 도커 레지스트리에서 풀(Pull) 받아 실행하기

이제 가장 중요한 부분입니다. 도커 레지스트리에 이미지를 업로드했으니 거꾸로 이 도커 레지스트르에서 이미지를 `pull` 받아 실행해보도록 하겠습니다. 로컬 도커 서버에 같은 이미지가 있으면 정확한 확인이 안 되니, 로컬에서 실행했던 컨테이너와 이미지를 삭제하겠습니다.

먼저 앞서 실행한 종료 상태에 있는 컨테이너를 삭제해야합니다. 컨테이너가 종료되었더라도 삭제되지 않은 상태로 있으면 컨테이너의 부모 이미지는 삭제할 수 없습니다. 앞서 `ps -a` 명령어를 참조해 컨테이너를 삭제합니다.

```sh
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS                     PORTS                    NAMES
d01aea6f8332        nacyot/hello_docker:latest   /bin/sh -c 'echo 'He   2 minutes ago       Exited (0) 2minutes ago                            prickly_fermat
$ docker rm prickly_fermat
prickly_fermat
```

`rm` 명령어에 컨테이너 이름이나 아이디를 지정해 컨테이너를 삭제합니다. 다음으로 이미지를 삭제합니다.

```sh
$ docker rmi nacyot/hello_docker 0.0.0.0:5000/hello_docker
Untagged: nacyot/hello_docker:latest
Untagged: 0.0.0.0:5000/hello_docker:latest
Deleted: 677a7d6fbf492ff63e9c7bd2fcbff5ea952b0c32c417d1251786a559a6b0af7a
Deleted: dfaa95be184ee02339884cd7b4d93e0830cf7e6c8262a281409e0e8cef5f45e9
```

`docker images`를 실행해 삭제되었는지 확인해봅니다.

```sh
$ docker images | grep hello_docker
```

삭제된 이미지는 당연히 실행되지 않겠죠? 하지만 앞서서 도커 레지스트리의 주소를 지정한 이름을 사용하면 도커는 해당하는 주소에 도커 이미지가 있는지 먼저 검색합니다. 공유된 도커 이미지의 실행은 먼저 풀(Pull)을 받고 실행하는 단계를 거칩니다만, 바로 실행(`run`) 명령어를 사용하면 도커는 자동적으로 해당하는 주소의 이미지를 풀 받고 실행합니다. 여기서는 바로 앞서 푸시한 도커 이미지를 실행하겠습니다.

```sh
$ docker run 0.0.0.0:5000/hello_docker
Unable to find image '0.0.0.0:5000/hello_docker' locally
Pulling repository 0.0.0.0:5000/hello_docker
677a7d6fbf49: Download complete
511136ea3c5a: Download complete
6170bb7b0ad1: Download complete
79fdb1362c84: Download complete
c0fe63f9a4c1: Download complete
dfaa95be184e: Download complete
Hello, Docker!
```

명령어는 위에서 로컬에 있던 이미지를 실행하는 것과 같습니다. 하지만 실행 과정의 출력을 보면 알 수 있듯이 로컬에 이미지가 없으니 `0.0.0.0:5000`의 도커 레지스트리에서 이미지를 다운 받는 것을 확인할 수 있습니다. 그리고 마지막에는 정상적으로 이미지가 실행되어 `Hello, Docker!`가 출력되었습니다!

### 원격에서 도커 레지스트리 사용하기

이 예제에서는 로컬에서 도커 레지스트리와 도커 실행 서버를 둘 다 운영하고 있어서 실제로 제대로 작동하는 건지 잘 와닿지 않을지도 모릅니다. 가능하면 자신의 로컬(도커 레지스트리를 설치한 서버)을 외부에 노출시켜서 다른 도커 서버에서 실행시켜봅니다.

```sh
$ curl http://17.231.14.21:5000/
"docker-registry server (dev) (v0.6.8)"
$ docker run 17.231.14.21:5000/hello_docker
Unable to find image '17.231.14.21:5000/hello_docker' locally
Pulling repository 17.231.14.21:5000/hello_docker
677a7d6fbf49: Download complete
511136ea3c5a: Download complete
6170bb7b0ad1: Download complete
79fdb1362c84: Download complete
c0fe63f9a4c1: Download complete
dfaa95be184e: Download complete
Hello, Docker!
```

실제 IP는 공개할 수 없지만 :) 도커 레지스트리 서버(여기선 `17.231.14.21:5000`)에 접속 가능한 도커 서버에서도 로컬에서와 같은 결과를 볼 수 있습니다. 직접 테스트해보시기 바랍니다.

## S3와 연동하기

AWS빠라면 응당 도커 이미지를 S3에 저장하고 싶다고 느낄 것입니다. 속도나 추가적인 비용이 발생하는 데서, S3에 저장하는데 따른 부담이 없는 것은 아닙니다만 가장 쉽게 이미지를 안전하게 저장하는 방법이라고 할 수 있습니다.

하지만 도커 레지스트리는 파이썬의 flask에 기반한 웹 어플리케이션입니다. 따라서 S3에서는 도커 레지스트리를 구동할 수 없습니다. 즉,  도커 레지스트리는 EC2나 로컬 서버를 이용해서 별도로 실행해야합니다. 이 레지스트리 설정에 이미지 저장 공간으로 로컬 드라이브가 아닌 S3 버킷을 지정해두면 해당하는 버킷에 이미지를 저장합니다. 이렇게 설정하면 도커 레지스트리에 이미지를 푸시할 때 도커 레지스트리는 이 이미지를 S3로 복사합니다. S3에 복사되면 아마존은 이 이미지를 안전하게 보관해줍니다.

### 도커 레지스트리 저장공간으로 S3 설정하기

S3 가입과 버킷 생성법은 별도로 다루지 않습니다.

먼저 `s3api` 명령어나 aws 웹콘솔에서 S3에 `docker-registry`라는 새로운 버킷(bucket)을 만들어줍니다. 아마 `docker-registry`라는 이름은 사용할 수 없을 테니 적당한 이름을 지정해줍니다.

![Creating a S3 bucket](/images/2014-05-07-docker-registry-introduction/create_bucket.png)

다음으로 아래와 같이 `config.yml` 파일을 작성합니다. bucket 이름과 `<>`로 둘러쌓인 변수들을 자신의 값으로 바꿔줍니다. `<SECRET_KEY>`에는 임의의 값을 적절히 입력해줍니다. s3_region은 도쿄를 사용하고 있다고 가정하겠습니다. 도쿄를 사용할 시 `ap-northeast-1`을 지정합니다. 이 파일을 적절히 새로운 디렉토리에 저장합니다. 여기서는 `/home/nacyot/src/registry-conf/config.yml`에 저장한다고 가정합니다.

```
prod:
    storage: s3
    boto_bucket: docker-registry
    s3_access_key: <S3_ACCESS_KEY>
    s3_secret_key: <S3_SECRET_KEY>
    s3_bucket: docker-registry
    s3_encrypt: true
    s3_secure: true
    s3_region: ap-northeast-1
    secret_key: <SECRET_KEY>
    storage_path: /images
```

이제 이 설정을 적용해서 도커 레지스트리를 실행할 차례입니다. 이 설정 파일을 컨테이너를 실행해 직접 복사하거나 작성하고 커밋하는 방식으로 설정 파일이 적용된 이미지를 새로 만들 수도 있습니다만, 여기서는 도커 컨테이너에 호스트의 디렉토리를 마운트하는 기능을 사용합니다. `-v {HOST_DIR}:{CONTAINER_DIR}`과 같이 지정하면 `HOST_DIR`이 컨테이너 내부의 `CONTAINER_DIR`에 마운트됩니다. 앞서서 `/home/naycot/src/registry-conf`에 설정 파일을 넣어뒀으니 컨테이너에서는 `/registry-conf` 디렉토리를 통해서 `config.yml`에 접근할 수 있습니다. 다음으로 `-e`는 컨테이너 내부의 환경 변수를 지정할 수 있습니다. `DOCKER_REGISTRY_CONFIG`는 설정 파일 위치를 지정하는 환경변수입니다. 다음으로 `SETTINGS_FLAVOR`는 실행 환경을 선택하는 환경변수입니다. 환경변수들을 아래와 같이 지정하고 컨테이너를 실행합니다.

```sh
$ docker run -d -p 5000:5000 -v /home/nacyot/src/registry-conf:/registry-conf -e SETTINGS_FLAVOR=prod -e DOCKER_REGISTRY_CONFIG=/registry-conf/config.yml registry
91f0af600e4ef3a0ba41382cf74e9b4c1228524ec95c8ab3a05d64fbae5755cd
```

`ps` 명령어로 컨테이너가 정상적으로 실행되었는지 확인합니다.

```sh
$ docker ps -l
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                    NAMES
91f0af600e4e        registry:0.6.8      /bin/sh -c 'cd /dock   6 minutes ago       Up 6 minutes        0.0.0.0:5000->5000/tcp   compassionate_ptolemy
```

앞서 로컬에서와 마찬가지로 0.0.0.0:5000에 이미지를 푸시해봅니다.

```sh
$ docker push 0.0.0.0:5000/hello_docker
The push refers to a repository [0.0.0.0:5000/hello_docker] (len: 1)
Sending image list
Pushing repository 0.0.0.0:5000/hello_docker (1 tags)
511136ea3c5a: Image successfully pushed
6170bb7b0ad1: Image successfully pushed
79fdb1362c84: Image successfully pushed
c0fe63f9a4c1: Image successfully pushed
dfaa95be184e: Image successfully pushed
677a7d6fbf49: Image successfully pushed
Pushing tag for rev [677a7d6fbf49] on {http://0.0.0.0:5000/v1/repositories/hello_docker/tags/latest}
```

정상적으로 푸시된 것을 확인할 수 있습니다. 이 출력을 봐서는 실제로 이미지가 어디에 저장되었는지 확인하기 어렵습니다. 실제로 s3에 들어가 저장이 되었는지 확인해봅니다.

![Docker Images on AWS S3](/images/2014-05-07-docker-registry-introduction/images.png)

푸시한 이미지들이 S3에 저장되어있는 것을 확인할 수 있습니다.

S3 설정을 사용하는 경우 어디에 저장하는 지만 차이가 나기 때문에, 앞서 다룬 풀(Pull)과 실행(Run)은 로컬에서 했던 것과 마찬가지입니다.

## 기타 주제

### 비용 문제

아직 헤비 유저는 아니라 단언은 불가하지만 비용 문제가 그렇게 부담은 아닐 거라고 생각하고 있습니다. 얼핏 생각해봐도 이미지의 용량이 상당히 크지 않을까 하는 생각이 듭니다만 도커에서는 이미지를 레이어 단위로 저장한다는 사실을 떠올릴 필요가 있습니다. 도커의 이미지는 부모 레이어에 대한 차분만을 저장합니다. 따라서 특정한 어플리케이션에 대한 이미지를 만들고 변경사항들을 계속 누적해가도 용량은 생각보다 크지 않습니다. 즉 10번의 변경이 누적된 이미지가 있다고 할 때 각각의 이미지가 최종적으로 1GB라고 해도 `1GB * 10 = 10GB`가 되는 것이 아니라 `1GB + 0GB + 0GB ... = 1.xxxGB` 정도가 됩니다. 물론 전혀 다른 이미지의 경우는 그만큼 용량을 차지합니다만, 사용하기에 따라서 절대적으로 부담스러운 용량은 아닐지도 모릅니다. 참고로 S3 프리티어는 5GB이고 이후 1GB당 1달에 $0.033 정도가 과금됩니다.

### 보안

이 예제에서는 사용자 인증을 다루고 있지 않습니다. 따라서 예제대로 따라하면 개인적인 이미지 저장소이지만 네트워크가 열려있으면 공개되어있는 거나 마찬가지입니다. 실제로 사용하려면 보안 설정은 필수입니다. 더 자세한 사항은 [Github 저장소][github_repo]를 참조해주세요.

[github_repo]: https://github.com/dotcloud/docker-registry

### API

[Docker Registry API][api]를 참조하세요. 아직 레지스트리에 올라간 모든 이미지를 가져오는 API가 없습니다만, 아마 다음 버전에 추가될 것으로 보입니다.

[api]: http://docs.docker.io/reference/api/registry_api/

## 결론

앞서 이야기했듯이 이미지를 쉽게 공유할 수 있다는 건 도커의 큰 장점 중 하나입니다. 공적 공유뿐 아니라 내부 네트워크에서 이미지의 사적 공유를 실현하는 건 도커를 실제 운용하는데 아마 필수적인 부분일 것입니다. 이를 통해 도커 레지스트리에서 커스텀 이미지를 일괄적으로 관리할 수 있고, 분산된 도커 서버들에서 이를 사용할 수 있습니다.
