---
title: 주피터(Jupyter, IPython >= 3)의 다중 커널 개념 이해하기 - 파이썬2와 파이썬3 동시에 사용하기
date: 2015-05-08 3:00:00 +0900
author: nacyot
tags: ipython, jupyter, python, jupyter kernel, iruby, python2, python3, ipython notebook, pyenv
title_image: http://i.imgur.com/ww5UMh7.jpg
published: true
---

아이파이썬 노트북(IPython Notebook)은 원래 파이썬 REPL의 확장으로 개발되었다. 원래 메시지 처리 부분을 분리한 현재의 아키텍처는 파이썬이라는 언어에 대해서 콘솔과 qt를 통한 GUI, 그리고 웹을 기반으로하는 노트북 등 클라이언트를 분리하기 위해서 도입되었다. 하지만 이는 동시에 언어 실행기의 확장 (즉, 파이썬 이외의 것들을 실행할 수 있는) 가능성도 열어주었다. 원래 IPython에서는 이런 부분에 대한 고려가 없었기 때문에 언어를 해석하는 커널은 기본적으로 한 가지만을 지원한다. 따라서 커널을 바꿀 수는 있지만, 커널을 바꾸려면 IPython Notebook 서버를 새로 실행해야만 했다. 반면에 주피터(IPython >= 3의 다른 이름)에서는 하나의 서버에서 다수의 커널을 바꿔가며 실행할 수 있다.

<!--more-->

## IPython2의 커널 설정 이해하기

먼저 IPython2 버전의 노트북 서버는 다음과 같이 실행한다.

```
$ ipython notebook
```

이 명령어로 파이썬을 실행하면, 현재 버전의 인터프리터 커널로 IPython Notebook 서버가 실행된다. 즉, 파이썬 버전이 2.7.9라면, IPython Kenrel도 2.7.9가 되고, 3.4.2면 3.4.2가 된다. 실행이 가능하다면 다른 인터프리터에 대해서도 마찬가지이다.

먼저 명령행에서 파이썬 버전을 확인해보고, 파이썬 노트북을 실행해보자.

```
$ python --version
Python 2.7.9
$ pip install "ipython[notebook]<3"
...
$ ipython notebook
```

서버를 실행하면 `http://localhost:8888`이나 출력되는 주소로 IPython Notebook에 접근할 수 있다. 새로운 노트북을 만들고, 노트북 위에서 파이썬 버전을 확인해보자.

