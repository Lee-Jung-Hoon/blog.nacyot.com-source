---
title: "도커(Docker)로 루비 온 레일스 어플리케이션 배포하기"
date: 2014-06-16 12:00:00 +0900
author: nacyot
tags: ruby, docker, rails, deploy, devops, haproxy, digital ocean, dockerfile, 루비, 도커, 레일스, 배포, 서버, 서버 운영
published: false
---

이 글은 지난 6월 10일 RORLab에서 발표한 '도커(Docker)로 루비 온 레일스 어플리케이션 배포하기'를 정리한 문서입니다. 먼지 이미지와 컨테이너 소개 및 이미지 생성에 대해서 다룬 앞 부분은 이전에 작성했던 문서 '[도커(Docker) 튜토리얼 : 깐 김에 배포까지][docker_introduction]'로 대체합니다.

[docker_introduction]: http://blog.nacyot.com/articles/2014-01-27-easy-deploy-with-docker/

<!--more-->

## 도커로 어플리케이션 배포하기

도커는 다양한 용도로 사용 가능하지만, 가장 원초적인 목적은 어플리케이션 배포에 있다. 또한 이미지를 기반으로 한 도커의 방식에 따라 도커를 통해 어플리케이션을 배포한다는 의미는 개발한 어플리케이션과 어플리케이션을 둘러싼 어플리케이션이 실행가능한 환경 전체를 이미지화한다는 의미를 가지고 있다.

이 과정에서 기존의 서버를 운영하는 것과 마찬가지로 기본적으로는 일련의 명령어를 실행시키거나 쉘스크립트를 실행시킨다. 이러한 일련의 과정을 도커에서는 Dockerfile 이라는 독자적인 포맷(DSL)을 통해서 기술하고, 이 Dockerfile을 빌드해서 이미지를 생성한다.

아쉽지만 같은 Dockerfile 이라도 빌드가 항상 성공한다는 보장은 물론 없다. 즉, Dockefile을 통해 이미지 생성 과정을 재현할 수 있지만, 이 과정이 완벽하다고는 할 수 없다. 예를 들어 네트워크가 불안정해서 관련된 빌드 과정에 문제가 생길 수도 있고, 시스템 라이브러리에 중요한 보안 패치가 있어서 어플리케이션 실행에 영향을 줄 수도 있다. 재현은 불완전하다. 하지만 일반적으로 빌드에 성공한 이미지는 그 시점이 언제인지가 큰 상관만 없다면 완결된 이미지로서 정상적으로 완결되어있다고 봐도 무방하다.

이렇게 빌드된 이미지는 어플리케이션 + 실행환경은 하나의 세트로 포함하고 있으며, 따라서 도커 서버가 설치된 곳이라면 어디에서든지 '당장'에 '정상적으로' 실행가능하다. 다시 한 번 이야기하지만, 도커를 통해서 어플리케이션을 배포한다는 의미는 어플리케이션을 포함하는 이미지를 생성하고 관리한다는 의미이다.

## 레일스 어플리케이션

이 글에서 배포하는 어플리케이션은 `rails new`로 생성되는 사실은 속에 아무것도 없는 어플리케이션이다. 물론 훨씬 더 개발이 진행된 어플리케이션에서는 고려해야할 사항이 훨씬 더 많이 있겠지만, 그런 문제들은 도커를 통한 배포의 문제라기보다는 서버 구성이나 레일스 내부적으로 결정해야할 문제라고 할 수 있다. 도커를 통해서 이미지를 만드는 과정 자체는 근본적으로 다르지 않을 것이다. 단지 좀 더 많은 설정이 필요하고, 좀 더 많고, 정교한 의존성 관리가 필요한 것 뿐이다.

어쨌거나 한 번 더 강조하지만, 어떤 어플리케이션을 배포하건 도커를 통한 배포의 목표는 이 어플리케이션이 실행 가능한 이미지를 만드는 일이다. 이 글에서 사용한 레일스 샘플 어플리케이션의 저장소는 아래에서 찾을 수 있다.

* [nacyot/docker-sample-project][docker-sample-project]

이 글에서 사용하는 dockerfile들은 아래 저장소에서 찾을 수 있다.

* [nacyot/rails-new-dockerfile][rails-new-dockerfile]

[docker-sample-project]: https://github.com/nacyot/docker-sample-project
[rails-new-dockerfile]: https://github.com/nacyot/rails-new-dockerfile

### 이미지 생성 준비 작업

먼저 작업을 진행하기 위해 위에서 언급한 저장소를 작업 디렉토리에 clone한다.

```
# 샘플 레일스 프로젝트 클론
$ git clone git@github.com:nacyot/docker-sample-project.git

# 도커파일 클론
$ git clone git@github.com:nacyot/rails-new-dockerfile.git
```

정상적으로 클론되었는지 확인한다.

```
$ ll
drwxrwxr-x 13 nacyot nacyot 4096 Jun 10 20:50 docker-sample-project
drwxrwxr-x 10 nacyot nacyot 4096 Jun 11 21:08 rails-new-dockerfile
```

## v0.0 

`docker-sample-project`는 `rails new` 명령어로 생성되었다. 레일스를 사용해본 사람이라면 바로 이해하겠지만 `rails new` 명령어는 레일스 프로젝트의 뼈대를 만들어준다. 프로그래머는 이 뼈대에 자신이 필요한 것들을 붙여나가면서 어플리케이션을 만들어나간다.

`v0.0`은 아직 아무것도 수정하지 않은 상태이다. 실제 이미지 생성은 `v0.1`부터 진행한다.

```
$ cd docker-sample-project
$ git checkout v0.0
HEAD is now at c3754e3... Initialize project
$ ls
app  ca      config.ru  docker   Gemfile.lock  log     Rakefile     test  vendor
bin  config  db         Gemfile  lib           public  README.rdoc  tmp
```

익숙한 레일스 프로젝트를 볼 수 있다.

## v0.1 Procfile & serve_static_assets

먼저 처음으로 배포할 태그 `v0.1`은 `rails new`로 프로젝트를 생성한 이후 약간의 수정을 거쳤다.

```
$ git checkout v0.1
HEAD is now at 4b3c006... Set serve_static_assets true in production
```

`v0.0`은 레일스 프로젝트가 초기화된 시점이다. diff 명령어를 통해 `v0.1`과 비교해본다.

```
$ git diff v0.0
diff --git a/Procfile b/Procfile
+web: bundle exec rails server -p 60005

diff --git a/config/environments/production.rb b/config/environments/production.rb
-  config.serve_static_assets = false
+  config.serve_static_assets = true
```

diff를 통해 `v0.1`에서는 두 개의 파일이 변경된 것을 확인할 수 있다.

### Procfile

```
$ cat Procfile
web: bundle exec rails server -p 60005
```

