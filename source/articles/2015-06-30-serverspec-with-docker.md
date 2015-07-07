---
title: Serverspec(서버스펙)을 통한 도커 이미지 테스트 자동화
date: 2015-07-07 10:25:00 +0900
author: nacyot
tags: devops, serverspec, rspec, test, infrastructure_as_code, docker, specinfra, guard, dockerfile, programming, infrastructure
categories: programming, infrastructure
title_image: http://i.imgur.com/MyCDEgF.jpg
published: true
---

Immutable Infrastructure와 컨테이너로 대표되는 도커(Docker)와 함께 서버 분야에 많은 변화를 가져온 것은 Configuration Management 도구들이었다. 쉐프(Chef), 퍼펫(Puppet), 앤서블(Ansible)로 대표되는 CM 툴들은 독자적인 DSL을 통해서 서버의 이상적인 상태와 그에 다다르는 과정을 선언적으로 기록한다. 그리고 이 기록을 통해서 원하는 서버의 특정 상태를 재현하게 도와준다. 이러한 흐름을 Infrastructure as Code라고 표현하기도 한다. 서버의 코드화, 여기서 한 단계 더 나아가면 또 다른 흥미로운 아이디어를 만나게된다. 서버가 코드라면 소프트웨어를 검증하는 기법들을 똑같이 적용할 수 있지 않을까?

서버스펙(Serverspec)은 바로 이 질문에 대한 답을 보여주는 도구이다. 이 글에서는 Serverspec을 통해서 도커 이미지를 테스트하는 방법에 대해서 다룬다.

<!--more-->

## 서버스펙(Serverspec)을 통한 도커 이미지 테스트

이제 테스트 환경을 마련하고 실제로 테스트를 작성해보도록하자. 서버스펙에는 기본적으로 프로젝트를 초기화를 돕는 `serverspec-init`이라는 명령어가 포함되어있다. 여기서는 이 명령어를 사용하지 않고 진행한다. 먼저 루비의 기본적인 구조와 비슷하게 spec 디렉터리를 만들고 그 아래에 테스트 코드를 넣을 것이다.

```
./serverspec-with-docker
├── Gemfile
└── spec
    ├── mongodb_image_spec.rb
    └── spec_helper.rb
```

디렉터리 구조는 아주 간단한다. 프로젝트 메인 디렉터리 아래에 spec 디렉터리를 만들고 테스트 설정 파일은 `spec_helper.rb`와 테스트 파일은 `mongodb_image_spec.rb`를 준비한다.

### 도커 이미지 준비

여기서는 시스템에 도커가 설치되어있다고 가정한다(boot2docker도 무방하며, 실제로 이 글의 내용은 boot2docker를 통해서 테스트되었다). 도커를 통해서 nginx 공식 이미지를 다운로드 받는다.

```
$ docker pull nginx:latest
```

### Gemfile을 통한 의존성 관리

Serverspec을 통한 인프라 테스트는 루비를 기반으로 돌아간다(즉, 시스템에 루비가 설치되어있어야한다). 루비를 테스트를 위해 사용할 의존성 관리를 위해 프로젝트 루트에 다음과 같이 Gemfile을 작성한다.

```
source "https://rubygems.org"

`gem "3e,21ec"
gem "docker-api"
```

Gemfile은 프로젝트의 의존성을 관리하고, 프로젝트 내에서 사용될 실행 가능한 명령어들을 관리하기 위해 사용된다. 이제 의존성을 설치해보자.

```
$ bundle install
Fetching gem metadata from https://rubygems.org/.......
Resolving dependencies...
Using diff-lcs 1.2.5
Using excon 0.45.3
...
Using specinfra 2.36.6
Using serverspec 2.19.0
Using bundler 1.7.3
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

설치가 끝났으면 프로젝트 루트 아래에서 rspec 명령어가 작동하는지 테스트해보자.

```
$ bundle exec rspec --version
3.3.1
```

잘 동작한다!

### `spec_helper.rb`

