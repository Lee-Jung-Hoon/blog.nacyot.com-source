---
title: "도쿠(Dokku)로 만드는 미니 히로쿠(Heroku)"
date: 2014-01-30 01:30:00 +0900
author: nacyot
profile: 구름 위를 헤매는 프로그래머(29)
tags: docker, dokku, heroku, tutorial, nginx, buildpack, paas, iaas, infrastructure
categories: infrastructure
title_image: http://i.imgur.com/e8TYHYx.jpg
---

지난 번 [도커][docker] 시리즈의 첫번째 글에서는 [도커(Docker) 튜토리얼 : 깐 김에 배포까지][docker-1] 도커를 설치하고 이미지와 컨테이너의 개념 그리고 마지막으로 Dockerfile을 통해서 이미지를 생성하고 실제로 배포하는 부분까지 다뤄봤습니다. 이번 글에서는 [[도커|docker]]를 활용해 간단히 어플리케이션 배포 서버를 구축할 수 있게 도와주는 [도쿠][dokku](Dokku)를 다루도록 하겠습니다.

<!--more-->

[docker]: http://docker.io/
[docker-1]:http://blog.nacyot.com/articles/2014-01-27-easy-deploy-with-docker/
[dokku]: https://github.com/progrium/dokku/

## 도쿠(Dokku) 소개 ##

Jeff Lindsay이 개발한 도쿠는 도커(Docker)를 활용해 100줄 남짓한 쉘스크립트 본체와 도쿠를 둘러싼 몇 가지 모듈들을 활용해 미니 [히로쿠][heroku](Heroku)와 같은 [[PaaS]] 환경을 구축할 수 있도록 해줍니다. 도쿠 스스로가 미니 히로쿠라고 표현하고 있습니다만, 사용해보시면 아시겠지만 정말 히로쿠와 비슷합니다. 실제로 내부적으로 도쿠는 히로쿠에서 공개한 각 언어별 빌드팩들을 그대로 사용하고 있습니다. 히로쿠를 통해서 서비스를 배포해보셨거나 [Rails Tutorial][tutorial]을 따라하면서 배포를 연습해보셨던 분들이라면 꽤나 반갑게 느껴지실 겁니다. 실제로 활용을 하건 안하건, 이런 훌륭한 시스템(생태계)을 직접 구축해볼 수 있다니!

[heroku]: https://heroku.com
[tutorial]: http://ruby.railstutorial.org/

도커도 [[도쿠|dokku]]도 매력적이지 않을 수 없습니다.

[[히로쿠|heroku]]나 PaaS에 대해서 잘 모르는 분들은 이런 개념이 낯설게 느껴지실 지도 모릅니다. 히로쿠나 PaaS 역시 클라우드 생태계의 한 축을 구성하고 있는 단어들입니다. 클라우드하면 가상화입니다. 클라우드의 본질적인 가치는 하드웨어 추상화에 있습니다. 하드웨어를 추상화하기 위해서는 다양한 기술과 관리를 위한 기술들이 필요합니다만, 이렇게 추상화된 하드웨어를 이용하는 입장에서는 '더 이상' 하드웨어라는 물리적인 영역을 신경쓰지 않아도 됩니다. 개발과는 거리가 있습니다만, 이런 종류의 추상화를 가장 잘 보여주는 게 **[[구글|google]] 검색창**입니다. 그 안에서 어떠한 로직과 방법으로 데이터를 분석하는지는 전혀 알 필요없이, 우리는 구글의 엄청나게 거대한 시스템을 사용할 수 있습니다. 그렇게 보자면 서비스는 가장 높은 단계의 추상화라고 할 수 있습니다. 

[[IaaS]]나 [[Paas]]는 이보다 좀 더 낮은 단계의 추상화를 제공합니다. 서비스를 이용하는 사람은 서버가 어떤 하드웨어로 구성되어있고, 램은 몇 기가고 CPU는 뭘 쓰고 있고 신경쓸 필요가 없을 뿐더러, 어떤 운영체게 위에서 돌아가는지, 어플리케이션이 어떤 언어를 사용하고, 어떤 구조로 만들어져있고 데이터베이스가 어떻게 분산되어있는지도 신경쓸 필요가 없습니다. 앞의 문장을 **어디까지 신경써야 하는가**를 가지고 단계를 나눌 수 있습니다. 앞서 이야기했듯이 서비스는 위에서 아무것도 신경쓰지 않습니다. 여기서 한단계 내려가면 사용하는 언어와 어플리케이션만 신경써야하는 단계가 있습니다. 이 아래에 있는 것들은 서비스로 지원합니다. 여기가 PaaS가 위치한 곳입니다. 여기서 더 아래로 내려가면 CPU의 성능과 램의 용량을 따지고 어떤 운영체제를 사용하고  각각의 시스템들을 어떻게 연동시켜야하는지 하는 부분이 나옵니다. 심지어 시스템의 크기까지 제어할 수 있습니다. 여기가 바로 IaaS가 위치한 곳입니다. 더 아래로 내려가면 네, 실제 서버 구성부터 이것저것 모든 것을 다 해야합니다. 해보신 분들은 아시겠지만 이런 일은 한 마디로 말해서 고역입니다. 운영체제도 하드웨어도 같지 않은 같지 않은 수십대의 시스템을 효과적으로 관리한다는 건 거의 불가능에 가깝습니다. 거기다가 고장까지 고려하면 더더욱 쉽지 않은 일입니다.