Procfile은 어플리케이션의 실행단위를 정의한다. 예를 들어 하나의 어플리케이션은 여러개의 프로세스로 구성될 수 있다. 가장 기본적인 프로세스는 단연 웹 서버일 것이다. 부가적으로 백그라운드 작업을 하는 sidekiq이 있을 수도 있고, 중간 cache_db가 있을 수도 있다. 일반적인 서버 운영시에는 필요한 프로세스를 각각 실행시킨다. 하지만 이러한 프로세스들은 하나로 모아야만 하나의 어플리케이션이 정상적으로 실행될 수 있다면, 그것들을 한꺼번에 실행시키는 것이 더 합리적일 것이다. Procfile에는 바로 이러한 어플리케이션 실행 단위를 정의한다. 여기서는 아직 레일스 기본 웹서버밖에 없으므로 특별한 내용은 없다.

참고로 포트를 60005번으로 지정한 것은 3000번 포트를 자주 사용하므로 편의상 이동시킨 것뿐이고, 특별한 의미는 없다.

이 Procfile은 루비의 foreman이라는 Gem을 사용해서 실행한다. 이는 뒤에서 Dockerfile을 검토할 때 다룬다.

### serve_static_assets

두번째로 변경한 부분은 `produciton.rb`(프로덕션 환경 설정)에서 `serve_static_assets` 옵션을 `true`로 지정한 부분이다. 개발(development) 모드에서는 레일스 서버가 `./public` 디렉토리 아래의 파일들을 직접 응답해준다. 하지만 프로덕션 환경에서는 그렇지 않다. 이는 실제 프로덕션 환경에서는 이러한 정적 파일들을 레일스 서버가 아니라 nginx나 apache와 같은 이런 역할에 좀 더 충실한 서버들을 활용해서 전달될 것을 기대하기 때문이다. 그리고 실제로 그렇게 사용하는 것이 정상적인 구성이다. 하지만 여기서는 해당하는 구성을 하지 않으므로 에러 페이지를 비롯한 기본적인 정적 파일에 응답하기 위해 이 옵션을 활성화한다.

### v0.1 이미지 생성하기

여기까지 간략하게 `v0.1`이 어떻게 변경되었는 지를 살펴보았다. 그렇다면 여기서부터는 실제로 `v0.1` 프로젝트를 이미지로 만들 것이다. 이를 위해서는 이러한 일련의 과정을 기술한 Dockerfile을 준비해야한다. 이 파일은 앞서서 클론 받은 `rails-new-dockerfile` 디렉토리에 포함되어 있다.

```
$ cd ../rails-new-dockerfile/v0.1
$ ls
Dockerfile
```

이 디렉토리에는 Dockerfile 하나만 덩그러니 들어있다.

### Dockerfile(v0.1)

먼저 빌드에 앞서 도커 파일을 살펴보도록하자.

```
FROM dockerfile/ubuntu
MAINTAINER nacyot(propellerheaven@gmail.com)

# Run upgrades
RUN apt-get update

# Install basic packages
RUN apt-get -qq -y install git curl build-essential openssl libssl-dev python-software-properties python g++ make 

# Install Ruby 2.1
RUN apt-get -qq -y install python-software-properties
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -qq -y install ruby2.1 ruby2.1-dev
RUN gem install bundler --no-ri --no-rdoc

# Install packages for app
RUN apt-get install -qq -y libsqlite3-dev
RUN apt-get install -qq -y nodejs
RUN gem install foreman compass

# Install docker-sample-project v0.1
WORKDIR /app
RUN git clone https://github.com/nacyot/docker-sample-project.git /app
RUN git checkout v0.1
RUN bundle install --without development test

# Run docker-sample-project
ENV SECRET_KEY_BASE hellodocker
ENV RAILS_ENV production
EXPOSE 60005
CMD foreman start -f Procfile
```

계속해서 사용할 Dockerfile이므로 각각의 부분에 대해서 좀 더 자세히 살펴보자.

#### 베이스 이미지 지정

```
FROM dockerfile/ubuntu
```

`FROM`은 이 Dockerfile을 빌드할 때 사용할 베이스 이미지를 지정한다. 지정 방식은 이미지를 나타내는 해시값이나 이름을 지정할 수 있다.

여기서 사용한 `dockerfile/ubuntu`는 공식 `ubuntu:14.04`에 약간의 기본적인 설정이 가미된 이미지이다. [Dockerfile Project][dockerfile_project]는 비슷한 종류의 확장 기본 이미지를 다수 제공한다.

[dockerfile_project]: http://dockerfile.github.io/#/ubuntu

#### Dockerfile 관리자 지정

```
MAINTAINER nacyot(propellerheaven@gmail.com)
```

`MAINTAINER`는 이 Dockerfile을 관리하는 사람을 명시적으로 알려준다.

#### 기본 라이브러리 설치

```
# Run upgrades
RUN apt-get update

# Install basic packages
RUN apt-get -qq -y install git curl build-essential openssl libssl-dev python-software-properties python g++ make 
```

`RUN`은 쉘 명령어를 실행시킨다. 먼저 `apt-get update`를 통해서 저장소의 정보를 갱신한다. 이 과정을 생략하면 빌드 시점에 따라서 `apt-get install`이 정상적으로 작동되지 않을 가능성이 높으므로 특별한 이유가 없는 한 반드시 실행한다.

다음으로는 `apt-get install` 명령어로 기본 패키지들을 설치한다. 이는 필요에 따라서 유동적이다. 여기서는 다른 어플리케이션 빌드 과정에서 필요한 패키지들과 어플리케이션을 저장소에서 가져올 수 있도록 git을 미리 설치한다.

#### 루비 설치하기

```
# Install Ruby 2.1
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -qq -y install ruby2.1 ruby2.1-dev
```

레일스 어플리케이션은 루비 프로그래밍 언어를 기반으로 하고 있다. 따라서 레일스 어플리케이션을 실행하고자 한다며 반드시 루비를 실행할 수 있어야한다. 공식 루비 패키지는 루비 버전이 오래되었을 가능성이 높다. `ppa:brightbox/ruby-ng`에서는 최신 루비 패키지를 지원한다. 따라서 이 저장소를 추가하고 `apt-get install ruby2.1` 명령어로 루비를 설치한다.

```
RUN gem install bundler --no-ri --no-rdoc
```

루비에는 현재 기본적으로 패키지 관리를 위한 `gem` 명령어를 포함한다. 이는 시스템 단위의 패키지 관리를 해주는 툴이므로 어플리케이션 단위의 의존성 관리를 위한 `bundler`를 설치할 필요가 있다. 이를 설치해준다.

#### 레일스 어플리케이션 실행을 위한 시스템 패키지 설치

```
RUN apt-get install -qq -y libsqlite3-dev
RUN apt-get install -qq -y nodejs
```

여기에는 함정에 빠진 초보 레일스 개발자를 구해줄 마법같은 명령어들이 있다. 레일스는 특별히 설정하지 않으면 기본적으로 sqlite3를 사용한다. 그런데 `bundle install`을 실행하면 sqlite3 Gem 부분에서 에러가 나는 경우가 많다. 위의 패키지를 설치하면 해당하는 문제가 마법같이 해결된다.