![파이썬 버전 확인](http://i.imgur.com/vmEJyXA.png)

명령행에서와 마찬가지로 2.7.9임을 확인할 수 있다. 만일 다른 언어나 다른 버전의 파이썬 커널을 실행하고자 한다면, 별도의 IPython Profile(설정들을 모아놓은 디렉터리)를 만들고 아래의 명령어로 해당하는 프로필을 적용할 수 있다.

```
$ ipython notebook --profile <PROFILE>
```

아니면 커널 옵션을 직접 지정하는 방법도 있다.

```
$ ipython notebook --KernelManager.kernel_cmd=<COMMAND>
```

즉, 하나의 서버에서는 다수의 커널을 지원하지 않기 때문에 매번 새로 실행하거나 별도의 서버를 실행해야하는 번거로움이 있었다.

## 왜 주피터(Jupyter)가 되었을까?

전술하였듯이, 원래 IPython에서 클라이언트와 파이썬 해석기 사이에 메시지를 중개하기 위한 ZeroMQ가 사용된 것은 사실 다양한 클라이언트를 지원하기 위해서였다. 그런데 이는 동시에 다양한 커널을 도입하게 되는 계기가 되기도 했다([IPEP 25][IPEP25]). 이러한 요구사항은 IPython이라는 이름 대신 새로운 이름이 필요했던 가장 큰 이유라고 생각된다.

[IPEP25]: https://github.com/ipython/ipython/wiki/IPEP-25%3A-Registry-of-installed-kernels

Jupyter(IPython >= 3)에서는 하나의 노트북 서버에서 다수의 커널을 지원한다. 즉, 하나의 서버를 실행한 상태에서 커널을 선택해서 노트북을 작성할 수 있도록 구조가 변경되었다.

### 주피터(Jupyter)의 기본 커널

먼저 여기에서는 OSX나 Linux 계열 운영체제에서 파이썬3를 사용하고 있다고 가정한다.

```
$ python --version
Python 3.4.2
```

최신 버전의 주피터를 설치한다.

```
$ pip install ipython[notebook]
$ ipython --version
3.1.0
```

주피터에는 현재 사용가능한 kernel들을 확인할 수 있는 명령어가 추가되었다. 먼저 현재 사용할 수 있는 커널을 살펴보자.

```
$ ipython kernelspec list
python kernelspec list
Available kernels:
  python3
```

이를 통해서 현재 파이썬 버전이 사용가능하다는 것을 알 수 있다. 실제로 서버를 실행해서 확인해보면 새로운 노트북을 만들 때 Python 3만을 선택할 수 있을 것이다.

### 다중 커널 개념 이해하기

앞서 이야기한 것처럼 주피터에서는 다중 커널을 하나의 노트북 서버에서 지원한다. 이러한 기능을 활성화하려면 적절히 커널 설정 파일을 추가해주어야한다. 과거에는 이러한 작업을 위해서 프로필 개념을 주로 사용했으나, 현재는 `~/.ipython` 디렉터리 아래에 `kernels`라는 디렉터리를 사용하는 것이 더 편리하다.

여기에 가보면 처음에는 아무런 커널도 없음을 알 수 있다.

```
$ cd $(ipython locate)/kernels
$ ls
```

여기에 커널 설정이 없더라도, 주피터는 기본 커널(파이썬3)을 적절히 실행해준다. 명시적으로 커널 설정을 확인하고 수정하기 위해서는 다음 명령어를 사용한다.

```
$ ipython kernelspec install-self
```

이 명령어를 실행하면, `/usr/local/share/jupyter/kernels`에 Python3 커널 설정을 추가할 것이다. 편의상 이를 ipython 설정 디렉터리 아래로 복사한다.

```
$ mv /usr/local/share/jupyter/kernels/python3 $(ipython locate)/kernels
```

커널 디렉터리로 이동해보면 다음과 같은 파일들을 볼 수 있다.

```
$ cd ~/.ipython/kernels/python3
kernel.json    logo-32x32.png logo-64x64.png
```

`logo-*.png` 이미지 파일은 해당하는 커널을 사용할 때 화면에 보여줄 이미지이다. 여기서 주목할 파일은 kernel.json이다.

```
$ cat kernel.json
{
 "language": "python",
 "display_name": "Python 3",
 "argv": [
  "/usr/bin/python3",
  "-m",
  "IPython.kernel",
  "-f",
  "{connection_file}"
 ]
}
```

`langugae`는 커널의 언어, `display_name`은 화면에 보여줄 이름이라는 것을 쉽게 유추할 수 있다. 그리고 `argv` 속성이 바로 파이썬 커널 서버를 실행하기 위한 명령어이다. 이 명령어를 그대로 복사해서 실행해보도록하자. `connection_file`은 임의로 `python3.ipython`이라고 붙였다.

```
/usr/bin/python3 -m IPython.kernel -f python3.ipython
NOTE: When using the `ipython kernel` entry point, Ctrl-C will not work.

To exit, you will have to explicitly quit this process, by either sending
"quit" from a client, or using Ctrl-\ in UNIX-like environments.

To read more about this, see https://github.com/ipython/ipython/issues/2049

To connect another client to this kernel, use:
    --existing python3.ipython
```

이제 커널 서버가 실행되고 명령을 기다린다. 맨 아래에서 설명하고 있듯이 `--existing python3.ipython` 옵션을 통해서 ipython에서 이 커널 서버를 직접 사용하는 것도 가능하다.

```
# 다른 셸에서 실행
$ ipython console --existing python3.ipython
IPython Console 3.1.0

In [1]: print('Hello, Python')
Hello, Python
```

#### 다른 언어 커널 예제(ruby)

위의 예제는 사용하는 커널이 파이썬3이기 때문에 `ipython console`을 그냥 사용하는 것과 어떻게 다른지 알 수 없다. 실제로 커널 서버가 작동하는 것을 보여주기 위해, 다음 예제에서는 IRuby가 설치되어있다고 가정한다.(IRuby에 대해서는 이전 글 [IRuby Notebook][iruby] 참조)

[iruby]: http://blog.nacyot.com/articles/2015-04-15-rorlab-jupyter-iruby-notebook/

IRuby를 위한 `kernel.json`을 살펴본다.

```
$ cd $(ipython locate)/kernels/ruby
$ cat kernel.json
{
  "argv": [ "iruby", "kernel", "{connection_file}" ],
  "display_name": "Ruby",
  "language":     "ruby"
}
```

기본적인 구조는 파이썬의 `kernel.json`과 완전히 같다. 간단히 설명하자면 IRuby는 Jupyter와 소통하기 위한 커널 서버의 Ruby 구현체라고 할 수 있다. 앞서와 마찬가치로 커널 서버를 실행한다. 단, iruby 커널은 자동적으로 connection 파일을 생성하지 않으므로, 임시 파일을 미리 생성해준다.

```
$ echo '{
  "stdin_port": 57533, 
  "ip": "127.0.0.1", 
  "control_port": 40023, 
  "hb_port": 35724, 
  "signature_scheme": "hmac-sha256", 
  "key": "29e39299-76c7-495f-be03-eb1722c25efe", 
  "shell_port": 52952, 
  "transport": "tcp", 
  "iopub_port": 41730
}' > ruby.ipython
```

이제 IPython을 이 connection 파일로 실행하면, 루비 코드가 실행된다.

```
$ ipython console --existing ruby.ipython
IPython Console 3.1.0

In [1]: puts "puts is not python method!"
puts is not python method!
```

이와 같이 어떤 원리로 커널(실행기)가 클라이언트가 실행되는 지를 이해하면, 다중 커널이 무엇을 의미하고 어떻게 설정할 수 있는 지도 어렵지 않게 이해할 수 있다.

## 주피터(Jupyter)에서 파이썬2와 파이썬3 동시에 사용하기

앞서서 살펴보았듯이 IPython에서는 IPython을 실행한 파이썬 버전을 우선적으로 사용한다. 이는 주피터에서도 마찬가지이다. 파이썬3를 사용하고 있다면 기본 커널은 파이썬3가 된다. 그렇다면 파이썬2를 사용하고자 한다면 어떻게 해야할까? 물론 파이썬2를 설치하고 pip로 ipython을 설치하고 notebook 서버를 실행하는 것도 방법이긴 하다. 하지만 앞서 다중 커널에 대해서 배웠으니, 여기서는 이를 활용해보도록 하자.

다시 한 번 되새겨보자. 커널은 노트북 서버나 클라이언트와는 분리되어있다. 따라서 커널이 파이썬2건 파이썬3건 노트북 서버나 클라이언트는 전혀 신경쓰지 않는다. 단지 기본적으로 실행되는 파이썬은 IPython이 실행되는 파이썬을 사용하도록 설정되어있을 뿐이다.

여기서는 pyenv와 파이썬3를 사용한다고 가정하고 앞서 보았던 파이썬3의 `kernel.json` 파일을 사용해 파이썬2 커널을 지원하도록 만들 것이다.

먼저 Notebook Server를 실행해 파이썬 3만이 지원된다는 것을 확인해보자.

```
$ pyenv install 3.4.2
$ pyenv global 3.4.2
$ pythen --version
Python 3.4.2
$ ipython notebook
```

다음 이미지와 같이 IPython Notebook 서버에서는 기본적으로 `Python 3` 하나의 커널만을 지원하다. 기본 커널을 생성하고 이를 IPython 설정 디렉터리로 이동시킨다. 그리고 디렉터리 이름을 python2로 변경한다.

```
$ ipython kernelspec install-self
$ mv /usr/local/share/jupyter/kernels/python3 $(ipython locate)/kernels
$ cd $(ipython locate)/kernels
$ mv python3 python2
$ cd python2
```

먼저 `pyenv`를 통해서 파이썬 2를 설치한다.

```
$ pyenv install 2.7.8
```

`kernel.json`을 다음과 같이 수정한다. <USER>은 적절히 변경한다.

```
{
 "language": "python",
 "display_name": "Python 2",
 "argv": [
  "/Users/<USER>/.pyenv/versions/2.7.8/bin/python2.7",
  "-m",
  "IPython.kernel",
  "-f",
  "{connection_file}"
 ]
}
```

이게 전부다. 다시 IPython Notebook을 실행시켜본다(이미 실행이 되어있다면 재실행하지 않아도 바로 적용된다).

```
$ ipython notebook
```

이제 Notebook에 접속해서 새로운 문서를 만들려고 하면 다음과 같이 "Python 2"와 "Python 3" 두 선택지가 있는 것을 알 수 있다.

![노트북 생성시 커널 선택 - 파이썬2, 파이썬3](http://i.imgur.com/XhKnpqa.png)

각각의 커널을 선택해서 실제로 작동하는 버전을 확인해보자. 먼저 파이썬2로 노트북을 만들고, 중간에 파이썬3로 커널을 교체한다.

![하나의 서버에서 다른 파이썬 버전 커널 사용하기](http://i.imgur.com/N6Ftpak.png)

위와 같이 파이썬2와 파이썬3 커널을 하나의 노트북 서버에서 사용 가능하다는 것을 확인할 수 있다.

## 결론

주피터의 다중 커널 개념 지원은 매우 간단하고, 강력하다. IPython이 실행되는 파이썬 실행기에 종속되지 않기 때문에, 다른 언어들의 커널을 지원할 뿐만 아니라, 환경만 갖춰져 있다면 같은 언어의 다양한 버전에 대해서도 별도의 커널을 만들어 사용할 수 있다. 나아가 파이썬의 virtualenv와 결합하면 환경별로도 커널을 분리해 사용할 수 있다. 이와 같이 다중 커널 개념은 Jupyter의 핵심 개념이며, 이를 통해서 좀 더 자유롭게 Notebook 생활이 가능해질 것이다 >_<
