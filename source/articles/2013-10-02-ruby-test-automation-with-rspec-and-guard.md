---
title: "Rspec과 Guard를 활용한 루비 테스트 자동화"
date: 2013-10-02 12:00:00 +0900
author: nacyot
published: true
---

루비 테스트로는 minitest와 Rspec이 많이 사용됩니다.. 저는 대부분 Rspec을 사용합니다만, 어느 쪽이건 이러한 테스트를 매번 직접 실행해주기는 매우 귀찮은 일입니다. 이러한 부분을 자동화하기 위해서 과거에는 Autotest 같은 툴이 사용되었습니다. Autotest는 특정 파일이 수정되면 테스트를 자동으로 실행하는 방식으로 작동합니다. 현재는 Autotest 대신에 Guard를 많이 사용하는데, Guard는 특정한 파일을 감시하다가 이러한 파일에 변화가 있을 때 특정한 명령어를 수행하는 좀 더 범용적인 툴이라고 생각하면 됩니다. 여기서는 Guard를 사용해 rspec 테스트를 자동화하는 법을 소개합니다.

<!--more-->

## Spring

먼저 테스트 속도 향상을 위해 Rails preloader인
[spring](https://github.com/jonleighton/spring)을 설정해 두었습니다.
자세한 사항은 spring github 페이지를 참조하시면 됩니다. 간단한
사용법은 spring을 앞에 붙여주면 됩니다. 별도로 spring server 실행
명령어를 사용할 필요가 없으며, 명령어를 처음 실행할 때 자동으로
실행됩니다.

```
# spring 설정 전 테스트
# rvm 사용시 bundle exec 는 생략하셔도 됩니다.
bundle exec rake rspec

# spring 설정 후 테스트
bundle exec spring rake rspec
```

테스트를 지속적으로 실행하게 되므로 spring을 사용하는 편이 압도적으로
속도가 빠릅니다. 문제가 있다면 가끔씩 spring 서버에 문제가 생겨서
제대로 작동을 안 하는 경우가 있는데, 그럴 경우엔

```
bundle exec spring stop
```

을 실항해서 spring을 종료하시고 다시 명령어를 실행시켜주시면됩니다.

## Guard

단순히 spec 폴더의 파일들을 테스트 하는 것은 rake면 충분합니다만,
작업과정의 변경사항에 대한 자동적인 테스트를 실행시키기 위해서는
[Guard](https://github.com/guard/guard)가 필요합니다. Guard는 watch와
비슷한 역할을 해주는 프로그램으로 파일을 감시하다가 특정 파일이
변경되면 거기에 해당하는 스크립트를 실행시켜줍니다. 이러한 세팅은
Guardfile에 들어가 있으며 현재는 rspec(+spring)에 대해 기본설정이
적용되어 있습니다. 아래의 명령어로 초기화합니다.

```
bundle exec guard init rspec
```

guard는 spring과는 별개로 작동하고 guard에서 파일 변화를 캐치해서
테스트를 실행할 때만 내부적으로 spring을 사용합니다. spring과
연동시켜주기 위해서 아래의 설정을 Guardfile에 추가해줍니다.

```
# default
guard :rspec do

# after
guard :rspec, :spring => true do
```

따라서 Rails 어플리케이션의 루트에서 아래의 명령어로 실행시키시면
됩니다.

```
bundle exec guard
```

보통은 tmux나 screen에서 하나의 윈도우를 할당해놓고 사용하는 게
일반적입니다. 이렇게 해두면 다른 윈도우나 텍스트 에디터에서 Rails
어플리케이션 파일이나 테스트 파일을 변경하면 guard가 자동으로 캐치해서
해당하는 부분의 spec 테스트를 실행시켜줍니다. 이런 식으로 테스트
결과를 계속 확인하면서 작업할 수 있습니다. 또한 guard 프로그램 내에서
여러가지 명령어를 실행시킬 수 있으며, 명령어 없이 엔터를 눌러주면 전체
테스트를 실행시켜 줍니다. guard는 단순히 rspec 자동화를 위해 만들어 진
gem은 아니라, cucumber나 서버 재실행 등 다른 작업을 실행시키는 데도
확장해서 사용할 수 있습니다.

테스트 결과에 대한 알림은 Ubuntu 같은 경우는 notification을 시스템
쪽으로 자동으로 주는 것 같고, Mac 같은 경우는 growl과 연동해서
사용하는 게 보통입니다. 다양한 notification 지원에 대해서는 Guard
github 페이지에 좀 더 자세히 나와있으니 참조하시면 될 것 같습니다.

## Rspec setting

rspec을 실행하는 데 기본 옵션 설정은 HOME 디렉토리의 .rspec 파일이나,
Rails 어플리케이션 루트의 .rspec 파일에 기록합니다.

```
# 테스트 결과에 색을 입혀 출력해줍니다.
--colour

# 테스트 실행 결과에 테스트 이름을 같이 보여줍니다. rspec을 사용하면
  기본적으로 테스트를 .으로 출력하는데, 이게 불편하실 때 사용하시면
  됩니다.
--format d
```

## spec_helper.rb
