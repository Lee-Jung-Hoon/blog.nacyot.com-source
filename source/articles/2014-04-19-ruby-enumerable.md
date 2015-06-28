---
title: "루비의 꽃, 열거자 Enumerable 모듈"
date: 2014-04-19 18:53:32 +0900
author: nacyot
tags: ruby, enumerable, programming_language, programming
categories: programming
title_image: http://i.imgur.com/smOrGyZ.jpg
---

프로그래밍을 배우면 피해갈 수 없는 부분 중 하나가 바로 제어 추상화입니다. 그 중에서도 반복문은 특히 많이 사용되는데, 재미있는 건 [[루비|ruby]]에서는 다른 언어에서 많이 사용되는 while이나 for 같은 문법을 잘 사용하지 않는다는 점입니다. 이러한 변수 재대입에 의존한 반복문들을 사용하기보다는 컬렉션의 요소 하나하나를 블록에 넘겨 평가하는 `each`와 같은 열거자([[Enumerable]]) 메서드가 주로 사용됩니다. 이러한 컬렉션 확장 메서들은 처음 사용할 때는 낯설게 느껴질 지도 모르지만, 사실은 컬렉션 없는 반복문이야 말로 특수한 경우이므로 루비의 접근이 합리적이라는 걸 금방 깨닫게됩니다. 나아가 Enumerable은 단순히 `each` 메서드만 제공하는 게 아닙니다. 다양한 열거자 메서드를 통해 루비에서 컬렉션을 좀 더 자유자재로 다룰 수 있습니다. 이 글에서는 Enumerable 모듈에 포함된 다양한 열거자 메서드들을 소개합니다.

<!--more-->

{{ipython:ruby_enumerable}}

## 결론

이걸로 [[Enumerable]] 모듈의 거의 모든 메서드를 다뤘습니다. 좀 더 이야기해 볼 주제가 있다면 Enumerable 확장 클래스 만들기, Lazy, Enumerabtor와 외부 반복자, Enumerable 모듈을 일부 확장하는 [[gem]]인 [[powerpack]]과 메소드 체인 활용 예제 정도가 있을 것 같은데 기회가 되면 이런 이야기들도 정리해보도록하겠습니다. 아듀~
