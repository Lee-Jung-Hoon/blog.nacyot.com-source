---
title: "[RORLab 발표] 주피터(Jupyter) - IRuby Notebook 보충"
date: 2015-04-15 10:30:00 +0900
author: nacyot
tags: ipython, iruby, jupyter, iruby notebook, ipython notebook, literate programming, active essays
published: true
---

IPython은 Python REPL의 확장 구현이다. 0.12 버전부터 Notebook이라는 이름으로 웹 인터페이스를 지원하고 있다. 또한 파이썬 뿐만 아니라 다른 언어를 실행할 수 있는 다양한 커스텀 커널을 지원하고 있다. IRuby는 IPython의 루비(Ruby) 커널 구현체로 이를 사용해 IPython Notebook에서 Ruby 코드를 실행하고 문서를 작성하는 게 가능하다.

![](http://i.imgur.com/x794HK9.png)

이 글은 2015년 4월 14일 RORLab에서 발표한 내용을 보충하기 위한 글로 IRuby 설치, 실행 및 발표 레퍼런스를 소개한다.

<!--more-->

## 발표자료

<div style='max-width:550px'>
<script async class="speakerdeck-embed" data-id="ee397ca6231f4a7a9c2c73eda6e81525" data-ratio="1.29456384323641" src="//speakerdeck.com/assets/embed.js"></script>
</div>

https://speakerdeck.com/nacyot/jupyter-iruby-notebook

## IRuby 설치하기

### ZeroMQ 설치하기

ZeroMQ를 설치한다.

```
# Mac OSX
$ brew install zeromq --universal

# Ubuntu
$ apt-get install libzmq3
```

### python 환경 구축 및 ipython 설치

pyenv를 설치한다.

```
# Mac OSX
$ brew install pyenv

# Ubuntu
$ git clone https://github.com/yyuu/pyenv.git ~/.pyenv
```

pyenv를 셸에 설정해준다. zsh을 사용한다면 `.bash_profile`을 `.zshrc`로 바꿔준다.

```
$ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
$ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
```

파이썬 3.4.3을 설치하고, 사용하도록 설정한다.

```
$ pyenv install 3.4.3
$ pyenv global 3.4.3
```

관련 라이브러리와 IPython을 설치한다.

```
$ pip install jinja2 tornado pyzmq
$ pip install ipython
```

### IRuby 설치

IRuby 최신 버전은 gem으로 설치할 수 있다. 여기서는 루비 환경은 구축되어있다고 가정한다.

```
$ gem install iruby
```

`iruby` 명령어가 설치되었는지 확인해본다. `iruby` 명령어는 IPython3 이전에 루비 커널로 IPython을 실행하는 래퍼였다.

```
$ iruby --version
0.1.13
```

IPython3부터는 `~/.ipython/kernels`의 커널 설정들을 사용하므로, 루비 커널이 추가되었는지 확인한다.

```
$ ls .ipython/kernels
ruby
```

## IRuby 실행하기

최신 버전(>=3)에서는 `iruby`를 사용하지 않고 `ipython`으로 실행해도 정상적으로 ruby 커널을 사용할 수 있다.

```
$ ipython notebook --ip=0.0.0.0 --notebook-dir <NOTEBOOKS_DIR>
```

정상적으로 서버가 실행되면 `http://0.0.0.0:8888`에 접속해본다.

![](http://i.imgur.com/uhedvNL.png)

## 레퍼런스

### IRuby

* [SciRuby/iruby][iruby]
* [Handybook/irails][irails]

[iruby]:https://github.com/SciRuby/iruby
[irails]:https://github.com/Handybook/irails/

### IPython/Jupyter

* [Project Jupyter][jupyter]
* [IPython 0.0.1][ipython_001]
* [Fernando Perez - The IPython notebook: a historical retrospective][ipython-historical]
* [IPython 0.11 Release Note][release_011]
* [IPython 0.12 Release Note][release_012]
* [Ipython documentation - Messaging in IPython][jupyter_messaging]
* [IPython wiki - IPython kernels for other languages][other_kernels]
* [Galileo's Sidereus nuncius - Starry Messenger][galmoons]
* [Reddit - What is the big deal about IPython Notebooks?][big_deal]
* [Javascript Magic][javascript_magic]
* [Andrew Gibiansky - Creating Language Kernels for IPython][create_kernel]

[jupyter]: https://jupyter.org/
[ipython_001]: https://gist.github.com/fperez/1579699
[ipython-historical]: http://blog.fperez.org/2012/01/ipython-notebook-historical.html
[release_011]: http://ipython.org/ipython-doc/rel-0.11/whatsnew/version0.11.html
[release_012]: http://ipython.org/ipython-doc/rel-0.12/whatsnew/version0.12.html
[jupyter_messaging]: https://ipython.org/ipython-doc/dev/development/messaging.html
[other_kernels]: https://github.com/ipython/ipython/wiki/IPython-kernels-for-other-languages
[galmoons]: http://www4.ncsu.edu/~kimler/hi322/galmoons.html
[big_deal]: http://www.reddit.com/r/Python/comments/1q9tq7/what_is_the_big_deal_about_ipython_notebooks/
[javascript_magic]: http://nbviewer.ipython.org/github/payne92/notebooks/blob/master/00%20Javascript%20In%20Notebooks.ipynb
[create_kernel]: http://andrew.gibiansky.com/blog/ipython/ipython-kernels/

### IPython Kernel for other languages

* [gibiansky/IHaskell][haskell_kernel]
* [takluyver/bash_kernel][bash_kernel]
* [JuliaLang/IJulia.jl][julia_kernel]
* [Jeroen Janssens - IBash Notebook‽][ibash]

[haskell_kernel]: https://github.com/gibiansky/IHaskell
[bash_kernel]: https://github.com/takluyver/bash_kernel
[julia_kernel]: https://github.com/JuliaLang/IJulia.jl
[ibash]: http://jeroenjanssens.com/2015/02/19/ibash-notebook.html

### IPython Client

* [ivanov/bipython][bipython]
* [millejoh/emacs-ipython-notebook][ein]
* [ivanov/vim-ipython][vim-ipython]
* [PyCharm - IPython Notebook Support][pycharm-ipython]

[bipython]: https://github.com/ivanov/bipython
[ein]: https://github.com/millejoh/emacs-ipython-notebook
[vim-ipython]: https://github.com/ivanov/vim-ipython
[pycharm-ipython]: https://www.jetbrains.com/pycharm/help/ipython-notebook-support.html

### Examples

* [D3 Notebook 예제(시각화 스터디)][ex_vis]
* [Interactive Widget][widget]
* [InlineAttachment 예제][inline_attachment]
* [naycot/euler_project][euler_project]
* [루비(Ruby) 테스트 프레임워크 RSpec 2.14 매쳐][rspec_matcher] [ipynb][rspec_ipynb]
* [루비의 꽃, 열거자 Enumerable 모듈][enumerable] [ipynb][enum_ipynb]

<div style='border:1px solid gray;max-width:500px;padding:1.8em'>
<img src='http://i.imgur.com/ir6nP73.png' />
</div>

[ex_vis]: http://nbviewer.ipython.org/gist/nacyot/c0190709f56024eb516e
[widget]: http://nbviewer.ipython.org/github/melund/ipython/blob/3.x/examples/Interactive%20Widgets/Index.ipynb
[inline_attachment]: https://github.com/nacyot/jupyter-inline-attachment-sample
[euler_project]: https://github.com/nacyot/euler-project
[enumerable]: http://blog.nacyot.com/articles/2014-04-19-ruby-enumerable
[rspec_matcher]: http://blog.nacyot.com/articles/2014-04-07-rspec-matchers/
[rspec_ipynb]: https://github.com/nacyot/blog.nacyot.com-source/blob/master/source/iruby/ruby_enumerable.ipynb
[enum_ipynb]: https://github.com/nacyot/blog.nacyot.com-source/blob/master/source/iruby/rspec_matchers.ipynb

### Active Essays / Literate Programming

* [Active Essays - Alan Kay][a_essays_orig]
* [Active Essays on the Web][a_essays]
* [Steven Wittens - Making WebGL Dance][webgl_dance]
* [Setosa blog - markov Chains][markov_chains]
* [Jiongster - Removing User Interface Complexity, or Why React is Awesome][react_awesome]
* [Greensock - Timeline Tip: Understanding the Position Parameter][position_parameter]
* [Donald E. Knuth - Literate Programming][literate_programming]
* [Knuth - Programs to Read][knuth_program]
* [구조적 문서화를 위한 CWEB 시스템(한국어 번역)][ktug_cweb]
* [KTUGFaq - Literate Programming][ktug_literate]
* [Wikipedia - CWEB][wiki_cweb]
* [Wikipedia - Literate Programming][wiki_literate]
* [from __future__ import dream - knitr를 이용한 워드프래스 포스팅하기][knitr]
* [전희원 - R Markdown을 이용한 문학적 프로그래밍][knitr_youtube]
* [Fernando Perez - "Literate computing" and computational reproducibility: IPython in the age of data-driven journalism][data_journalism]
* [Ansible Documentation][ansible_document]

[a_essays_orig]: http://web.archive.org/web/20060710213801/http://www.squeakland.org/whatis/a_essays.html
[a_essays]: http://www.vpri.org/pdf/tr2009002_active_essays.pdf
[webgl_dance]: http://acko.net/files/fullfrontal/fullfrontal/webglmath/online.html
[markov_chains]: http://setosa.io/blog/2014/07/26/markov-chains/
[react_awesome]: http://jlongster.com/Removing-User-Interface-Complexity,-or-Why-React-is-Awesome
[position_parameter]: http://greensock.com/position-parameter
[literate_programming]: http://www.literateprogramming.com/knuthweb.pdf
[ktug_cweb]: http://faq.ktug.org/wiki/pds/SampleDocument/cwebman.pdf
[wiki_cweb]: http://en.wikipedia.org/wiki/CWEB
[wiki_literate]: http://en.wikipedia.org/wiki/Literate_programming
[knitr]: http://freesearch.pe.kr/archives/3265
[ktug_cweb]: http://faq.ktug.org/faq/CWEB
[knitr_youtube]: https://www.youtube.com/watch?v=CuhsPl7JDvc
[ktug_literate]: http://faq.ktug.org/faq/LiterateProgramming
[data_journalism]: http://nbviewer.ipython.org/github/fperez/blog/blob/master/130418-Data-driven%20journalism.ipynb
[ansible_document]: http://docs.ansible.com/docker_module.html
[knuth_program]: http://www-cs-faculty.stanford.edu/~uno/programs.html

### Blogging by Ipython

* [Fernando Perez - Blogging with the IPython notebook][blog_fperez]
* [Pythonic Perambulations][blog_jakevdp]
* [Box and Whisker - IPython Notebook으로 블로깅하기][blog_boxnwhis]

[blog_fperez]: http://blog.fperez.org/2012/09/blogging-with-ipython-notebook.html
[blog_jakevdp]: https://jakevdp.github.io/
[blog_boxnwhis]: http://www.boxnwhis.kr/2015/02/10/blogging_with_python.html

### ETC

* [Eyeo 2013 - For example by Mike Bostock][mike]
* [O'Reilly Atlas + jsbin][atlas]
* [Codemirror - a versatile text editor implemented in JavaScript for the browser][codemirror]
* [Bokeh - Python interactive visualization library][bokeh]

[mike]: https://vimeo.com/69448223
[atlas]: http://chimera.labs.oreilly.com/books/1230000000345/
[codemirror]: https://codemirror.net/
[bokeh]: https://github.com/bokeh/bokeh
