title: Serverspec(서버스펙)을 통한 도커 이미지 테스트

가능하면 서버스펙 이야기를 먼저하면 좋을 것 같습니다만, 이 글에서는 짧게 다루고 넘어가겠습니다. 서버스펙은 '서버'를 루비의 Rspec 확장으로 테스트할 수 있게 도와주는 도구입니다. 기본적으로 ssh를 통해서 이러한 테스트를 수행합니다만, 최근에는 Docker를 백엔드로 사용하는 것도 가능해졌습니다. 이 글에서는 Serverspec의 백엔드로 Docker를 사용해 도커 이미지를 테스트하는 법을 다루고자 합니다.

<!--more-->

## 서버스펙(Serverspec) 설치

먼저 서버스펙을 설치합니다. Serverspec을 사용하려면 먼저 루비가 설치되어있어야 합니다.

```
$ gem install serverspec
Successfully installed serverspec-2.10.1
Parsing documentation for serverspec-2.10.1
Done installing documentation for serverspec after 0 seconds
1 gem installed
```

이를 통해 서버스펙이 설치되었습니다. 서버스펙은 내부적으로 Rspec을 사용하므로 Serverspce을 위한 명령어가 따로 존재하지는 않습니다.

## 서버 테스트 프로젝트 준비하기

단, Serverspec 테스트 프로젝트를 구성하기 위한 `serverspec-init`이라는 명령어가 시스템에 추가됩니다. 이를 사용해서 간단한 시스템 테스트를 만들어 보겠습니다.

```
$ mkdir -p ~/tmp/serverspec
$ cd ~/tmp/serverspec
$ serverspec-init
Select OS type:

1) UN*X
2) Windows

Select number: 1
```

먼저 OS type을 물어봅니다. 여기서는 1을 선택했습니다.

```
Select a backend type:

1) SSH
2) Exec (local)

Select number: 2

+ spec/
+ spec/localhost/
+ spec/localhost/sample_spec.rb
+ spec/spec_helper.rb
+ Rakefile
 + .rspec
 ```

다음으로 backend 타입을 물어봅니다. 별도의 서버를 준비하는 게 귀찮은 관계로 여기서는 2번 Exec(local)을 선택했습니다.

이걸로 Serverspec 프로젝트가 준비되었습니다. 생성되는 파일 목록에서 알 수 있듯이, 서버스펙 프로젝트는 일반적인 루비 프로젝트와 구조가 비슷합니다. `.rspec`은 rspec 실행에 사용될 옵션이 들어가며 spec 디렉터리 아래에 테스트들이 추가됩니다. 또한 일반적인 rspec 구성과 마찬가지로 테스트에서 항상 로드가 되는 테스트 설정 파일인 spec_helper.rb도 존재합니다. 마지막으로 Rakefile에는 테스트 실행을 위한 테스크가 준비되어 있습니다.

마지막으로 `/spec/localhost/sample_spec.rb`에는 아파치 서버를 대상으로 한 간단한 테스트가 포함되어 있습니다.

```
require 'spec_helper'

describe package('httpd'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('httpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
end

describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

describe service('org.apache.httpd'), :if => os[:family] == 'darwin' do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
```

이미 Rspec에 친숙하다면 테스트가 어떻게 구성되는 지 아마 쉽게 알아챌 수 있을 것입니다. Rspec에서 다룰 수 있는 모든 리소스는 서버스펙 사이트의 [Resource Types](http://serverspec.org/resource_types.html)에서 찾아볼 수 있습니다.

## 서버스펙 시작하기

우선 위의 예제 테스트들은 로컬 환경에서는 실패할 것이므로 더 간단한 예제로 바꿔보겠습니다.

```
require 'spec_helper'

describe file('/tmp') do
  it { should be_directory }
end

describe file('/super_awesome_directory') do
  it { should_not be_directory }
end
```

이 예제에서는 시스템에 `/tmp` 디렉터리가 있는 지 여부와 `/super_awesome_directory` 디렉터리가 없는 지 여부를 테스트합니다. 테스트를 실행하려면 프로젝트 루트에서 `rspec`이나 `rake`를 실행하면 가능합니다.

```
$ rspec

File "/tmp"
  should be directory

File "/super_awesome_directory"
  should not be directory

Finished in 0.16006 seconds (files took 0.83904 seconds to load)
2 examples, 0 failures
```

위 결과를 통해 두 테스트 모두 통과한 것을 알 수 있습니다. 그렇다면 시스템 루트에 `/super_awesome_directory`를 만들면 어떻게 될까요? 서버스펙이 정상적으로 작동한다면, 테스트는 실패할 것입니다.


```
$ rspec

File "/tmp"
  should be directory

File "/super_awesome_directory"
  should not be directory (FAILED - 1)

Failures:

  1) File "/super_awesome_directory" should not be directory
    Failure/Error: it { should_not be_directory }
      expected `File "/super_awesome_directory".directory?` to return false, got true
      /bin/sh -c test\ -d\ /super_awesome_directory

    # ./spec/localhost/sample_spec.rb:8:in `block (2 levels) in <top (required)>'

Finished in 0.07035 seconds (files took 0.83333 seconds to load)
2 examples, 1 failure

Failed examples:

rspec ./spec/localhost/sample_spec.rb:8 # File "/super_awesome_directory" should not be directory
```

예상했던 대로 실패했습니다. 서버스펙에서는 이와 같은 형식으로 일반적인 프로그램 테스트 도구들과는 달리, 서버 내의 자원들이 예상한 대로 존재하거나 존재하지 않는지, 동작하고 있는 지를 테스트할 수 있는 기능들을 제공합니다.

## 서버스펙에서 도커 사용하기

앞선 예제에서는 로컬 자원을 테스트했습니다만, 서버스펙의 목적은 외부 서버를 테스트하기 위한 도구로서 기본적으로 ssh를 사용해서 테스트를 수행합니다. 좀 더 구체적으로 설명하자면, 서버스펙은 크게 테스트를 지원하기 위한 서버스펙 본체와 테스트 실행을 다양한 환경에 대해 추상화시켜주는 Specinfra로 구성되어 있습니다. Specinfra는 서버스펙의 테스트를 다양한 환경과 백엔드를 기반으로 실행할 수 있도록 지원합니다. ssh