다시 클라우드입니다만, 클라우드의 본질적인 가치는 어플리케이션을 개발하는데 있어서 우리가 어디까지 신경서야하는 지 그 위치를 **선택가능한 옵션**으로 떨어뜨려줬다는 데 있습니다. 그건 내가 해줄게 하는 겁니다. AWS가 나오기 전에 서비스를 만드는 사람들에게 그런 종류의 선택권은 존재하지 않았습니다. 구체적이 서비스를 예를 들면 [AmazonWS EC2][ec2]가 IaaS라면 히로쿠나 구글 앱 엔진은 대표적인 PaaS 서비스입니다. 더욱 재미있는 건 Heroku가 다름 아닌 AWS 위에서 돌아가고 있다는 사실입니다. 

[ec2]: http://aws.amazon.com/en/ec2/

특히 히로쿠는 [루비 온 레일즈][rails]를 시작으로 현재는 [[자바|java]], [[Node.js]], [[파이썬|python]] 어플리케이션까지 지원하고 있습니다. 히로쿠를 사용하면 회사나 개발자는 딱 **어플리케이션**만 만들어내면 됩니다. 거짓말 조금 보태서 어디서 어떻게 관리하고 배포할 지 일절 고민할 필요가 없습니다. 어플리케이션을 만들고 Heroku에 있는 [[Git]] 서버에 푸쉬하기만 하면 어플리케이션을 자동으로 빌드하고 연결한 도메인으로 배포해줍니다. 이건 그저 감탄만 나올 정도로 너무 훌륭합니다만(!) 같은 크기에 있어서 IaaS 서비스보다 PaaS가 일반적으로 더 비싼 편이기 때문에 가격 정책이나 여러가지를 고려해서 맞는 서비스를 이용한 게 현명한 일입니다.

[rails]: http://rubyonrails.org/

네, 본 주제로 돌아가죠. 다시 도쿠입니다. 도쿠는 바로 Docker라는 가상화 기술을 활용해 이러한 PaaS를 직접 구축하게 도와주는 절대로 **크지 않은** 어플리케이션입니다. 절대로 많은 것을 요구하지도 않고 어렵지도 않습니다. 도커에 대해서 조금 아시면 좋고, 우분투를 사용하고 계신다면 당장 사용해볼 수 있습니다.

## 도쿠 설치하기 ##

당연한 이야기입니다. 도쿠를 사용하기 위해서는 먼저 설치를 해야합니다. Dokku는 현재 [[우분투|ubuntu]] 12나 13.04를 사용할 것을 권장하고 있습니다. 우분투 13.10에서도 사용한 바 정상적으로 사용이 가능했습니다만 몇 가지 이슈가 있어서 13.10에서 사용하는 것은 권장하지 않고 있는 상황입니다.[^2][^3] 먼저 Docker는 설치가 되어있다고 가정하겠습니다. 아직 설치가 되어있지 않다면 [도커(Docker) 튜토리얼 : 깐 김에 배포까지][docker-1]나 도커 공식 홈페이지를 참조해 설치해주시기 바랍니다.

하나 주의해야하는 점은 도쿠 서버는 어디까지나 배포 서버입니다. 불가능한 건 아니지만, 가능하면 개발 서버와 분리된 환경이나 서버가 따로 없다면 가상 머신 상에서 테스트 해보기를 권장합니다. 또한 도메인 설정이 되어있어야 정상적으로 사용가능합니다(없이도 테스트나 사용은 가능합니다만 권장하지 않습니다). 자세한 내용은 각 설정에 대해서 얘기하는 부분에서 자세히 다룹니다.

[^2]: https://github.com/dotcloud/docker/issues/1300
[^3]: https://github.com/dotcloud/docker/issues/1906