아래 nodejs 패키지도 마찬가지다. nodejs 패키지 설치없이 `bundle install`을 설치하면 시스템에 자바스크립트 런타임이 없다는 이유로 bundle이 제대로 이루어지지 못 한다. nodejs를 설치하면 이러한 문제가 해결된다.

```
RUN gem install foreman compass
```

추가적으로 루비 패키지들을 설치해준다. foreman은 앞서서 소개한 Procfile을 실행시켜주는 Gem이다. compass는 에셋 컴파일에 사용된다.

#### 레일스 어플리케이션 설치하기

여기까지가 기본적인 시스템 설정이었다면 여기부터가 직접 만든 어플리케이션을 설치하는 부분이다.

```
WORKDIR /app
```

`WORKDIR` 지시자는 앞으로 실행되는 모든 `RUN` 지시자의 실행 위치를 지정한다. 즉 `WORKDIR /app`을 통해서 아래의 모든 명령어는 `/app` 디렉토리에서 실행된다. 

```
RUN git clone https://github.com/nacyot/docker-sample-project.git /app
RUN git checkout v0.1
```

어플리케이션을 클론하고, `v0.1`로 체크아웃한다.

```
RUN bundle install --without development test
```

프로덕션 모드에서 배포를 위한 레일스 의존성을 설치한다. 특별히 어려울 건 전혀없다. 앞서서 `bundle` 실행시 발생할 수 있는 문제들을 해결하기 위한 패키지들도 미리 설치해두었기 때문에 별 무리없이 설치가 진행될 것이다.

#### 환경변수 지정하기

```
ENV RAILS_ENV production
ENV SECRET_KEY_BASE hellodocker
```

레일스에서는 일부 환경변수를 우선적으로 자신의 환경설정에 적용한다. `ENV` 지시자를 사용하면 이미지에 이러한 환경변수 초기값을 지정할 수 있다.

`RAILS_ENV`는 어플리케이션이 실행되는 환경을 의미한다. 여기서는 (아직 아무것도 없음에도 불구하고!)배포 과정이므로 `production`을 지정한다.

또한 production 모드에서는 `secret_token`이 기본적으로 설정되어있지 않다. 이를 지정하기 위해서는 `SECRET_KEY_BASE` 환경변수를 사용해야한다. 적당한 값을 지정해주면 된다.

#### 포트 노출하기

```
EXPOSE 60005
```

`EXPOSE` 지시자는 실행된 도커 컨테이너에서 외부에 노출 가능한 포트를 지정한다. 앞서 언급한 바 있듯이 이 글에서는 편의상 서버를 60005번으로 사용한다. 따라서 컨테이너의 60005번 포트를 노출시킨다.

#### 기본 명령어 지정하기

```
CMD foreman start -f Procfile
```

`CMD`를 사용하면 도커 이미지에 기본 명령어를 지정할 수 있다. 이미지와 컨테이너를 소개할 때 반복적으로 강조하려고 하는 두 가지가 이미지로부터 컨테이너가 실행된다는 거고, 컨테이너는 항상 단 하나의 프로세스라는 점이다. 즉 개념적으로는 가상머신과 비슷하지만, 구현적으로는 가상머신과 너무나도 다르다. 다시 한 번 이야기한다. 컨테이너는 항상 단 하나의 프로세스이다. 이 사실을 놓쳐서는 안 된다.

이 말을 바꿔말하면 어플리케이션 실행 환경이 통째로 들어있는 이미지에 대해서 '어떠한 명령어'를 사용해서든 컨테이너를 실행할 수 있다는 말이다. 그래서 `/bin/bash`를 지정하면 컨테이너에 접속을 할 수 있는 거고, `bundle exec rails server`를 지정하면 어플리케이션을 실행할 수 있다. 조건은 컨테이너에 해당하는 실행파일만 있으면 된다.

`CMD`로 기본 명령어를 지정한다는 말은 도커 이미지를 명령어 인자 없이 `run`(실행)시켰을 때 실행되는 명령어를 지정한다는 의미이다.

여기서는 기본 명령어로 위에서 이야기한 대로 foreman을 사용해 Procfile을 실행한다.

### 도커 이미지 빌드

여기까지 따라왔으면 거진 다 온 거나 마찬가지다. 이제 이미지를 빌드해보자.

```
$ docker build -t nacyot/rails-new:0.1 .
Sending build context to Docker daemon 3.584 kB
Sending build context to Docker daemon 
Step 0 : FROM dockerfile/ubuntu
 ---> 96af2d36fb39
Step 1 : MAINTAINER nacyot(propellerheaven@gmail.com)
 ---> Using cache
 ---> 63b3eaf59343
Step 2 : RUN apt-get update
 ---> Using cache
 ---> c20d985f7209
...
Step 18 : EXPOSE 60005
 ---> Using cache
 ---> 1d4c322a6f1a
Step 19 : CMD foreman start -f Procfile
 ---> Using cache
 ---> 3c2e6f8643fd
Successfully built 3c2e6f8643fd
```

`-t` 옵션은 이미지 이름을 지정해주는 부분이다. 마지막의 `.`이 조금 헷갈릴 수도 있는데, 이는 현재 디렉토리에 있는 Dockerfile을 빌드하라는 의미이다. 한번 빌드했었기 때문에 위의 출력 결과에서는 cache를 사용해 빌드했음을 알 수 있다. 어쨌거나 빌드는 무사히 성공되었다.

이미지가 정상적으로 등록되었는지 검색해보자.

```
$ docker images | grep rails-new
(standard input):8:nacyot/rails-new   0.1   3c2e6f8643fd   32 hours ago   716.8 MB
```

Dockerfile만 잘 만들면 시간이 걸릴 뿐이지, 빌드는 정말 쉽다. 중간에 빌드가 실패하더라도, 실패한 부분까지는 레이어가 만들어져 cache를 사용할 수 있게된다. 따라서 실패한 부분 이후의 Dockerfile만 수정하고 다시 빌드하더라도 매우 빠르게 진행이 되서 부담이 적다.

### 도커 이미지 실행

계속해서 강조하지만 도커에서 어플리케이션을 배포한다는 말은 실행가능한 이미지를 생성하는 일이다. 첫번째 레일스 이미지를 만드는데 무사히 성공했다. 이제 이를 실행해보자.

```
$ docker run --name v0.1 -d -p 60005:60005 nacyot/rails-new:0.1
320306d26b2efbd2b3e326890f4c477b5a62fa1ca0e95b21912f8557c9f49df0
```

정상적으로 실행되었는 지 확인해본다.

```
$ docker ps -l
CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS                      NAMES
320306d26b2e        nacyot/rails-new:0.1   /bin/sh -c 'foreman    12 minutes ago      Up 12 minutes       0.0.0.0:60005->60005/tcp   v0.1
```

정상적으로 실행되고 있음을 알 수 있다.

