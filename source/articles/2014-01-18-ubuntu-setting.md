---
title: "우분투 13.10 개발환경 세팅"
date: 2014-01-18 00:00:00 +0900
author: nacyot
profile: 우분투 쓰는 루비 프로그래머(29)
---

Ubuntu 13.10 개발 환경 세팅 정리. 서버면 자동화시키는 것도 좋은 방법일 듯 한데, 데스크탑은 그래픽 드라이버 같은 부분이 컴퓨터마다 다르다 보니 완전히 자동화하는 건 쉽지 않은 것 같다. 지난 번까지 우분투 13.04 써왔는데(지금 노트북도 13.04), 이번에 새로 13.10에 도전해봤다. 사실 그래픽 드라이버 문제로 13.04로 낮추고 싶었으나, 조만간 지원이 끝난다고 하길래 맘 잡고 13.10으로 개발환경 정리를 했다. 금요일 오전 내내 걸렸으니까 전체 세팅하는데 4~5시간 정도 걸린 것 같다. 이걸로 기본적인 부분은 정리가 된 듯 싶고, 어디까지나 앞으로 삽질 방지용 포스트.

참고로 본인은 Ubuntu / Terminator(터미널 프로그램) / Emacs(에디터) / Dvorak(키보드 레이아웃) 사용자.

<!--more-->

## Ubuntu 13.10 설치