`spec_helper.rb`는 프로젝트에 적용되는 RSpec 설정파일이다. `:host`에는 테스트에 사용할 적절한 도커 서버의 주소를 입력한다. `:docker_image`는 테스트할 대상을 의미하며, `:os`는 테스트 대상이 되는 서버의 운영체제를 의미한다. 서버스펙은 이 옵션을 통해서 테스트에서 사용하는 DSL을 추상화한다. `<USERNAME>`에는 적절한 사용자 이름을 넣어준다. 여기서는 OSX에서 boot2docker를 사용하고 있다고 가정하고 있으며 ssl key가 다른 곳에 있다면 적절한 위치를 지정해준다.

```
require 'serverspec'
require 'docker'

set :backend, 'docker'
set :host, 'https://192.168.59.103:2376'
set :docker_image, 'tutum/mongodb'
set :os, family: :ubuntu

Docker.options = {
  client_cert: '/Users/<USERNAME>/.boot2docker/certs/boot2docker-vm/cert.pem',
  client_key: '/Users/<USERNAME>/.boot2docker/certs/boot2docker-vm/key.pem',
  ssl_ca_file: '/Users/<USERNAME>/.boot2docker/certs/boot2docker-vm/ca.pem',
  scheme: 'https',
  read_timeout: 3600
}

Excon.defaults[:ssl_verify_peer] = false
```

### `mongodb_image_spec.rb`

이 파일에는 테스트 코드를 작성한다. 테스트 코드는 RSpec 고유의 DSL로 작성되며, 서버스펙은 서버를 검증하기 위한 도구들을 제공한다. 아마 루비나 RSpec에 친숙하다면, 이 코드를 보고 어떤 내용인지 바로 알 수 있을 것이며, 안 써봤어도 직관적으로 이해할 수 있을 것이다.

```
require 'spec_helper'

describe 'tutum/mongodb Image' do
  describe file('/etc') do
    it { should be_directory }
  end

  describe process('mongod') do
    it { should be_running }
  end

  describe port(27017) do
    it { should be_listening }
  end
end
```

여기에는 3개의 테스트가 기술되어있다. 서버스펙에서는 리소스라는 개념을 사용해서 테스트를 수행한다. 먼저 첫번째 테스트에서 쓰인 리소스는 `file`이다. 이를 통해서 `/etc`가 디렉터리인지 검증한다. 그 다음으로 두번째 테스트에서는 `process` 리소스를 통해서 `mongod` 프로세스가 실행중인지 검증한다. 마지막으로 `port` 리소스를 통해서 27017 포트가 대기중인지 검증한다. 서버스펙은 서버를 검증하기 위한 다양한 리소스를 제공하고 있으며 더 많은 리소스들에 대해서는 [서버스펙 공식 사이트][serverspec_resources]에서 찾아볼 수 있다.

[serverspec_resources]: http://serverspec.org/resource_types.html

### rspec으로 테스트 실행하기

이제 테스트 코드도 모두 작성했으니, 테스트가 정상적으로 작동하는지 검증하는 일만 남았다. 프로젝트 메인에서 테스트를 실행해보자.

```
$ rspec .
tutum/mongodb IMage
  File "/etc"
    should be directory
  Process "mongod"
    should be running
  Port "27017"
    should be listening

Finished in 6.18 seconds (files took 1.14 seconds to load)
3 examples, 0 failures
```

모든 테스트가 성공했다! 테스트를 통해서 `/etc` 디렉터리가 존재하고, `mongod` 프로세스가 실행되고 있으며, `27017` 포트가 대기중임을 알 수 있다.

## 테스트 주도 인프라스트럭처(Test Driven Infrastructure)

여기까지 서버스펙을 통해서 이미 생성되어져 있는 도커 이미지를 검증하는 방법에 대해서 살펴보았다. 그렇다면 소프트웨어 개발과 마찬가지로 `Dockerfile`을 만드는 과정 전체를 테스트해보는 것은 어떨까?

물론 이것도 가능하다. 여기서는 redis 이미지를 직접 만들어가면서 테스트를 수행해보자.

### 디렉터리 구조

```
./serverspec-with-docker
├── Dockerfile
├── Gemfile
├── Guardfile
└── spec
    ├── nacyot_redis_image_spec.rb
    └── spec_helper.rb
```