바로 도쿠를 설치하겠습니다. 도쿠 역시 원큐에 설치가능한 쉘스크립트를 제공하고 있습니다. 

```
$ wget -qO- https://raw.github.com/progrium/dokku/v0.2.1/bootstrap.sh | sudo DOKKU_TAG=v0.2.1 bash
```

현재 최신 안정 버진인 `0.2.1`을 설치합니다. 도쿠 공식 문서에 따르면 우분투 12.04에서는 `python-software-properties` 패키지가 필요할 지도 모른다고 이야기하고 있습니다. 아래와 같은 메시지가 뜨면서 설치가 실패하는 경우가 있습니다.

```
/var/lib/dokku/plugins/nginx-vhosts/install: line 5: add-apt-repository: command not found
make: *** [plugins] Error 127
```

이때는 `apt-get install python-software-properties`를 실행시켜 필요한 패키지를 설치해주세요.

설치가 끝났으면 제대로 설치가 되었는지 확인해봅니다.

```
...
Almost done! For next steps on configuration:                                                                                       https://github.com/progrium/dokku#configuring

$ dokku version
v0.2.1
```

버전이 제대로 출력되는 걸 보니 정상적으로 설치가 끝났습니다. 이제 간단한 설정을 해줄 필요가 있습니다.

### 도메인 설정 ###

도커는 기본적으로 배포환경이기 때문에 도메인을 지정해줄 필요가 있습니다. 도커를 설치하면 자동적으로 `dokku` 유저가 시스템에 추가되고, `/home/dokku` 디렉토리에서 현재 배포중인 앱과 설정에 관련된 파일들을 확인할 수 있습니다. 먼저 여기에 `VHOST`라는 파일을 추가하고 자신이 사용할 도메인을 지정해줍니다. 예를 들어서 `<APP_NAME>.nacyot.com`을 도메인으로 사용하고자 한다면 `/home/dokku/VHOST` 파일에 다음과 같이 추가해줍니다(파일이 없으면 루트나 dokku 권한으로 직접 생성해주세요).

```
nacyot.com
```

뒤에서 좀 더 이야기하겠습니다만, 여기서 도메인을 설정하게 되면 따로 아무런 설정을 하지 않더라도앱 배포시 앱의 이름을 활용해 서브도메인으로 곧장 배포가 됩니다. 당연하지만 이를 위해서는 일반적으로 도메인을 사용하는 것과 마찬가지로 DNS 서버에 `A Record`를 추가해야합니다. 예를 들어 `nacyot.com` 아래의 모든 도메인을 도쿠로 배포하는 어플리케이션의 서브 도메인을 사용하도록 하려면 `*.nacyot.com`을 `<Dokku_IP_APPRESS>` 도쿠 서버의 아이피 주소를 가리키도록 설정하시면 됩니다. 이 때 도메인이 없는 경우에는 VHOST 파일을 삭제해주시기바랍니다. 이렇게하면 랜덤하게 생성된(사실은 49000번대에서 순차적으로 생성되는) 포트에 앱이 자동으로 연결됩니다. 하지만 이 포트는 앱을 생성할 때마다 유동적으로 변하므로 미리 DNS 서버를 설정해놓고 도메인을 사용하는 게 좋습니다.

### Git Server 설정 ###

앞어서 히로쿠를 간단히 소개하면서 히로쿠의 Git 서버에 푸쉬만 하면 어플리케이션을 자동으로 빌드하고 배포해준다는 이야기를 했습니다. 도쿠도 마찬가지 방식을 사용합니다. 따라서 Push를 보내는 쪽이 적절한 권한을 가지고 있는지 인증 절차를 거칠 필요가 있습니다. 도쿠 README 파일에서는 아래의 명령어를 실행시키라고 이야기하고 있습니다.

```
$ cat ~/.ssh/id_rsa.pub | ssh progriumapp.com "sudo sshcommand acl-add dokku progrium"
```

잠깐! 이 명령어를 실행시키기 전에 약간의 이해가 필요합니다. 도쿠는 어디까지나 배포서버라는 것을 전제로 하고 있습니다. 즉, 도쿠는 어디까지나 개발서버 머나먼 어딘가에서 어플리케이션을 실제로 배포해주는 배포서버입니다. 그리고 어플리케이션을 개발하고 배포하려는 사람(머신)은 다른 곳에 있습니다. 이 명령어는 도쿠 서버에서 사용하는 명령어가 아니라 개발 서버에서 ssh를 통해 Git 저장소를 접근할 수 있도록 권한 설정을 해주는 명령어입니다. 즉 이 명령어는 개발 서버에 있는 ssh 공개키를 도쿠 서버에 넘겨서 접근 권한을 줍니다. 위 명령어를 좀 더 정확히 표현하자면 아래와 같습니다.