```
$docker logs v0.1
15:54:16 web.1  | started with pid 10
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  WEBrick 1.3.1
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  ruby 2.1.1 (2014-02-24) [x86_64-linux-gnu]
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  WEBrick::HTTPServer#start: pid=10 port=60005
```

이제 사이트에 접속 가능하다. `http://localhost:60005`로 사이트에 접속해보면 아래와 같은 결과를 볼 수 있다.

![v0.1 사이트 접속][v0.1]

[v0.1]: /images/2014-06-16-rails-on-docker/v0.1.png

접속은 정상적으로 이루어지지만 에러가 난다. 이 에러는 내부 에러라기보다는 아직 레일스 어플리케이션을 전혀 작성하지 않았기 때문에 발생하는 에러이다. 즉, 메인 라우트가 없기 때문에 발생한다. 이전에 Rails3까지는 Public 폴더에 레일스 기본 페이지가 있었으나, Rails4 부터는 이러한 기본 페이지가 동적으로 생성되며 프로덕션 모두에서는 작동하지 않는다. 따라서 에러가 발생하는 것이다. 일단 어플리케이션 작성이 목적은 아니라 **정상적으로** 에러가 나는 것을 축하하며 다음으로 넘어가자.

다시 로그를 출력해본다.

```
$ docker logs v0.1
15:54:16 web.1  | started with pid 10
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  WEBrick 1.3.1
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  ruby 2.1.1 (2014-02-24) [x86_64-linux-gnu]
15:54:18 web.1  | [2014-06-11 15:54:18] INFO  WEBrick::HTTPServer#start: pid=10 port=60005
```

프로덕션 모드에서는 기본적으로 로그가 전부 파일에서 출력되기 때문에 아무것도 출력되지 않는다.

여기까지 해서 훌륭히 첫번째 레일스 어플리케이션을 도커로 빌드하고 실행해봤다. 이제 컨테이너를 종료하고 v0.2로 넘어간다.

```
$ docker stop v0.1
v0.1
$ docker rm v0.1
v0.1
```

## v0.2 rails_12factor

히로쿠(heroku)를 사용해본 적이 있다면 히로쿠의 배포 방식이 기존의 배포 방식과는 상당히 다르다는 것을 알 수 있다. 클라우드로 따지자면 Infrastructure as a Service와 Platform as a Service의 차이라고 단순히 말할 수도 있겠지만, 그러한 환경을 구현하기 위해서 많은 것이 달라진다. 그리고 그러한 변화에 대응하기 위해 적용되는 라이브러리가 `rails_12factor`라는 gem이다.

분명 잘은 모르겠지만,

Heroku에서는 이 gem을 설치하라고 하고, 이 gem을 설치하면 뭔가 문제가 생기된 게 해결된다. 하지만 마법과 같은 이 Gem이 무엇을 하는 지까지 관심을 가지는 경우는 드물다. 이번에는 이 gem 을 설치하고 그 궁금증을 해소해본다.

### 프로젝트 변경사항

```
$ cd ../docker-sample-project
$ git checkout v0.2
$ cat Gemfile | grep 12
(standard input):13:gem 'rails_12factor'
```

프로젝트에 변경되는 부분은 거의 없다. 단지 gem에 rails_12factor를 추가했을 뿐이다.

### Dockerfile

Dockerfile에 대해서도 위에서 자세히 설명했다. 여기서 달라지는 부분은 실질적으로 `v0.2`로 체크아웃하는 거 이외에는 없다.

````
# Dockerfile
$ cd ../v0.2
$ cat Dockerfile
$ diff Dockerfile ../v0.1/Dockerfile
22c22
< # Install docker-sample-project v0.2
---
> # Install docker-sample-project v0.1
25c25
< RUN git checkout v0.2
---
> RUN git checkout v0.1
```

### 이미지 빌드하기

빌드도 똑같다. 단지 이번에는 태그에 `0.2`를 주고 빌드한다.

```
$ docker build -t nacyot/rails-new:0.2 .
Sending build context to Docker daemon 3.072 kB
Sending build context to Docker daemon 
Step 0 : FROM dockerfile/ubuntu
 ---> 96af2d36fb39
Step 1 : MAINTAINER nacyot(propellerheaven@gmail.com)
 ---> Using cache
 ---> 63b3eaf59343
Step 2 : RUN apt-get update
 ---> Using cache
 ---> c20d985f7209
...
Step 18 : EXPOSE 60005
 ---> Using cache
 ---> 2804c093d552
Step 19 : CMD foreman start -f Procfile
 ---> Using cache
 ---> a8263aeb3676
Successfully built a8263aeb3676
```

### 이미지 실행하기

실행하고 정상적으로 실행되었는 지 확인해본다.

```
$ docker run --name v0.2 -d -p 60005:60005 nacyot/rails-new:0.2
019e38fb70382fd1e49c3be7b011b7ea715644e6bb6b99f199506d8e8708fadb
$ docker ps -l
CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS               NAMES
019e38fb7038        nacyot/rails-new:0.2   /bin/sh -c 'foreman    16 minutes ago                                              v0.2
```

`http://localhost:6005`로 접속해본다.

![v0.2 사이트 접속][v0.2]

[v0.2]: /images/2014-06-16-rails-on-docker/v0.2.png

v0.1 때와 같은 에러가 출력된다. 다시 로그를 출력해본다.

```
$ docker logs v0.2
16:00:27 web.1  | started with pid 10
16:00:29 web.1  | [2014-06-14 16:00:29] INFO  WEBrick 1.3.1
16:00:29 web.1  | [2014-06-14 16:00:29] INFO  ruby 2.1.1 (2014-02-24) [x86_64-linux-gnu]
16:00:29 web.1  | [2014-06-14 16:00:29] INFO  WEBrick::HTTPServer#start: pid=10 port=60005
16:00:33 web.1  | => Booting WEBrick
16:00:33 web.1  | => Rails 4.1.1 application starting in production on http://0.0.0.0:60005
16:00:33 web.1  | => Run `rails server -h` for more startup options
16:00:33 web.1  | => Notice: server is listening on all interfaces (0.0.0.0). Consider using 127.0.0.1 (--binding option)
16:00:33 web.1  | => Ctrl-C to shutdown server
16:00:33 web.1  | Started GET "/" for 172.17.42.1 at 2014-06-14 16:00:33 +0000
16:00:33 web.1  | 
16:00:33 web.1  | ActionController::RoutingError (No route matches [GET] "/"):
16:00:33 web.1  |   actionpack (4.1.1) lib/action_dispatch/middleware/debug_exceptions.rb:21:in `call'
16:00:33 web.1  |   actionpack (4.1.1) lib/action_dispatch/middleware/show_exceptions.rb:30:in `call'
...
```

뭔가 달라졌다. 분명 `v0.1` 때는 로그에 아무것도 출력되지 않았으나, `v0.2`에서는 에러에 대한 로그가 출력된다.