### `spec_helper.rb`

먼저 spec_helper.rb은 앞선 예제를 그대로 사용하되, 이미지 부분을 주석처리 한다.

```
# set :docker_image, 'nacyot/redis'
```

### `nacyot_redis_image_spec.rb`

Redis 서버가 정상적으로 작동하는 지 확인하기 위한 테스트를 준비한다. 

```
require 'spec_helper'

describe 'nacyot/redis Image' do
  before(:all) do
    image = Docker::Image.build_from_dir('.');
    set :docker_image, image.id
  end

  describe file('/etc') do
    it { should be_directory }
  end

  describe package('redis-server') do
    it { should be_installed }
  end

  describe file('/usr/local/bin/redis-server') do
    it { should be_executable }
  end

  describe process('redis-server') do
    it { should be_running }
  end

  describe port(6379) do
    it { should be_listening }
  end
end
```

여기서 작성한 테스트들 역시 기본적인 rspec 문법으로 작성되었으며 서버스펙의 리소스들을 사용하고 있다.

주목할만한 부분이 있다. 이전에는 없었던 `before(:all)` 절이 추가되었는데, 이 부분은 테스트를 실행하기에 앞서 한 번 실행된다. 여기서 하는 일은 프로젝트 루트의 `Dockerfile`로부터 도커 이미지를 생성하고, 테스트 대상 이미지를 동적으로 지정하는 일이다(이 때 이미지 이름이 아니라, 빌드로부터 반환되는 이미지 ID를 사용한다). 이를 통해서 별도로 빌드 명령을 수행하지 않아도, 테스트를 수행할 때마다 자동적으로 빌드를 하고 테스트를 수행한다.

### Guard를 통한 자동테스트

이번 프로젝트에서는 Guard를 통해서 Dockerfile과 spec 파일의 변경을 감지하고 테스트할 수 있도록 한다. 이를 위해 Gemfile을 다음과 같이 수정한다.

```
source 'https://rubygems.org'

gem 'serverspec'
gem 'docker-api'
gem 'guard'
gem 'guard-rspec'
```

프로젝트 루트에서 추가한 의존성을 설치해준다.

```
$ bundle
```

그리고 아래와 같이 Guardfile을 작성한다.

```
guard :rspec, cmd: "bundle exec rspec" do
  require 'guard/rspec/dsl'
  watch(Guard::RSpec::Dsl.new(self).rspec.spec_files)
  watch(%r{^Dockerfile$}) { 'spec/nacyot_redis_image_spec.rb' }
end
```

이 Guard 파일의 내용은 spec 디렉터리 아래의 파일이나 dockerfile이 변경되었을 때 테스트를 자동적으로 실행하도록 한다.

이제 별도의 터미널을 실행해서 프로젝트 루트에서 다음 명령어를 실행하면 파일이 변경될 때마다 테스트가 자동적으로 실행된다.

```
# bundle exec guard
09:47:59 - INFO - Guard::RSpec is running
09:47:59 - INFO - Guard is now watching at '/Users/.../docker-with-serverspec'
[1] guard(main)>
```

### 첫번째 이터레이션 : 이미지 생성하기

먼저 빈 Dockerfile을 만들고 베이스 이미지를 지정해준다.

```
FROM ubuntu:14.04
```

Guard에서 이 변화를 알아채고 자동적으로 테스트를 수행할 것이다. 앞서 이야기했듯이 테스트가 실행되면 자동적으로 이미지가 빌드되므로 빌드는 별도로 수행하지 않아도 된다.

```
nacyot/redis Image
  File "/etc"
    should be directory
  Package "redis-server"
    should be installed (FAILED - 1)
  File "/usr/bin/redis-server"
    should be executable (FAILED - 2)
  Process "redis-server"
    should be running (FAILED - 3)
  Port "6379"
    should be listening (FAILED - 4)

Finished in 5.23 seconds (files took 0.30381 seconds to load)
5 examples, 4 failures

Failed examples:

rspec ./spec/nacyot_redis_image_spec.rb:14 # nacyot/redis Image Package "redis-server" should be installed
rspec ./spec/nacyot_redis_image_spec.rb:18 # nacyot/redis Image File "/usr/bin/redis-server" should be executable
rspec ./spec/nacyot_redis_image_spec.rb:22 # nacyot/redis Image Process "redis-server" should be running
rspec ./spec/nacyot_redis_image_spec.rb:26 # nacyot/redis Image Port "6379" should be listening
```