```
$ cat ~/.ssh/id_rsa.pub | ssh <아이디>@<서버_아이피_주소_혹은_도메인> "sudo sshcommand acl-add dokku progrium"
```

꺽쇠 안의 부분을 도쿠 서버에 맞게 적당히 바꿔주시고 개발 서버에서 이 명령어를 실행해야합니다. 또한 이 때 root 계정이나 root에 준하는 권한을 가진 권한을 사용한다면 바로 실행이 되겠지만 sudo를 실행시 비밀번호를 묻는 경우 이 명령어가 정상적으로 처리되지 않습니다. 정 실행이 어려운 경우엔 도쿠 서버에서 직접 공개키를 `echo`해서 실행하셔도 무방합니다. 실패하는 경우 `failed`라는 메시지가 뜨며 권한 등록에 성공하면 콜론으로 구분된 문자열이 출력됩니다.

제대로 등록됐는지 확인하기 위해 개발 서버에서 테스트로 접근해보겠습니다.

```
$ ssh dokku@<도쿠_서버_아이피_혹은_도메인>
```

이 때 연결이 끊어졌다는 메시지가 나오면 정상이고, dokku 계정의 패스워드를 물어본다면 제대로 등록이 안 된 상황입니다. ssh 키나 등록 부분에 문제가 없는지 확인해볼 필요가 있습니다. 특히 얼마 전까지만 해도 계정을 git을 사용했었고, ssh 등록 명령어도 `gitreceive upload-key dokku`를 사용했었기 때문에 예전 문서를 참조했는지도 확인이 필요합니다.

고생하셨습니다. 자 이제 설치가 끝났으니 본격적으로 도쿠의 세계로 출발해보죠.

## 첫 어플리케이션 배포 ##

이제 끝나갑니다. 여기서는 도쿠의 [[README]] 문서를 따라 샘플 어플리케이션을 배포해보도록 하겠습니다. 샘플 어플리케이션으로는 히로쿠에서 제공하는 `node-js-sample`을 사용합니다. 참고로(!) 이 작업들은 개발 머신에서 진행합니다. 

```
$ git clone https://github.com/heroku/node-js-sample.git
```

먼저 git 저장소에서 어플리케이션을 클론합니다. 이제 `node-js-sample` 폴더로 이동해 원격 저장소로 도쿠 서버를 등록하고 푸쉬해줍니다.

```
$ cd node-js-sample
$ git remote add dokku dokku@<도쿠_서버_주소>:<앱_이름>
$ git push dokku master
Counting objects: 313, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (270/270), done.
Writing objects: 100% (313/313), 200.76 KiB | 0 bytes/s, done.
Total 313 (delta 15), reused 313 (delta 15)
----> Building node-sample ...
```

`도쿠 서버 주소`는 실제 도쿠 서버의 주소를 아이피나 도메인으로 지정하면 되고, 앱 이름은 원하는 이름을 사용하면 됩니다. 이 때 앱 이름이 곧 서브 도메인 이름이 됩니다. 예를 들어 `node-sample`으로 이름을 지정하면 도메인은 `VHOST`에서 설정한 메인 도메인과 연결되어 `node-sample.nacyot.com`이 됩니다. 자동으로 빌드가 진행됩니다.

```
...
-----> Building runtime environment
-----> Discovering process types
Procfile declares types -> web
-----> Releasing node-sample ...
-----> Deploying node-sample ...
-----> Cleaning up ...
=====> Application deployed:
http://node-sample.nacyot.com
To dokku@<...>:node-sample
* [new branch]      master -> master
$
```

1분 여 남짓 기다리면, 자 이제 빌드가 끝났습니다. 배포도 끝났습니다. DNS 설정이 이미 적용 되어있다면 배포 즉시 `node-sample.nacyot.com` 도메인으로 접속해 어플리케이션을 확인해볼 수 있습니다. 정상적으로 배포가 되었다면 `Hello, world`라는 문자열이 여러분을 반길 것입니다.

빌드도 알아서 해주고, 서버 설정도 알아서 해줍니다. 훌륭한 PaaS 시스템이라고 할 수 있습니다. 여러분은 그저 어플리케이션만 만들고 Push해주면 됩니다. 끝입니다.

어플리케이션은 여러분이 만들어야 하는 부분이니,

헐... 더 할 얘기가 없네요. 너무 간단하죠?

## [빌드스텝][buildstep](Buildstep) ##

[buildstep]: https://github.com/progrium/buildstep