`v0.2`에서 코드가 달라진 부분은 `rails_12factor`를 추가한 부분뿐이다. 그렇다면 자연스럽게 결론을 내릴 수 있다. `rails_12factor`는 로그를 Process의 stdout으로 출력해준다.

### The Twelve-Factor App 

여기서 두 가지 정도 의문이 들 것이다.

`rails_12factor`는 왜 로그를 굳이 파일이 아니라 stdout로 출력해주는 걸까?

그리고 이 gem을 여기서 왜 설치했을까?

이는 도커의 컨테이너 환경을 이해하는데 핵심적인 역할을 하는 문제이다. 잠깐 히로쿠 이야기로 돌아가보자. 일반적으로 운영체제에서 할 수 있는 모든 것을 할 수 있는 가상머신인 IaaS와 어플리케이션 코드만으로 실행 가능한 PaaS는 근본적으로 많은 부분에서 다르다. 예를 들어 히로쿠에는 서버 관리라는 개념이 없다. 히로쿠를 써봤다면 알겠지만, 히로쿠에 git 저장소를 만들어놓고 이 저장소에 어플리케이션을 push하면 어플리케이션이 빌드되고 자동으로 실행된다. 여기서 중요한 점은 heroku에서 실행되고 있는 서버에 접근해서 어떠한 명령어를 실행시키는 게 거의 불가능하다는 점이다(혹은 매우 제한적이다). 사용자는 히로쿠의 서버를 운영하지 않는다. 그런 면에서 볼 때 PaaS란 단순히 IaaS의 일부 역할을 대체한다고 말할 수가 없어진다. 어플리케이션을 운영해본 사람이라면 알겠지만 어플리케이션과 직접 관련이 없더라도 어플리케이션 운영중에 서버 상에서 여러가지 작업을 필요로 하는 경우는 흔한 일이다. 히로쿠에서는 그런 종류의 작업이 거의 불가능하다.

단지 어플리케이션이 실행되고 있을 뿐이다.

따라서 PaaS에서 어플리케이션을 운영하는 모델은 IaaS에서 해오던 것과는 전혀 다르다. 바로 이 지점에서 단순한 범위 차이 이상의 차이가 발생한다. 이러한 차이는 최적화의 문제이기도 하고, 패러다임의 문제이기도 하다. 예를 들어 TDD를 적용해 프로그래밍을 하면 단순히 테스트를 습관화들이는 것뿐만 아니라, 어플리케이션을 설계하는 데 있어서도 테스트가 더 편하게 가능한 설계를 고민하게 된다는 이야기와 비슷하다. PaaS는 기존의 어플리케이션을 그대로 옮겨둘 수도 있겠지만, PaaS 방식에 맞는 어플리케이션을 요구한다. 여기서 어플리케이션이란 단순히 실제 어플리케이션 코드만을 이야기하는 것은 아니다. 어플리케이션과 그것을 운영하고 관리하는 방식 전체를 통틀어서의 이야기이다.

추상적인 얘기는 집어치우고, 그래서 왜 히로쿠에서는 `rails_12factor`가 필요할까? 정답은 간단하다. 사용자는 히로쿠 서버의 파일 시스템에 직접적으로 접근할 수 없고, 따라서 log파일을 직접 가져오는 게 불가능하다. 바로 이런 지점이 IaaS와 PaaS가 극적으로 달라지는 부분이자, 패러다임 시프트를 요구하는 부분이다. 어쨌거나 로그는 필요하다. 그래서 히로쿠는 CLI 클라이언트를 통해서 마지막 (최대) [1500줄 분량의 로그를 제공해준다][log]. 이를 위해서 rails_12factor를 통해 파일로 보내질 로그를 stdout으로 출력할 필요가 있었던 것이다. 즉 히로쿠에서는 전체 어플리케이션 로그를 가져올 방법이 없고, 히로쿠에서는 이러한 문제를 해결할 수 있는 방안으로 다른 로깅 서비스를 연동해서 사용할 것을 이야기하고 있다.

[log]: https://devcenter.heroku.com/articles/limits#logs

이 정도면 조금 감이 올 지 모르겠다. 도커, 좀 더 정확히는 컨테이너는 기본적으로 PaaS에 가깝다. 도커에서도 히로쿠와 마찬가지로 실행중인 어플리케이션의 서버를 운용하는 방식으로 관리하는 것은 매우 번거롭고 제한적이다. 더욱이 Adam Wiggins은 The Twelve-Factor App에서 히로쿠의 로그 방식이 단순히 파일을 다룰 수 없는 제약 때문은 아니었다는 것을 분명히 이야기하고 있다.

> 로그는 모든 실행중인 프로세스와 백엔드 서비스의 누적되며 시간순으로 수집되고 정렬되는 이벤트 스트림이다. 일반적으로 어플리케이션이 직접 생성하는 로그는 한 줄에 하나의 이벤트를 텍스트 포맷으로 기록한다(예외를 추적하는 로그는 여러줄로 쓰여지기도 한다). 로그는 고정된 시작과 끝이 없으면 어플리케이션이 실행되는 한 계속된다.
> 
> Twelve Factor App은 어플리케이션의 출력 스트림의 목적지나 어디에 저장되는 지 일체 간섭하지 않는다. 어플리케이션은 로그를 작성하거나 로그 파일을 관리하려고 해서는 안된다. 로그 파일을 관리하는 대신 각각의 실행중인 프로세스는 자신의 이벤트 스트림을 버퍼없이 stdout에 출력한다. 로컬에서 개발중인 프로그래머는 이러한 스트림을 터미널의 포그라운드에서 확인할 수 있으며, 이를 통해 어플리케이션이 어떻게 동작하는 지 확인할 수 있다. ([The Twelve-Factor App 11장 로그][ttfa-log])

[ttfa-log]: http://the-twelve-factor-app.herokuapp.com/logs

아, 여기서 `rails_12factor`의 정체가 명확해진다. `rails_12factor`은 다름 아닌 The Twelve-Factor App의 실천사항의 일부를 실제로 구현해주는 gem이다. 소개가 늦었다. The Twelve-Factor App은 위에서 이야기한 PaaS의 패러다임에 해당하는 이야기를 히로쿠의 프로그래머가 정리한 문서이다.

도커는 어렵다. 도커를 가상화 기술이라고 소개할 때 VMWare나 VirtualBox와 같은 툴들과 상당한 차이를 지니고 있다. 이는 단순히 하드웨어 에뮬레이션 정도의 차이가 아니라, 어플리케이션을 다루는 방식 전반에 걸친 차이가 존재하기 때문이다. 그리고 컨테이너라는 개념과 이러한 차이를 이해하는 게 도커를 활용하는 지름길이라고 할 수 있다. 컨테이너는 단지 하나의 프로세스이고, 이 하나의 프로세스로 어플리케이션을 운영해야한다는 점에서는 VMWare의 가상머신보다는 히로쿠의 어플리케이션에 한없이 가깝다. 따라서 The twelve-Factor App의 원칙들은 컨테이너를 유연하게 사용하는데 좋은 지침이 된다. 이는 2가지 면에서 좋은 지침이 되어주는데, 도커에서 어플리케이션을 어떻게 실행 관리되는 지를 알려주고, 두번째로 `Build once, Run anywhere`를 실현할 수 있는 전략들을 알려준다.

