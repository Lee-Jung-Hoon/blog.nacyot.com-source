---
title: "이맥스(Emacs) 패키지 관리 도구 Cask 문서 번역"
date: 2014-04-28 10:00:00 +0900
author: nacyot
published: true
tags: emacs, cask, translation, editor, news
categories: editor, news
title_image: http://i.imgur.com/QyIQJCe.jpg
---

* [http://cask.emacs.kr/][cask]

> Emacs を使い始めてはや15年、ようやくまともな elisp 管理ができるようになった。

> Emacs를 사용하기 시작한 지 벌써 15년, 드디어 제대로 된 elisp 관리가 가능하게 되었다. 

[cask]: http://cask.emacs.kr

일본 프로그래머 Ito Naoya 씨가 [Cask를 소개하는 글][ito]에서 이런 얘기를 하길래, 관심이 가서 [Cask 공식 문서][cask_original]를 번역했습니다.

[ito]: http://d.hatena.ne.jp/naoya/20140424/1398318293
[cask_original]: http://cask.github.io

[[Emacs]] 24를 사용하시는 분들은 아시겠지만 이제 Emacs에서도 공식 패키지 관리 도구를 제공합니다. 하지만 어디까지나 패키지를 설치할 뿐이고, 삭제나 업데이트 같은 기능은 지원하지 않습니다. 이런 이유로 장기적인 관점에서 패키지 관리나 환경 설정이 산만해지는 건 아직까지도 어쩔 수 없는 문제입니다.

그만큼이나 Emacs 설정을 잘 하는 건 어렵습니다. 해본 사람은 알겠지만 이것저것 입맛대로 뜯어고치고 플러그인 설치하고 한 번 꼬이고 그러면 그냥 프로그래밍 하는 시간보다 설정하는 시간이 더 많이 드는 거 아닌가 하는 회의감이 들 정도니까요. 강력하지만 귀찮고 어렵습니다.

[[Cask]]는 이러한 문제를 [[Ruby]]의 번들러나 [[Node.js]]의 [[npm]]처럼 'Cask'라는 파일을 통해 해결해줍니다. 이를 통해 [[Emacs Lisp|emacs_lisp]] 개발자는 의존 라이브러리를 관리할 수 있고, Emacs 사용자는 자신이 사용하고자 하는 패키지를 쉽고 체계적으로 관리할 수 있습니다.

현재 틈틈히 Cask로 옮기는 작업을 하고 있으니, 조만간 Cask로 완전히 갈아타는 데 성공하면 사용법에 대해서도 소개하겠습니다.

<!--more-->