히로쿠를 써보신 분들이라면 눈치 까셨겠지만 빌드 과정에서 나오는 메시지들이 히로쿠에서 어플리케이션을 푸시할 때 나오는 메시지들과 매우 닮아있습니다. 실제로 도쿠 어플리케이션을 빌드하는 방법은 히로쿠에서 제공하는 빌드팩이라는 오픈소스를 통해서 이루어집니다. 사실 도쿠가 어떻게 도커를 사용하고 [[빌드팩|buildpack]]을 사용하는지 이렇게 봐서는 이해가 어려울지도 모릅니다.

도쿠는 분명 도커 기반으로 작동합니다. 하지만 이번 글에서는 아직 도커에 관련된 부분이 아직 나오지 않았습니다. 이제 도커가 나설 차례입니다. 도쿠를 설치하면 도커에서는 어떤일이 일어났을까요. 도쿠를 설치한 상태에서(위의 과정을 따라오셨다면, 설치가 되어있겠죠) 도커의 이미지를 확인해보겠습니다. 도쿠 서버에서 아래 명령어를 실행시켜주세요.

```
$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
progrium/buildstep   latest              107a86e32874        6 hours ago         1.42 GB
ubuntu               quantal             426130da57f7        3 days ago          127.9 MB
centos               6.4                 539c0211cd76        10 months ago       300.6 MB
```

`progrium/buildstep`이라는 이미지가 하나 추가된 것을 알 수 있습니다. 위 예제의 이미지는 커스터마이징이 되어있어서 아마 출력되는 용량은 더 작을 것입니다. 이 빌드스텝이라는 이미지가 도쿠 시스템의 하이라이트입니다. 빌드스탭은 어플리케이션이 빌드가 될 베이스가 되는 이미지입니다. 즉 위의 `node-js-sample`에서 푸시를 하게 되면 실제로 일어나는 일은 이 `buildstep`이라는 이미지를 바탕으로 푸시된 어플리케션을 빌드해서 새로운 이미지를 생성하는 일입니다.

따라서 실제로 어플리케이션을 푸쉬한 다음에 이미지들을 확인해보면 다음과 같습니다.

```
$ docker imaegs
REPOSITORY           TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
app/node-sample      latest              4d88b88215cc        11 minutes ago      1.582 GB
progrium/buildstep   latest              107a86e32874        6 hours ago         1.42 GB
ubuntu               quantal             426130da57f7        3 days ago          127.9 MB
centos               6.4                 539c0211cd76        10 months ago       300.6 MB
```

보시면 아시겠지만 `app/node-sample`이라는 새로운 이미지가 추가된 것을 확인할 수 있습니다. 추정컨테 마치 `progrium/buildstep` 이미지에서 뭔가가 추가된 것 같이 용량도 별반 다르지 않습니다. 그런데 이것만으로는 정말론 `app/node-sample`의 부모 이미지가 `progrium/buildstep`인지 확인할 수 없습니다. 따라서 `history` 명령을 통해서 `app/node-sample`의 이력을 조회해보겠습니다.

```
$ docker history app/node-sample
IMAGE               CREATED             CREATED BY                                   SIZE
4d88b88215cc        18 minutes ago      /build/builder                               162.4 MB
30848b99f896        19 minutes ago      /bin/bash -c mkdir -p /app && tar -xC /app   1.976 kB
107a86e32874        6 hours ago         /bin/bash                                    517.1 MB
b1c426dee3ff        29 hours ago                                                     875.5 MB
```

아래에서부터 이력을 쫓아보면 아시겠지만 `107a86e32874(progrium/buildstep)`에서 `4d88b88215cc(app/node-sample)`이 파생된 것을 확인할 수 있습니다. 네, 이로써 `buildstep`이 도쿠를 통한 어플리케이션에 있어서 모든 근원이라는 것을 확인했습니다. 이쯤되면 `buildstep`이 도대체 뭔가 하는 궁금증이 생기게 마련입니다. 그렇다면 빌드스텝 안을 까보도록 하겠습니다.

```
$ docker run -rm -i -t progrium/buildstep:latest /bin/bash
root@3a6b0a823acb:/# ls
boot   cache  etc   home  lib64  mnt  proc  run   selinux  tmp  var
bin  build  dev    exec  lib   media  opt  root  sbin  srv      sys    usr
root@3a6b0a823acb:/# cd build
root@3a6b0a823acb:/build# ls
builder  buildpacks  buildpacks.txt  packages.txt  prepare
root@3a6b0a823acb:/build# 
```