물론 도커의 컨테이너를 가상머신처럼 다루는 게 불가능하지는 않다. 컨테이너를 실행할 때 sshd 데몬을 같이 띄운다거나 log가 저장되는 디렉토리 자체를 어플리케이션에 이미지와 별개로 마운트시키는 방식으로 log 파일을 관리하는 게 가능하기는 하다. 하지만 그런 방식이 도커에서 딱히 권장되지는 않는다.

이 정도면 처음에 품었던 두 가지 질문에 대한 설명은 충분히되었다.

### rails_12factor

그렇다면 실제로 `rails_12factor`가 해주는 일은 어떤 것들이 있을까?

먼저 로그를 stdout으로 출력해주는 것은 이미 살펴보았다. 또 하나는 앞서 다룬 `serve_static_assets`를 활성화시켜는 일이다. rails_12factor가 하는 일은 정말 딱 이렇게 두가지다.

### v0.2 정리

이걸로 v0.2에 대한 설명도 마무리 되었다. 이제 컨테이너를 멈추고 삭제한다.

```
docker stop v0.2
docker rm v0.2
```

## v0.3 데이터베이스 연동하기

웹 어플리케이션의 꽃은 이러쿵저러쿵 해도 데이터베이스다. `v0.3`에서는 데이터베이스를 연동하고 간단한 scaffolding을 통해 에러없이 어플리케이션이 작동하도록 만든다.

### 프로젝트 변경사항

먼저 v0.3에서는 scaffold 명령어로 Post 모델을 생성했다.

```
$ bundle exec rails g scaffold post title body:text published:boolean
```

`config/routes.rb` 파일을 아래와 같이 변경한다.

```
Rails.application.routes.draw do
  root "posts#index"
  resources :posts
end
```

그 외에 변경한 사항은 mysql2 gem을 추가한 정도이다.

```
$ git checkout v0.3
$ cat Gemfile | grep mysql2
(standard input):14:gem 'mysql2'
```

### Dockerfile

rails-new-docker/v0.3의 Dockerfile에서 달라진 부분은 아래와 같다.

```
$ diff Dockerfile ../v0.2/Dockerfile
19d18
< RUN apt-get install -qq -y mysql-server mysql-client libmysqlclient-dev
23c22
< # Install docker-sample-project v0.3
---
> # Install docker-sample-project v0.2
26c25
< RUN git checkout v0.3
---
> RUN git checkout v0.2
34d32
< 
```

mysql에 필요한 시스템 패키지를 설치하고 v0.3으로 체크아웃 하는 정도이다.. 시스템 라이브러리를 설치하는 부분은 레일스를 처음 사용할 때 겪는 함정으로 해당하는 패키지가 없으면 `bundle install`에 실패한다.

### 이미지 빌드하기

이미지를 빌드한다.

```
docker build -t nacyot/rails-new:0.3 .
```

### 이미지 실행하기

이미지를 실행한다.

```
docker run --name v0.3 -d -p 60005:60005 nacyot/rails-new:0.3
```

`http://localhost:60005` 페이지에 접속해본다.

