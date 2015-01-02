---
title: 루비 젬(pg, mysql2, sqlite, curb, imagemagick, capybara)을 설치를 시스템 패키지(Site Package)
author: nacyot
date: 2014-08-12 00:15:03 +0900
tags: 
published: false
---

여느 프로그래밍 언어와 마찬가지로 루비를 사용하면서도 정말 빠지기 쉽고, 빠질 수밖에 없는 함정이 Gem을 통한 라이브러리 설치 과정에서 생기는 문제입니다. 대부분은 패키지 설치 과정의 빌드 과정에서 일어나는 문제입니다. 에러 메시지를 좀 더 자세히 보고, 시스템 환경을 다시 갖추는 등, 좀 더 섬세한 문제 해결도 가능합니다만, 대부분은 `apt-get`(혹은 `brew` 명령어)를 통해 해당 Gem(라이브러리)이 의존성을 가진 시스템 패키지(Site Package라고도 합니다)를 설치하는 것만으로도 해결이 가능합니다. 이 글에서는 반드시 한 번은 이런 문제로 고생을 시키는 젬들을 설치하는 법을 다룹니다.

## rbenv(루비 빌드)

Gem을 다루기에 앞서 루비 빌드에 필요한 패키지들을 정리해봅니다. 여기서는 최근에 많이 사용되는 조합인 rbenv + ruby-build 플러그인을 사용해 루비를 빌드해봅니다.

```
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ bash
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
$ rbenv install 2.1.2
Downloading ruby-2.1.2.tar.gz...
-> http://dqw8nmjcqpjn7.cloudfront.net/f22a6447811a81f3c808d1c2a5ce3b5f5f0955c68c9a749182feb425589e6635
Installing ruby-2.1.2...

BUILD FAILED

Inspect or clean up the working tree at /tmp/ruby-build.20140811151005.17457
Results logged to /tmp/ruby-build.20140811151005.17457.log
```

실패합니다. 루비를 빌드하기 위해서는 빌드 툴들과 libreadline, libssl 등의 라이브러리가 시스템에 설치되어 있어야합니다. 아래 명령어로 패키지들을 설치하고 다시 빌드해봅니다.

```
$ apt-get install -y build-essential autoconf libpq-dev zlib1g-dev libssl-dev libreadline-dev
$ rbenv install 2.1.2

```

루비가 정상적으로 설치되었는 지 확인해봅니다.

```
$ rbenv global 2.1.2
$ ruby --version
```


## sqlite3

가벼워서 로컬에서 자주 사용되는 파일 기반 데이터 sqlite3 데이터베이스 인터페이스 라이브러리입니다. 특히 레일스 개발환경의 기본 데이터베이스로 자주 사용하게 됩니다.

보통 rails 프로젝트를 초기화하고 `bundle install`하거나 직접 sqlite3를 설치하려고 할 때 아래와 같이 실패하곤 합니다.

```
$ gem install sqlite3
Fetching: sqlite3-1.3.9.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing sqlite3:
ERROR: Failed to build gem native extension.
```

이 때는 libsqlite3-dev를 설치해줍니다.

```
$ sudo apt-get install libsqlite3-dev
Building native extensions.  This could take a while...
Successfully installed sqlite3-1.3.9
...
```


## mysql2

다음은 아마 데이터베이스 인터페이스로 가장 많이 사용될 mysql2 라이브러리입니다.

```
$ gem install mysql2
gem install mysql2
Fetching: mysql2-0.3.16.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing mysql2:
ERROR: Failed to build gem native extension.
...
```

sqlite3와 비슷한 문제가 발생하는 것을 알 수 있습니다. 이 문제를 해결하기 위해서는 `libmysqlclient-dev` 패키지가 필요합니다.

```
$ sudo apt-get install libmysqlclient-dev
$ gem install mysql2
Building native extensions.  This could take a while...
Successfully installed mysql2-0.3.16
...
```

이제 정상적으로 설치되는 것을 알 수 있습니다.

다른 플랫폼에서는 아래 패키지를 시도해보시기 바랍니다.

```
# centos
$ yum -y install gcc mysql-devel
```

## pg

다음은 mysql의 대체 데이터베이스로 자주 사용되는 postgresql의 루비 인터페이스 라이브러리인 pg입니다. pg를 설치하려고 시도하면, 아래와 같은 에러를 만나게 되는 경우가 있습니다.

```
$ gem install pg
Fetching: pg-0.17.1.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing pg:
ERROR: Failed to build gem native extension.
...
```

이 때는 libpq-dev 패키지를 설치해줍니다.

```
$ sudo apt-get install libpq-dev
$ gem install pg
Building native extensions.  This could take a while...
Successfully installed pg-0.17.1
...
```

## Nokogiri

루비를 사용하다보면 여기저기서 만나게 되는 라이브러리 중의 하나가 Nokogiri 입니다. Nokogiri 역시 설치가 실패하는 경우가 많습니다.

```
$ gem install nokogiri
Fetching: mini_portile-0.6.0.gem (100%)
Successfully installed mini_portile-0.6.0
Fetching: nokogiri-1.6.3.1.gem (100%)
...
Done installing documentation for mini_portile, nokogiri after 2 seconds
2 gems installed
```

음... 문제 없이 설치가 되네요. 설치 과정을 좀 더 자세히보면 아래와 같이 나오는 것을 알 수 있습니다.

```
IMPORTANT!  Nokogiri builds and uses a packaged version of libxml2.
...
For example, libxml2-2.9.0 and higher are currently known to be broken
and thus unsupported by nokogiri, due to compatibility problems and
XPath optimization bugs.
...
IMPORTANT!  Nokogiri builds and uses a packaged version of libxslt.
...
gem install nokogiri -- --use-system-libraries
```

호환성 문제 및 설치 문제를 해결하기 위해 libxml2와 libxslt를 아예 내장한 것으로 보입니다.

```
$ sudo apt-get install libxslt-dev libxml2-dev
```


문제없이 설치되는 것을 알 수 있습니다.

## Nodejs(Javascript Runtime)

```
$ sudo apt-get install nodejs
```



## curb

```
$ sudo apt-get install libcurl4-openssl-dev libcurl4-gnutls-dev
```

## imagemagick

```
$ sudo apt-get install libmagickwand-dev
```

```
$ yum install ImageMagick-devel
```

```
$ brew install imagemagick
```

## capybara-webkit

```
$ sudo apt-get install libqt4-dev libqtwebkit-dev
```