* [우분투 공식 홈페이지](http://www.ubuntu.com/download/desktop)

우분투 13.10 설치. 우분투에는 기본적으로 setup disk creator이라는 어플이 들어가서 있어서 이걸로 usb에 옮겨담을 수 있는데 조금 문제가 있어서 윈도우에서 [Linux Live USB Driver](http://www.linuxliveusb.com/)로 USB에 설치.

## APT 다운로드 서버 설정

처음에 자동으로 업데이트를 실시하지만 패키지도 많고 상당히 시간이 오래걸린다. 이 때 미러 서버를 바꿔주면 속도가 많이 개선된다.

0. 자동으로 뜨는 업데이트는 진행하지 말 것.
0. System Settings
0. Software & Updates
0. Ubuntu Software 탭에서 Download from : http://ftp.daum.net/ubuntu

APT 다운로드 서버 설정. 자세히 알고 있다면 `/etc/apt`에 설정 파일들을 직접 편집해도 되지만 보통 시스템 설정을 사용하는 게 편리하다. 디폴트로 잡혀있는 kr.archive.ubuntu.com은 많이 느린 편이고, 한국에서는 Daum이나 Neowiz 서버가 빠르긴한데 업데이트가 느리거나 불안정하다는 얘기가 있다. 한국 미러에 문제가 있는 경우, 일본에서 빠른 서버 찾아서 사용하면 된다. jaist를 많이 사용하는 것 같다.

0. 터미널에서 업데이트 진행(Software & Updates 윈도우에서 진행해도 무관하다).

```
sudo apt-get update
sudo apt-get upgrade
```

## 그래픽 카드 설치

이번에 설치한 그래픽 카드는 AMD A10 5800K(APU). 아마도 이런 모델이었던 것 같은데 맞는 지는 모르겠다. 일단 Ubuntu에서 기본적으로 지원하는 드라이버 Xorg로는 화면이 깨지는 현상이 있어서 AMD 쪽에서 나오는 서드파티 드라이버를 설치해야한다. `fglrx`를 설치하면 화면이 깨지는 현상은 사라지는데 마우스 커서가 없어지는 문제가 있어서 `fglrx-update`를 설치.

`sudo apt-get install fglrx-update fglrx-update-dev`

이걸로 안 되면 삭제하고 `fglrx` 설치.

`sudo apt-get install fglrx fglrx-dev`

### 듀얼 모니터 설정

단 `fglrx-update`를 설치하니 듀얼모니터가 해상도 제한이 걸린다며 지정이 안 되는 문제가 발생했다.

```
sudo aticonfig --initial # /etc/X11/xorg.conf 생성.
sudo amdcccle
```

설정을 알고 있다면 직접 xorg.conf 생성 후 직접 편집해도 되지만, 잘 모른다면 AMD 드라이버 설정 관리자(amdcccle)를 열어서 듀얼 모니터를 잡아주면 된다. 여기서 화면 회전이나 추가적인 설정 가능.

### 참고

일반적으로 어떤 그래픽 카드건 Software & Updates의 Additianal Drivers에서 사용가능한 드라이버를 확인할 수 있다. 문제가 있으면 여기에 뜨는 것들을 바꿔가며 테스트 해보고 구글링으로 해당하는 문제를 찾아보는 게 좋다.

## Nabi 설정

### 한글 입력기 Nabi 설치[^1]

```
sudo add-apt-repository ppa:createsc/copy4
sudo apt-get update
sudo apt-get install nabi
```

[^1]: 참고 http://www.ubuntu.or.kr/viewtopic.php?p=62810

0. System Settings
0. Language Support
0. 키보드 입력기 : Hangul
0. 재부팅 or 로그아웃
0. 드보락 설정(필요시, 링크 참조)

### System Tray Whitelist 등록[^2]

```
sudo add-apt-repository ppa:mc3man/systray-white
sudo apt-get update
gsettings set com.canonical.Unity.Panel systray-whitelist "['all']"
```

[^2]: 참조 http://www.ubuntu.or.kr/viewtopic.php?p=112275

## 방화병 설정 및 ssh 서버 설치

```
sudo ufw enable
sudo ufw allow 22/tcp
sudo apt-get ssh-server
sudo apt-get install ssh-server
```

외부 접속 위해서 ssh-server 설치해줘야 되는 건지 원래 되는 건지(설치 되어있는지) 정확히 기억이 안난다. `uft`은 방화벽 설정.

## ssh key 생성

```
ssh-keygen -t rsa -C "propellerheaven@gmail.com"
```

ssh key 생성 후, `~/.ssh/id_rsa.pub` 파일 출력해서 github, bitbucket, gitlab에 등록 해 줌.

## OpenVPN 세팅

```
sudo apt-get install openvpn
# /etc/openvpn vpn 환경 설정 파일 설정
sudo service openvpn restart
```

개인적으로는 로컬 서버에서 돌리는 것들이 있어서 openvpn 열어서 사용중. 필요하면 /etc/openvpn디렉토리에서 설정.

## Unix 설정 파일 Clone

```
sudo apt-get install zsh tmux git
chsh # /bin/zsh
git clone git@<GIT_SERVER>:configuration/unix-config.git conf
```

환경설정 파일들은 마찬가지로 기존에 사용하는 것들 그대로 가져와서 사용. 개인적으로 private repository에서 관리중이고 클론해서 `~`에서 `conf` 디렉토리의 폴더로 심볼릭 링크 걸어서 사용. 필요한 게 추가로 있으면 scp로 기존 작업 환경에서 복사해서 사용. 

## Terminator 설치

```
sudo apt-get install terminator
```

터미네이터 설정 파일은 `.config/terminator/config`. 보통은 scp로 원래 쓰던 거 가져다가 세팅했는데,이번엔 [terminator-solarized](https://github.com/ghuntley/terminator-solarized) 테마도 같이사용해봤다.사용해보진 않았는데 Mac 쓰던 경우엔 [이 gist](https://gist.github.com/olistik/3894072)도좋을 듯.

## Eamcs 설치

```
sudo apt-get install emacs24 emacs24-common
git clone git@<GIT_SERVER>:configuration/emacs-config.git .emacs.d
```

ubuntu 13.10에서는 emacs24를 바로 설치해서 사용 가능. 환경 설정에 기존에 사용하던 거 그대로 가져와서 사용.

### the silver seacher 설치

ubuntu 13.10에서는 apt-get으로 바로 silver seacher 설치할 수 있다.

```
sudo apt-get install silversearcher-ag
```

## 워크스페이스 활성화

```
sudo apt-get install compizconfig-settings-manager
```

0. Windows(Super) 키 누르고 `컴피즈 설정 관리자` 실행.
0. General => 일반 설정
0. 데스크탑 크기 탭에서 `가로 가상 크기`와 `세로 가상 크기` 지정.

### 워크스페이스 간 창 이동 단축키 변경

Ubuntu Unity에서는 워크스페이스간에 창 이동을 시킬때 컨트롤 + 쉬프트 + 알트 화살표를 사용하는데 Ubuntu 13.10에서는 기본적으로 양 옆 이동은 가능하나 위 아래 이동은 안 먹히는 문제가 있다. 이를 해결하기 위해서는,

0. Windows(Super) 키 누르고 `컴피즈 설정 관리자` 실행.
0. Desktop => Desktop Wall
0. 바로가기 탭의 Move with window within wall을 열고,
0. 단축키 다시 설정 해줌(연필 아이콘)

## Ruby 설치

```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
```

rbenv 설치. 기본적으로 README에는 bash 기준으로 설정이 되어있는데, 자신이 사용하는 쉘 설정 파일에 집어넣어준다(여기선 zsh). 필요하면 설정하고 쉘을 다시 실행시켜준다.

```
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
sudo apt-get install -qy build-essential zlib1g-dev libyaml-dev libssl-devlibgdbm-devlibreadline-dev libncurses5-dev libffi-dev curl libxml2-dev libxslt-devlibcurl4-openssl-dev libicu-dev
rbenv install 2.1.0
rbenv install 2.0.0-p353
rbenv install 1.9.3-p484
rbenv global 2.1.0
```

ruby-build는 rbenv에서 루비 빌드를 하기 위한 플러그인. 위에서 설치하는 패키지들은 루비 빌드에 사용되는 패키지들.

```
gem install travis middleman middleman-blog rails heroku --verbose
```

중요한 gem들 설치... 별로 중요해보이지 않지만 패스.

## Hub 설치

```
git clone git://github.com/github/hub.git
cd hub/
sudo .rbenv/shims/rake install
```

적당한 디렉토리에 클론하고 `rake install`로 설치.

```
wget https://raw.github.com/github/hub/master/etc/hub.zsh_completion
sudo mv hub.zsh_completion /usr/local/share/zsh/site-functions/_hub
```

zsh용 자동완성 파일을 받아서 위의 디렉토리로 복사해준다. 아래 설정을 `.zshrc` 파일에 추가해준다.

```
eval "$(hub alias -s)"
compdef git=hub
```

## Wine 카카오톡 설치

현재 팀에서 사용하고 있는 메신저가 카카오톡이라 Wine로 카카오톡 설치 시도. 

```
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get upgrade
sudo apt-cache search "wine"
sudo apt-get install wine1.7
winetricks gdiplus
winetricks wmp9 
winetricks riched20
```

`wmp9`은 메시지 알림음, `riched20`은 한글 입력에 필요한 듯.

한글 설정을 위해 굴림 폰트 구해서 wine 폴더 쪽으로 복사해주고 기본 폰트 쪽에 링크를 걸어준다.

```
mv gulim.ttc ../.wine/drive_c/windows/Fonts/
ln -s gulim.ttc batang.ttc
ln -s gulim.ttc dotum.ttc
```

`~/.wine/system.reg` 파일을 열어서 아래 부분을 찾아서,

```
"MS Shell Dlg"="Tahoma"
"MS Shell Dlg 2"="Tahoma"
```

아래 내용으로 바꿔준다.

```
"MS Shell Dlg"="Gulim"
"MS Shell Dlg 2"="Gulim"
```

[카카오톡 설치 파일](http://app.pc.kakao.com/talk/win32/KakaoTalk_Setup.exe) 다운 받아서 실행. 한글이 깨지는 경우 적당이 추측해서 설치해준다.

터미널에서 아래 명령어를 실행해본다. 이 때 카카오톡 아이콘 위치가 정확하지 않으면 직접 확인해준다.

```
wine C:\\windows\\command\\start.exe/Unix/home/daekwon/.wine/dosdevices/c:/users/Public/Desktop/카카오톡.lnk
```

이렇게 실행했는데, 한글이 깨지면 카카오톡을 전부 종료하고 강제로 `LC_ALL` 환경변수를 지정해 실행해본다. 이게 나 같은 경우에는 이번에 Ubuntu를 영어로 설치해서 그러니 Wine도 기본으로 Language가 영어로 잡혀서 폰트 설정만으로는 제대로 적용이 안 됐다. 이 환경변수를 사용해 한글이 잘 되면 카카오톡 설치시 바탕화면에 생기는 아이콘의 실행 경로에 `LC_ALL` 환경변수를 지정해 놓는다.

```
LC_ALL=ko_KR.utf8 wine C:\\windows\\command\\start.exe/Unix/home/daekwon/.wine/dosdevices/c:/users/Public/Desktop/카카오톡.lnk
```

한글이 조금 구려보이긴 하지만 잘 되는 것은 확인.

## 개발용 [Docker](http://docker.io/) 설치

```
curl -s https://get.docker.io/ubuntu/ | sudo sh
```

요새 서버에 도입하려고 궁리중인 Docker. 공식 사이트에서 제공해주는 스크립트 하나면 정말 간단히 설치할 수 있다. 자세항 내용은 [공식 문서](http://docs.docker.io/en/latest/installation/ubuntulinux/) 확인.

## 정리

일단 중요한 부분은 다 정리한 듯. 이외에도 VirtualBox, Vagrant, Pandoc, Tex, python, 등등 설치해야되지만, 필요해지면 설치할 예정.