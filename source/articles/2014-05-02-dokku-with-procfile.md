---
title: "도쿠(Dokku)에서 Procfile 사용하기"
date: Fri May  2 22:29:23 KST 2014
author: nacyot
---

도쿠에서는 기본적으로 Procfile을 지원하고 있습니다. 따라서 어플리케이션 빌드하고 만들어지는 도커(Docker) 이미지의 기본 실행파일은 Procfile의 `web`에 지정된 명령어가 됩니다.

```
web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rbㅏ
```

원래 Procfile은 다중 프로세스를 실행할 수 있도록 설계되어 있습니다만, 이러한 `web` 이외의 모든 명령어는 무시됩니다. 현재 이 Procfile을 통해서 여러 개의 프로세스를 실행시키기 위해서는(즉, 도커의 실행 명령으로 다중 프로세스를 실행하기 위해서는) 별도의 설정이 필요합니다.

<!--more-->

## 도커의 다중 프로세스 실행

도쿠는 도커를 기반으로 하는 배포 시스템입니다. 도쿠에서 제공하는 buildstep이라는 이미지를 기반으로 어플리케이션을 빌드하고 도커 이미지를 생성합니다. 그리고 기본적으로 도커 이미지는 하나의 명령어를 진입점으로 실행이되도록 되어있습니다. 하지만 실제로 어플리케이션을 운용하는 데는 여러개의 프로세스를 필요로 할 때가 있습니다. 이러한 문제를 해결하기 위해서는 하나의 프로세스로 다수의 프로세스를 실행하는 방법을 사용해야합니다. 이러한 도구로는 파이썬(Python)의 슈퍼바이저(supervisor)와 루비(Ruby)의 포레맨(foreman)과 shoreman 등이 있습니다.

* [Supervisor][su]
* [Foreman][fo]
* [Shoreman][sh]

[su]: http://supervisord.org/
[fo]: https://github.com/ddollar/foreman
[sh]: https://github.com/hecticjeff/shoreman

## 도쿠에서 포레맨(foreman) 사용하기

일반적으로 슈퍼바이저는 시스템에서 좀 더 넓은 범위의 프로세스를 동시에 실행시키는 용도로 많이 사용됩니다. 반면에 Foreman은 어플리케이션에 포함된 Procfile을 통해서 어플리케이션에 직접적으로 연관된 프로세스를 실행하는데 사용합니다. 도커를 사용할 때는 용도에 따라서 편한 걸 사용하면됩니다. 단, 도쿠에서 어플리케이션의 기본진입점을 Procfile이 되는 것은 Foreman을 사용하기 때문이라기보단 히로쿠 빌드팩이 기본적으로 Procfile을 사용하기 때문입니다.

, web 명령어만 단일 프로세스로 실행되고 나머지 명령어 들은 무시됩니다.



sidekiq: bundle exec sidekiq -c 1 -e production