빌드스탭 이미지에 쉘을 띄웁니다. 안에는 일반적인 [[리눅스|linux]] 시스템에서는 보기 힘든 build라는 디렉토리가 있습니다. 들어가 봅니다. 들어가 보니 build와 관련된 파일들이 나옵니다. buildpakcs 디렉토리에 들어가보면 다음과 같은 디렉토리들이 있습니다.

```
root@3a6b0a823acb:/build/buildpacks# ls -al
total 64
drwxr-xr-x 16 root root 4096 Jan 29 07:16 .
drwxr-xr-x  3 root root 4096 Jan 29 06:18 ..
drwxr-xr-x  5 root root 4096 Dec  3 18:35 buildpack-nginx
drwxr-xr-x  5 root root 4096 Dec  3 18:35 heroku-buildpack-clojure
drwxr-xr-x  5 root root 4096 Dec  3 18:35 heroku-buildpack-dart
drwxr-xr-x  8 root root 4096 Dec  3 18:35 heroku-buildpack-go
drwxr-xr-x  6 root root 4096 Dec  3 18:35 heroku-buildpack-java
drwxr-xr-x  7 root root 4096 Dec  3 18:35 heroku-buildpack-meteorite
drwxr-xr-x  7 root root 4096 Dec  3 18:35 heroku-buildpack-nodejs
drwxr-xr-x  4 root root 4096 Dec  3 18:35 heroku-buildpack-perl
drwxr-xr-x  7 root root 4096 Dec  3 18:35 heroku-buildpack-php
drwxr-xr-x  6 root root 4096 Dec  3 18:35 heroku-buildpack-play
drwxr-xr-x  6 root root 4096 Dec  3 18:35 heroku-buildpack-python
drwxr-xr-x  9 root root 4096 Jan 29 07:16 heroku-buildpack-ruby
drwxr-xr-x  6 root root 4096 Dec  3 18:35 heroku-buildpack-scala
drwxr-xr-x  5 root root 4096 Dec  3 18:35 heroku-buildpack-static-apache
```

오, 뭔가 노다지를 찾은 기분입니다. heroku-buildpack 들이 우글우글대고 있습니다. 실제 빌드스텝이 어떻게 구성되어 있는지는 [빌드스텝 저장소][buildstep-repo]를 참조해보시면 도움이 되실 거라고 생각합니다. 정말 단순합니다. 여기는 어플리케이션 빌드가 가능하도록 각 언어별 heroku-buildpack들을 clone해두었다고 보시면 됩니다.

[buildstep-repo]: https://github.com/progrium/buildstep

눈치채셨을 지도 모르겠지만, 빌드스탭 이미지 역시 커스터마이징이 가능합니다. 도쿠에서 빌드스탭이미지를 기반으로 빌드를 할 때는 단순히 `progrium/buildstep:latest`라는 이름을 가진 이미지를 기반으로 빌드를 합니다. 물론 기본적으로 내부에 위에서 간략히 보여드린 빌드팩들이 포함되어있어야하겠습니다만, 어쨌거나 원한다면 이미지를 수정하거나 필요한 패키지들을 더 집어넣을 수도 있습니다. 이미지 이름만 같으면 됩니다. 별도의 글에서 다룰 예정입니다만, 저 같은 경우는 [heroku-buildpack-ruby][buildpack-ruby]를 간단히 커스터마이징해서 쓰고 있고 그래서 이미지 안의 heroku-buildpack-ruby만 제 저장소에 있는 걸 클론해서 쓰고 있습니다. 위의 `ls` 출력 결과를 보시면 [[ruby]]만 수정 날짜가 다른 걸 알 수 있습니다.

[heroku-buildpack-ruby]: https://github.com/heroku/heroku-buildpack-ruby

## 도커 컨테이너와 도메인 연결 ##

즉 도쿠 서버에 푸시를 해서 실제로 일어나는 일이란, 이 빌드스텝이라는 이미지를 기반으로, `/build` 폴더에 있는 히로쿠 빌드팩을 통해 어플리케이션을 빌드하고, 어라.

한 가지가 빠졌네요. 도메인을 연결시켜줍니다. 이 일은 어떻게 일어나는 걸까요? 이제 `buildstep` 이미지를 빠져나와 `dokku` 홈으로 이동해보겠습니다.