첫번째 테스트만 성공하고, 나머지 테스트가 실패했다! 

### 두번째 이터레이션 : apt-get을 통해서 redis 설치하기

Dockerfile 뒤에 다음 내용을 추가한다.

```
RUN sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list

RUN \
  apt-get update &&\
  apt-get install -y redis-server
```

자동적으로 테스트가 실행된다.

```
nacyot/redis Image
  File "/etc"
    should be directory
  Package "redis-server"
    should be installed
  File "/usr/bin/redis-server"
    should be executable
  Process "redis-server"
    should be running (FAILED - 1)
  Port "6379"
    should be listening (FAILED - 2)

Finished in 7.42 seconds (files took 0.29263 seconds to load)
5 examples, 2 failures

Failed examples:

rspec ./spec/nacyot_redis_image_spec.rb:22 # nacyot/redis Image Process "redis-server" should be running
rspec ./spec/nacyot_redis_image_spec.rb:26 # nacyot/redis Image Port "6379" should be listening
```

redis-server 패키지의 설치를 검증하는 두번째, 세번째 테스트도 통과했다!

### 세번째 이터레이션 : redis 실행하기

Dockerfile 뒤에 다음 내용을 추가해준다.

```
CMD redis-server
```

이번에도 자동적으로 테스트가 실행된다.

```
nacyot/redis Image
  File "/etc"
    should be directory
  Package "redis-server"
    should be installed
  File "/usr/bin/redis-server"
    should be executable
  Process "redis-server"
    should be running
  Port "6379"
    should be listening

Finished in 6.94 seconds (files took 0.29334 seconds to load)
5 examples, 0 failures
```

테스트가 모두 통과했다! 이를 통해 이 이미지로부터 레디스(redis) 서버가 정상적으로 실행되는 것을 보장할 수 있다.

### 테스트 코드

여기서 사용한 프로젝트와 테스트 코드는 [serverspec_tutorial][st_repo]에서 확인할 수 있다.

[st_repo]: https://github.com/nacyot/serverspec_tutorial

## 결론

인프라가 정상적인 상태에 있다는 것을 증명하는 것은 매우 중요한 주제이다. 그럼에도 불구하고 이러한 테스트는 대부분 자동화되어있지 않다. Serverspec은 원래 ssh를 통해서 서버의 상태나 CM 툴과 함께 사용을 목적으로 만들어진 도구이다. 이 훌륭한 도구는 단순히 기존 서버 환경 뿐만 아니라 빌드를 통해 완성된 이미지를 구성하는 도커와 같은 컨테이너 시스템을 테스트하는 데도 적격이다. 이를 통해 소프트웨어 테스트 뿐만 아니라 소프트웨어를 탑재한 이미지가  배포되기 전에 정상적으로 작동하는지, 필요한 파일들을 제대로 포함하고 있는지까지 함께 검증하는 것이 가능하다. 또한 서버가 코드처럼 다뤄질 수 있다면, 테스트 자동화는 물론 저장소와 연동해서 CI를 통해 지속적인 통합 역시 가능해진다.

이제 딱딱해 보이고 하드웨어에 더 가깝게 취급되던 인프라가 이제 정말로 소프트웨어 영역에 좀 더 가까워지고 있다.

## 보충

테스트 과정에서 도커 공식 이미지에서 주로 이용되는 debian 환경에 대해서는 포트 리스닝 테스트가 정상적으로 작동하지 않았다. 아직 일부 환경에서 몇몇 리소스들이 정상적으로 작동하지 않을 가능성이 있다. 다음 글에서는 서버스펙에서 도커 테스트가 어떻게 실행되는 지 살펴본다.