![v0.3 사이트 접속 - We`re sorry, but something went wrong][v0.3]

[v0.3]: /images/2014-06-16-rails-on-docker/v0.3.png

이번에는 에러메시지가 달라졌다. 이전 에러메시지는 페이지가 없다는 내용(즉 라우트가 없음)이었는데 이번에는 'We're sorry, but something went wrong.'라고 내부적으로 문제가 있다는 걸 볼 수 있다. 

구체적인 내요은 로그를 확인해본다.

```
$ docker logs v0.3
02:50:21 web.1  | started with pid 9
02:50:23 web.1  | [2014-06-15 02:50:23] INFO  WEBrick 1.3.1
02:50:23 web.1  | [2014-06-15 02:50:23] INFO  ruby 2.1.1 (2014-02-24) [x86_64-linux-gnu]
02:50:23 web.1  | [2014-06-15 02:50:23] INFO  WEBrick::HTTPServer#start: pid=9 port=60005
02:50:34 web.1  | => Booting WEBrick
02:50:34 web.1  | => Rails 4.1.1 application starting in production on http://0.0.0.0:60005
02:50:34 web.1  | => Run `rails server -h` for more startup options
02:50:34 web.1  | => Notice: server is listening on all interfaces (0.0.0.0). Consider using 127.0.0.1 (--binding option)
02:50:34 web.1  | => Ctrl-C to shutdown server
02:50:34 web.1  | Started GET "/" for 172.17.42.1 at 2014-06-15 02:50:34 +0000
02:50:34 web.1  | Processing by PostsController#index as HTML
02:50:34 web.1  | SQLite3::SQLException: no such table: posts: SELECT "posts".* FROM "posts"
02:50:34 web.1  |   Rendered posts/index.html.erb within layouts/application (6.3ms)
02:50:34 web.1  | Completed 500 Internal Server Error in 16ms
02:50:34 web.1  | 
02:50:34 web.1  | ActionView::Template::Error (SQLite3::SQLException: no such table: posts: SELECT "posts".* FROM "posts"):
02:50:34 web.1  |     11:   </thead>
02:50:34 web.1  |     12: 
02:50:34 web.1  |     13:   <tbody>
02:50:34 web.1  |     14:     <% @posts.each do |post| %>
02:50:34 web.1  |     15:       <tr>
02:50:34 web.1  |     16:         <td><%= post.title %></td>
02:50:34 web.1  |     17:         <td><%= post.body %></td>
02:50:34 web.1  |   app/views/posts/index.html.erb:14:in `_app_views_posts_index_html_erb___1118890408216197302_48728380'
02:50:34 web.1  | 
02:50:34 web.1  | 
```

에러 메시지를 자세히 살펴보면, 중간에 `SQLite3::SQLException` 에러가 발생한 것을 알 수 있다. 이 이유가 발생한 이유는 간단하다. `db:migrate`(혹은 `db:create`)를 하지 않았기 때문이다. 앞서 scaffold로 만든 post 모델은 데이터베이스를 필요로 한다. 레일스에서는 데이터베이스 접속을 `config/database.yml`에서 관리하는데 아무것도 설정하지 않으면 sqlite를 로컬에서 사용한다. 하지만 지금은 데이터베이스가 제대로 초기화되어있지 않기 때문에 문제가 발생하는 것이다.

이번에는 실제 데이터베이스에 연결하고 초기화하는 방법을 알아보자. 먼저 지금 실행중인 컨테이너를 삭제한다.

```
$ docker stop v0.3
$ docker rm v0.3
```

### 데이터베이스 준비

여기서는 데이터베이스로 mysql을 사용한다. 이를 통해서 도커에서 웹어플리케이션을 실행시킬 때 어떻게 외부 서비스를 연결하는지 알 수 있다. 먼저 mysql을 준비한다. 여기서는 편의상 호스트에 mysql을 설치한다.

```
$ sudo apt-get install mysql-server
```

데이터베이스에 접속해서 데이터베이스 및 계정을 추가하고 권한을 부여해준다. 데이터베이스 접속시 사용하는 root 계정의 암호는 위에서 mysql 설치 과정에서 입력하는 암호이다.

```
$ mysql -h localhost -u root -p
Enter password:
mysql> CREATE DATABASE rails_new
mysql> GRANT ALL PRIVILEGES ON rails_new.* TO 'docker'@'localhost' IDENTIFIED BY 'docker';
mysql> GRANT ALL PRIVILEGES ON rails_new.* TO 'docker'@'%' IDENTIFIED BY 'docker';
mysql> exit
```

권한 설정이 끝났으면 데이터베이스 접속을 종료하고 docker 계정으로 다시 접속한다

```
$ mysql -h localhost -u docker -p
Enter password:
mysql> use rails_new
Database changed
mysql > show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| rails_new          |
+--------------------+
2 rows in set (0.00 sec)
mysql> show tables;
Empty set (0.00 sec)
```

마지막으로 도커 컨테이너의 mysql 서버로 접속이 가능하도록 `/etc/mysql/my.cnf` 파일을 편집해준다.

```
bind-address = 0.0.0.0
```

데이터베이스를 재실행한다.

```
$ sudo service mysql restart
```

이것으로 데이터베이스가 준비되었다.

### 컨테이너로 rake 명령어 사용하기 - db:migrate

이번에는 도커 컨테이너를 통해서 rake를 실행해 데이터베이스 테이블을 초기화한다.

```
$ docker run -i -t -e DATABASE_URL="mysql2://docker:docker@172.17.42.1/rails_new" nacyot/rails-new:0.3 bundle exec rake db:migrate

Migrating to CreatePosts (20140608141640)
== 20140608141640 CreatePosts: migrating ======================================
-- create_table(:posts)
   -> 0.0035s
== 20140608141640 CreatePosts: migrated (0.0036s) =============================
```

기본적으로 루비 온 레일스에서는 데이터베이스 연결을 `database.yml` 파일에서 관리한다. 하지만 `DATABASE_URL` 환경 변수가 설정되어있다면 이 설정을 우선적으로 사용한다. 여기서는 컨테이너를 실행하는 호스트에 있는 mysql을 사용하니 `mysql2://docker:docker@localhost/rails_new`처럼 지정해준다. 여기에는 프로토콜, Id, Password, Host, Database 정보를 담고있다. 이제 레일스 어플리케이션은 이 데이터베이스를 사용한다. 여기서 `172.17.42.1`은 도커 내부에서 바라보는 호스트 PC의 IP이다. 컨테이너 안에서 localhost나 127.0.0.1이 도커 컨테이너 자체를 가리킨다고 생각하면 이해하기 쉬울 것이다.

그 다음에는 실행하고자 하는 이미지를 지정한다.

마지막 부분이 중요하다. 앞서서도 이야기했지만 컨테이너는 하나의 프로세스이다. 즉 이미지로부터 컨테이너를 실행할 때 실행하고자 하는 명령어를 지정할 수 있다. 일반적으로 이미지를 사용하면 `CMD` 지시자를 통해 지정된 기본 명령어를 사용하지만, 직접 명령어를 입력하면 해당하는 명령어가 실행된다.

따라서 위에서 실행한 `docker run` 명령어는 'nacyot/rails-new:0.3' 이미지를 통해서 `bundle exec rake db:migrate`를 실행한다. 이 때 외부 데이터베이스 서비스를 사용하도록 외부 mysql을 지정했으므로 해당하는 데이터베이스에 대해 `db:migrate`가 이루어진다. 여기서는 CreatePosts가 생성된다.

위에서 실행한 컨테이너는 단지 이 역할만 하고 종료된다.

### 데이터베이스가 연결된 어플리케이션 실행하기

이제 어플리케이션을 실행하고 어플리케이션에 접속한다.

```
docker run -d --name v0.3 -p 60005:60005 -e DATABASE_URL="mysql2://docker:docker@172.17.42.1/rails_new" nacyot/rails-new:0.3
```

![v0.3 사이트 접속][v0.3db]

[v0.3db]: /images/2014-06-16-rails-on-docker/v0.3db.png

정상적으로 실행된다! posts를 하나 만들어본다.

![v0.3 사이트 접속 - We`re sorry, but something went wrong][v0.3db2]

[v0.3db2]: /images/2014-06-16-rails-on-docker/v0.3db2.png

포스트도 정상적으로 만들어졌다. 이제 mysql에 접속해 지정한 데이터베이스에 정상적으로 기록이 되고있는지 확인한다.

```
$ mysql -h localhost -u docker -p
mysql> USE rails_new
mysql> SELECT * FROM posts;
+----+---------------+--------+-----------+---------------------+---------------------+
| id | title         | body   | published | created_at          | updated_at          |
+----+---------------+--------+-----------+---------------------+---------------------+
|  1 | Hello, Docker | Docker |         1 | 2014-06-15 04:49:20 | 2014-06-15 04:49:20 |
+----+---------------+--------+-----------+---------------------+---------------------+
1 row in set (0.00 sec)
mysql> exit
```

정상적으로 기록된다. 이제 도커를 통해 레일스 어플리케이션을 배포할 때 데이터베이스를 연결하는 것까지 성공했다.

### sqlite3 vs mysql, database.yml vs 환경변수

여기서 잠깐 왜 mysql과 환경변수를 사용했는지 살펴볼 필요가 있다.

먼저 sqlite3는 파일 하나로 구성되는 데이터베이스이다. 이는 임시로 사용하기에는 편리하지만 실제 어플리케이션에서 사용하기는 여러가지 제약이 따른다. 또한 도커 이미지를 통해서 어플리케이션을 배포할 때 sqlite를 사용하게 되면 어플리케이션과 데이터가 강하게 결합되게 된다. 이는 어플리케이션이 컨테이너의 상태에 강하게 의존되어 실행된다는 의미를 가진다. 이러한 로컬 파일 시스템에 의존해야할 때는 `docker run`의 `-v`와 같은 옵션을 사용해 이미지에 별개의 볼륨을 마운트 시켜 사용하는 방법이 있기는 하지만, 어플리케이션과 데이터는 가능한한 분리하는 것이 좋다. 이러한 분리가 이루어져야만 관리가 용이할 뿐 아니라 나중에 컨테이너 실행만으로도 스케일 아웃이 가능해진다. (물론 여기에는 좀 더 여러가지 궁리가 필요하지만...)

`database.yml` 역시 비슷한 이유에서 권장되지 않는다. 데이터베이스 커넥션 정보를 파일 형태로 가지고 있을 시에는 어플리케이션이 이 파일에 의존해서 작동한다. 여기에는 몇 가지 문제가 있는데 어플리케이션 저장소에 이러한 파일을 포함시키는 것은 매우 좋지 않다.

> 어플리케이션에서 설정이 분리되어있는 지 여부를 확인할 수 있는 간단한 방법은, 어플리케이션 내부에 어떠한 인증 정보도 포함시키지 않고 지금 당장 오픈소스로 공개할 수 있는 지 검토해보는 것이다. [The Twelve-Factor App - 설정][ttfa-config]

만약 저장소에 저장시키지 않고 이미지 빌드 시에 해당하는 파일을 전달해준다고 해도, 데이터베이스 설정이 바뀔 때마다 이미지를 새로 만들어야하는 불편함이 수반된다. 데이터베이스 접속을 `database.yml`에 의존하지 않고 데이터베이스 핸들러를 환경변수로 관리하면 이러한 불편함이 해소된다. 즉 외부 서비스가 어디에 있는지와는 상관없이 어플리케이션을 이미지로 보관할 수 있고, 실행시에 동적으로 외부 서비스들을 연결해줄 수 있다는 의미이다. 외부 서비스에 대해서 파일 설정보다 환경변수를 적극 활용하는 것은 `Build once, Run anywhere`를 구현하기 위해 The Twelve Factor App에서 제시하는 하나의 전략이라고 할 수 있다.

> Twelve-Factor App에서는 설정을 환경 변수(environment variables)에 저장한다. 환경변수를 사용하면 코드 수정 없이 설정을 쉽게 변경할 수 있다. 설정 파일과는 달리 실수로 저장소에 설정을 포함시킬 가능성도 낮다. 나아가 독자적인 형식의 설정 파일이나 자바 시스템 프로퍼티와 같은 설정 형식과 달리 환경변수는 언어나 OS에 의존하지 않는 표준이다. [The Twelve-Factor App - 설정][ttfa-config]

[ttfa-config]: http://the-twelve-factor-app.herokuapp.com/config



## 레일스 어플리케이션 이미지 배포하기

### 이미지 배포하기

#### hub.docker.com

* hub.dokcer.com
  * 구 index.docker.io
  * 많은 오픈소스들이 도커 이미지로 공유됨
  * 일부 오픈소스는 프로젝트에서 공식 지원
    * strider-cd, 도커 관련 프로젝트들

* https://registry.hub.docker.com/u/nacyot/docker-yobi
  * https://github.com/nacyot/docker-yobi
  * Dockerfile만 올리면 알아서 자동 빌드
  * commit 후크

* 올리는 과정
  * Dockerfile 있는 저장소 생성
  * Docker Hub에서 Github 연동

```
# 이미지 받아오기
docker pull nacyot/docker-yobi
docker images | grep nacyot/docker-yobi

# 컨테이너 실행
docker run --name YOBI -d -p 3001:9000 nacyot/docker-yobi

# 로그 보기
docker logs -f YOBI
```

* YOBI 사이트 접속 및 기본 설정
* 로그인 및 프로젝트 생성

```
cd ../hello-yobi
git remote -v
git push origin master
```

* 프로젝트 페이지 확인

```
# YOBI 삭제
docker stop YOBI
docker rm YOBI
```

### Private Docker Registry Server

* Docker registry
  * https://github.com/dotcloud/docker-registry
  * Docker Image 제공

#### docker-registry server

```
# 디지털 오션 클라이언트 설치
# gem install tugboat

# 가상 서버 생성
tugboat create registry -s 66 -i 3668014 -r 6 -k 102859

# 서버 실행 확인
tugboat droplets | grep registry
ping 128.199.252.140
# ssh-keygen -f "/home/nacyot/.ssh/known_hosts" -R 128.199.252.140

# registry 서버 접속
ssh root@128.199.252.140
docker version

# registry 이미지 가져오기
docker pull registry
docker run -d -p 5000:5000 registry

# ssh 빠져나오기
exit

# docker-registry 서버 테스트
curl -XGET http://128.199.252.140:5000/
```

#### registry 서버에 이미지 push

```
# registry 등록용 tag 지정
docker tag nacyot/rails-new:0.3 128.199.252.140:5000/rails-new:0.3

# 이미지 push하기
docker push 128.199.252.140:5000/rails-new:0.3
```

#### registry 서버에서 이미지 pull

```
# 가상 서버 실행
tugboat create docker1 -s 66 -i 3668014 -r 6 -k 102859
tugboat droplets | grep docker
ping 128.199.189.203

# ssh 접속
ssh root@128.199.189.208
ssh-keygen -f "/home/nacyot/.ssh/known_hosts" -R 128.199.189.208
docker --version
docker pull 128.199.252.140:5000/rails-new:0.3
docker images
docker run -d --name v0.3 -p 60005:60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" 128.199.252.140:5000/rails-new:0.3
w3m http://localhost:60005
```

#### 아마존 서버

```
ssh ubuntu@ec2-54-178-163-61.ap-northeast-1.compute.amazonaws.com -i ~/.ssh/amazonNacyot.pem
docker --version
docker pull 128.199.252.140:5000/rails-new:0.3
docker images
docker run -d --name v0.3 -p 60005:60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" 128.199.252.140:5000/rails-new:0.3
w3m http://localhost:60005
```

* Stateless Sharde Nothing

### vs chef, vs ami

#### chef

* 관리가능하고 (Cookbook)
* 테스트 가능하며
* 재현 가능하며
* --Stateless하고--
* Scalable한
* --이미지 기반의--
* 어플리케이션 배포

### AMI

* 관리가능하고(AMI Image)
* --테스트 가능하며--
* --재현 가능하며--
* --Stateless하고--
* Scalable한
* 이미지 기반의
* 어플리케이션 배포

### Docker

* 관리가능하고(AMI Image)
* 테스트 가능하며
* 재현 가능하며
* Stateless하고
* Scalable한
* 이미지 기반의
* 어플리케이션 배포

### v0.4 haproxy

#### rails 0.4

```
cd docker-sample-project
git checkout v0.3
git diff v0.4
```

#### haproxy

```
cd ..

# haproxy 이미지 pull
dokcer pull dockerfile/haproxy

# haproxy 환경 설정 파일
cat haproxy/haproxy.cfg

# haproxy 실행하기
docker run -d -p 3000:60000 -v /home/nacyot/Dropbox/writings/rails-on-docker/rails-new-dockerfile/haproxy:/haproxy-override dockerfile/haproxy
```

#### Build

```
cd ../v0.4
diff Dockerfile ../v0.3/Dockerfile
docker build -t nacyot/rails-new:0.4 .
```

#### 서버 실행하기

# rails 서버 실행하기
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4

docker ps
```

### packer

* http://www.packer.io/docs

```
cd ../packer
cat site-cookbooks/apache/recipes/default.rb
cat machine_chef.json
packer build machine
```

* Dokku
* Building
* Dockerfile