```
$ cd /home/dokku
$ ls -l
total 24
-rw-r--r-- 1 dokku root    13 Jan 29 11:31 dokkurc.log
-rw-r--r-- 1 dokku root    58 Jan 28 17:38 HOSTNAME
drwxr-xr-x 8 dokku dokku 4096 Jan 29 22:20 node-sample
-rw-r--r-- 1 root  root    19 Jan 29 17:08 VHOST

$ cd node-sample
$ ls -l
total 52
drwxr-xr-x 2 dokku dokku 4096 Jan 29 22:19 branches
drwxr-xr-x 2 dokku dokku 4096 Jan 29 22:19 cache
-rw-r--r-- 1 dokku dokku   66 Jan 29 22:19 config
-rw-r--r-- 1 dokku dokku   65 Jan 29 22:20 CONTAINER
-rw-r--r-- 1 dokku dokku   73 Jan 29 22:19 description
-rw-r--r-- 1 dokku dokku   23 Jan 29 22:19 HEAD
drwxr-xr-x 2 dokku dokku 4096 Jan 29 22:19 hooks
drwxr-xr-x 2 dokku dokku 4096 Jan 29 22:19 info
-rw-r--r-- 1 dokku dokku  530 Jan 29 22:20 nginx.conf
drwxr-xr-x 4 dokku dokku 4096 Jan 29 22:19 objects
-rw-r--r-- 1 dokku dokku    6 Jan 29 22:20 PORT
drwxr-xr-x 4 dokku dokku 4096 Jan 29 22:19 refs
-rw-r--r-- 1 dokku dokku   38 Jan 29 22:20 URL
```

앞어서도 어렴풋이 이야기 했습니다만, dokku 계정은 사실 git 원격 저장소를 관리하기 위한 계정입니다. 그리고 그 아래에 있는 디렉토리들은 실제로 하나하나 git 저장소가 됩니다. `node-sample` 역시 git 저장소이자 도커 이미지를 생성하기 위한 설정들이 저장 되어있는 디렉토리입니다. 마술은 `git`의 `hook`를 사용해서 일어납니다. `git`은 특정한 이벤트가 발생할 때 특정한 명령어를 실행시킬 수 있는 `hook`라는 특수한 기능을 지원합니다. `hooks` 디렉토리에 들어가보면 `pre-receive` 후크가 활성화되어있는 것을 알 수 있습니다.

```
$ cd hooks
$ cat pre-receive
#!/usr/bin/env bash
set -e; set -o pipefail;
cat | DOKKU_ROOT="/home/dokku" dokku git-hook node-sample
```

내용은 매우 간단합니다. `node-sample` 어플리케이션에 대해 `dokku` 명령어에 `git-hook`라는 플러그인 명령을 실행시키고 있습니다. 이렇게 보면 이 명령어의 정체가 잘 안 보이니 `git-hook`도 실제로 살펴 보겠습니다. `git-hook` 플러그인의 내용은 아래 `/var/lib/dokku/plugins/git/commands`에서 확인할 수 있습니다.

```sh
#!/usr/bin/env bash
set -eo pipefail; [[ $DOKKU_TRACE ]] && set -x

case "$1" in
  git-hook)
    APP=$2

    while read oldrev newrev refname
    do
      # Only run this script for the master branch. You can remove this
      # if block if you wish to run it for others as well.
      if [[ $refname = "refs/heads/master" ]] ; then
        git archive $newrev | dokku receive $APP | sed -u "s/^/"$'\e'"/"
      fi

    done
    ;;

...
```

여기서는 `git-hook` 명령어만 살펴보겠습니다. 여기서 git 브랜치가 master일 때 다시 `dokku` 명령어를 통해서 `receive` 명령을 실행시키는 걸 알 수 있습니다. `dokku receive` 명령어는 [dokku 메인 스크립트][dokku]에 정의되어 있습니다.

[dokku]: https://github.com/progrium/dokku/blob/master/dokku

```sh
case "$1" in
  receive)
    APP="$2"; IMAGE="app/$APP"
    echo "-----> Cleaning up ..."
    dokku cleanup
    echo "-----> Building $APP ..."
    cat | dokku build $APP
    echo "-----> Releasing $APP ..."
    dokku release $APP
    echo "-----> Deploying $APP ..."
    dokku deploy $APP
    echo "=====> Application deployed:"
    echo " $(dokku url $APP)"
    echo
    ;;
```

여기서 다시 `build`, `release`, `deploy` 명령을 실행합니다. 자세한 사항은 전체 스크립트에서 확인할 수 있으며, 여기서는 `deploy` 부분만 간략히 살펴보겠습니다.

