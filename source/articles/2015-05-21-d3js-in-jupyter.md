---
title: 주피터(Jupyter) 노트북과 자바스크립트 환경 이해하기 - 주피터 위에서 d3.js를 활용한 시각화
date: 2015-05-21 03:40:00 +0900
author: nacyot
tags: ipython, jupyter, d3.js, javascript, 시각화, 주피터, 아이파이썬, 자바스크립트, 커널, 클로저
published: true
---

기존의 아이파이썬(IPython)에서 이제 본격적으로 주피터 프로젝트로 옮겨가는 과정이 한창 진행중이다. 주피터의 핵심에 대해서는 **[주피터 다중 커널 개념 이해하기][multiple_kernel]**에서 이미 다루었듯이, 파이썬을 비롯한 다양한 언어의 커널을 지원한다는 데 있다. 맥락은 조금 다르지만, 아이파이썬은 이미 훌륭한 자바스크립트 실행환경에서 작동한다는 점에서 주피터 이전에도 이미 멀티 커널을 기본적으로 지원하고 있었다고 할 수 있다. 이 글에서는 이러한 기능을 활용해 주피터 위에서 자바스크립트 코드를 작성 및 실행하고, d3.js 라이브러리를 통해 시각화를 하는 방법에 대해 간단히 소개한다.

[multiple_kernel]: http://blog.nacyot.com/articles/2015-05-08-jupyter-multiple-pythons/

<!--more-->

{{ipython:d3js-in-jupyter}}