```
  deploy)
    APP="$2"; IMAGE="app/$APP"
    pluginhook pre-deploy $APP

    # kill the app when running
    if [[ -f "$DOKKU_ROOT/$APP/CONTAINER" ]]; then
oldid=$(< "$DOKKU_ROOT/$APP/CONTAINER")
      docker kill $oldid > /dev/null 2>&1 || true
fi

    # start the app
    DOCKER_ARGS=$(: | pluginhook docker-args $APP)
    id=$(docker run -d -p 5000 -e PORT=5000 $DOCKER_ARGS $IMAGE /bin/bash -c "/start web")
    echo $id > "$DOKKU_ROOT/$APP/CONTAINER"
    port=$(docker port $id 5000 | sed 's/0.0.0.0://')
    echo $port > "$DOKKU_ROOT/$APP/PORT"
    echo "http://$(< "$DOKKU_ROOT/HOSTNAME"):$port" > "$DOKKU_ROOT/$APP/URL"

    pluginhook post-deploy $APP $port
    ;;
```

`deploy` 부분에서는 빌드된 이미지로부터 docker container를 실행시킵니다. 특히 마지막 부분에서는 `post-deploy pluginhook`를 실행시킵니다. 이는 `/var/lib/dokku/plugins/nginx-vhosts/post-deploy`에 정의되어 있는 부분으로 저장소 폴더에 앱 설정에 맞춰 `nginx.conf`를 생성하고 이 설정이 적용되도록 nginx 서비스를 재실행합니다. 앞서 배포한 어플리케이션의 `/home/dokku/node-sample/nginx.conf`는 다음과 같습니다.

```
upstream node-sample { server 127.0.0.1:49175; }
server {
  listen      80;
  server_name node-sample.nacyot.com;
  location    / {
    proxy_pass  http://node-sample;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header X-Request-Start $msec;
  }
}
```

자세히 보면 이는 `node-sample.nacyot.com`으로 들어온 요청을 받았을 때 `127.0.0.1:49175`로 프록시를 보내주는 설정입니다. 배포된 어플리케이션이 어느 포트로 실행되고 있는지는 실행중인 컨테이너 목록에서 확인할 수 있습니다.

```
$ docker ps
CONTAINER ID        IMAGE                       COMMAND                CREATED             STATUS              PORTS                     NAMES
bc259b925113        app/node-sample:latest      /bin/bash -c /start    2 hours ago         Up 2 hours          0.0.0.0:49175->5000/tcp   ecstatic_fermi
```

포트 부분을 보게 되면 `localhost:49175` 요청에 대해서 `node-sample` 컨테이너의 5000번 포트로 포트포워딩이 이뤄지는 것을 알 수 있습니다. 즉 위에서 살펴본 `nginx.conf` 파일을 통해서 `node-sample.nacyot.com`으로 요청을 받으면 `node-sample` 컨테이너의 5000번 포트에서 돌아가고 있는 어플리케이션으로 요청이 전달되는 것을 알 수 있습니다.

그런데 `/home/dokku` 아래의 `nginx.conf` 설정이 어떤 원리로 적용이 되는 걸까요? 이 수수께끼는 도쿠 설치시에 추가되는 `/etc/nginx/conf.d/dokku.conf` 파일을 보면 풀립니다.

```
include /home/dokku/*/nginx.conf;
```

정말 단순하네요.

이로써 `git push`를 하면 일어나는 마술을 정말 간략히만 파헤쳐봤습니다.

다시 한 번 정리하자면 도쿠 서버에 푸시를 해서 실제로 일어나는 일이란, 이 빌드스텝(buildstep이라는 이미지를 기반으로, `/build` 폴더에 있는 히로쿠 빌드팩을 통해 어플리케이션을 빌드하고, [[nginx]] 설정 파일을 동적으로 만들고 재실행해서 원하는 도메인으로 서비스를 연결시켜주는 일입니다. 

## 정리 ##

지금까지 도쿠를 통해 샘플 어플리케이션을 배포해보고, 배포가 어떻게 이루어지는 지 간략하게 살펴보았습니다. 이제 도쿠가 어떻게 돌아가는지 감이 좀 잡히시나요? 실제 서비스 운용을 위한 용도는 아닙니다만, 도커와 도쿠를 개인 서버는 물론 [[KT cloud|kt_ucloud]]와 SKT T developes VM, [[Amazon EC2|aws_ec2]] 마이크로 인스턴스에도 올려봤습니다만 신기할 정도로 잘 돌아갑니다. 이렇게 쉽게(?) 내 손 안에 히로쿠가 올라오다니 신기할 따름입니다.

이번에는 도쿠의 원리를 가볍게 보여드리고자 샘플 어플리케이션을 배포해보았습니다만, (언제가 될 지 기약은 없습니다만) 다음 글에서는 레일즈4 어플리케이션을 도쿠를 통해 배포하면서 데이터베이스를 연동하고 빌드 과정에서 생길 수 있는 문제와 이를 해결하기 위해 buildstep과 buildpack을 간단히 커스터마이징 해보겠습니다.
