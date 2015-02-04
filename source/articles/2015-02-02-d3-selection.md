---
title: "D3.js 기초 - select API와 enter() 이해하기"
date: 2015-02-04 15:02:00 +0900
author: nacyot
tags: d3, d3.js, 시각화, visualization, select, enter, infovis
published: true
---

D3JS에서는 조작하고자 하는 요소를 선택할 수 있는 select API를 제공한다. select API는 jquery의 select API와도 비슷하지만, D3에서는 selection 객체에 대해서 `data()`를 통해 특정 데이터를 바인드하고, `enter()`와 `exit()`를 통해 데이터에 대응하는 객체를 다룰 수 있는 기능들을 제공한다. 이 글에서는 D3에서 이 select API를 통해서 어떻게 시각화를 **시작**하는 지에 대해서 다룬다.

<!--more-->

## D3 기초 예제 : 데이터 바인드하고 요소 추가하기

먼저 간단한 예제를 하나 살펴보자.

```
var dataset = [ 5, 10, 15, 20, 25 ];

d3.select("body")          // 1
  .selectAll("p")          // 2
  .data(dataset)           // 3
  .enter()                 // 4
  .append("p")             // 5
  .text("New paragraph!"); // 6
```

이 예제는 Interactive Data Visualization for the Web 5장에서 가져온 예제이다. 이 예제를 말로 풀어써보자면 `body` 요소를 선택하고(1) 그 아래에서 `p`요소를 전부 선택한다(2). 그리고 `dataset`을 이 미리 선택한 selection 객체에 바인드한다(3). 그리고 `enter()`를 통해서 `p` 요소에 바인드가 되지 않는, 즉 대응하는 `p` 요소가 없는 데이터에 대해 새로운 selection을 반환받는다(4). 다음으로 이렇게 선택된 요소들에 대해 실제로 `p` 태그로 이루어진 문서 요소를 생성한다(5). 마지막이다. 이 새로운 `p` 요소에 "New paragraph!"라는 내용을 쓴다(6).

먼저 HTML 상에 `<p>` 요소가 하나도 없는 상태에서 이 코드를 실행했다면, 결과는 다음과 같을 것이다. (편의상 텍스트로 나타낸다.)

```
New panagraph!
New panagraph!
New panagraph!
New panagraph!
New panagraph!
```

여기서 html 요소를 선택하는 (1)과, (1)에서 선택된 요소 아래에서 다시 요소를 선택하는 (2)에서 하는 일은 jquery와도 매우 비슷하고, 이해하기도 쉽다. 하지만 그 다음에 일어나는 일들은 D3에서 사용하는 고유의 데이터 처리 과정을 담고 있다. 이후의 과정에 대해서도 해설을 붙여보았지만, 예상컨데 D3를 따로 배워본 적이 없다면 이러한 접근은 다소 생소하게 느껴질 것이다.

### (1)~(2) D3 select API : 시각화할 요소 선택하기

다시 하나하나의 과정을 좀 더 자세히 살펴보자.

유심히 살펴 보면 (1), (2)에서 하는 일이, 사실은 jquery를 통해 하는 작업과 사실은 별로 비슷하지 않다. jquery를 사용할 때는 일반적으로 이미 어떤 요소가 있다는 것을 가정하고, 그 요소를 선택하기 위해서 select API를 사용한다. 그런데 앞서 위의 출력결과를 얻기 위해서는 `<p>` ***요소가 하나도 없는 상태에서 이 코드를 실행했다면***이라는 전제를 붙였다. 즉, 의도적으로 **아무것도 선택하지 않았다.**

D3에서는 일반적으로 메서드 체이닝 기법을 사용하는데, 이를 기반으로 생각해보자.

```
d3.select("body")          // 1
  .selectAll("p")          // 2
```

먼저 위 코드를 실행한 결과는 무엇을 반환할까? 개발자 도구를 통해서 이를 실행해보면 다음과 같다.

> ![selectAll 반환 결과](http://i.imgur.com/qaSyGYM.png)

여기서 알 수 있다시피 실제 반환값은 배열 비슷한 무언가가 넘어온다(단, 여기서 배열 안의 선택 결과 배열은 비어있다). 이는 엄밀히 말하면 배열이 아니라, d3에서 확장된 d3 selection 객체이다. 이에 대한 좀 더 자세한 내용은 [d3js 소스코드][d3_seleciton_code]에서 확인할 수 있다.

[d3_selection_code]:https://github.com/mbostock/d3/blob/master/src/selection/selection.js

```
d3.select = function(node) {
  var group = [typeof node === "string" ? d3_select(node, d3_document) : node];
  group.parentNode = d3_documentElement;
  return d3_selection([group]);
};
```

먼저 54-58행에서는 여기서 `d3_select()` 함수는 실제로는 sizzle 라이브러리를 통해서 요소를 찾고 이를 `d3_selection()`으로 랩핑한 결과를 반환한다.


```
function d3_selection(groups) {
  d3_subclass(groups, d3_selectionPrototype);
  return groups;
}
```

`d3_selection`은 `d3_subclass` 함수를 통해 객체를 확장한다. 대부분의 기능은 `/src/selection` 아래의 코드를 import해서 구현된다.

이를 통해서 select 혹은 selectAll을 통해서 반환되는 결과가 d3 selection 객체라는 것을 확인할 수 있었다. 단, 앞서 지적했듯이, 이 결과물 배열은 그 내용이 비어있다. (1)~(2)에서 하는 작업을 좀 더 쉽게 설명하자면, d3 라이브러리를 사용하기 위해 빈 d3 selection 객체를 만드는 과정이라고 할 수 있다.

이에 대해서 API 문서를 확인해보자. 먼저, selectAll을 보면,

> d3.selectAll(selector)
> 
> Selects all elements that match the specified selector. The elements will be selected in document traversal order (top-to-bottom). If no elements in the current document match the specified selector, returns the empty selection.

selector에 매치되는 요소가 없다면 빈 selection을 반환한다고 나와있다.

그리고 select를 살펴보면,

> d3.select(selector)
> 
> Selects the first element that matches the specified selector string, returning a single-element selection. If no elements in the current document match the specified selector, returns the empty selection. If multiple elements match the selector, only the first matching element (in document traversal order) will be selected.

마찬가지로 매치되지 않으면 빈 selection을 반환한다고 한다. 여기서 하나 중요한 사실을 알 수 있다. 지금 살펴보고 있는 전체 예제를 다시 확인해보자.

```
d3.select("body")          // 1
  .selectAll("p")          // 2
  .data(dataset)           // 3
  .enter()                 // 4
  .append("p")             // 5
  .text("New paragraph!"); // 6
```

여기서 (1)~(2)의 과정에서 반드시 `selectAll("p")`를 사용할 필요는 없다. 여기까지 과정에서 실제로 선택되는 문서 요소는 존재하지 않기 때문에 사실은 빈 d3 selection 을 반환하면 어떤 표현이라도 이를 대체할 수 있다. 따라서, 아래 네 표현은 모두 같다.

```
d3.select("body")
  .selectAll("p")
```

```
d3.selectAll("p")
```

```
d3.selectAll("div")
```

```
d3.select()
```

앞선 예제의 (1)~(2)를 어떤 표현으로 바꾸더라도, 그 결과는 같을 것이다(좀 더 엄밀히 말하면 그 결과만 같은 것이다. 이들인 빈 selection이라는 것은 동일하지만 다른 부모 요소를 가진다). 중요한 것은 여기서 무엇을 선택했느냐가 아니라 빈 d3 selection 객체를 시작으로 다음 작업들이 이루어진다는 점이다.

### (3)~(4) data()와 enter() : 화면에 없는 데이터를 보여줄 준비하기

(3)~(4)는 D3 고유의 과정이자 핵심적인 부분이라고 할 수 있다. (3)에서 d3 selection에 대해서 `data()` 메서드를 통해 데이터를 빈 선택물에 연결지을 수 있다. 여기까지는 (화면 상에) 아무런 변화도 일어나지 않는다. `data()`의 반환 결과에는 `enter()`, `exit()`라는 D3에서 사용하는 고유한 개념이자 메서드가 더해진다. `enter()` 메서드는 d3 selection에 바인드된 데이터들 중에 아직 실제 문서 요소를 가지지 못 하는 것들을 찾아내서 가상의 객체로 만들어 반환해준다.

> ![enter() 반환결과](http://i.imgur.com/3nOL6Lv.png)

여기서 알 수 있다시피, 이 객체들에는 각각의 데이터 요소들이 연결되어있다. (5)에서는 `append()`를 통해서 `enter()`로 생성된 가상 요소들을 빈 d3 selection 요소의 부모 요소를 기준으로 해서(여기서는 (1)에서 선택한 `body`가 되거나 지정하지 않았다면 html이 될 것이다) 실제 문서 요소로 생성한다. 여기서는 "p" 문서 요소로 생성이 되지만, p 요소는 기본적으로 보이는 내용이 없으므로 (6)에서 `text()` 메서드를 통해서 각 요소마다 "New paragraph!"를 보여주도록 한다.

여기까지가 D3 : 장대한 시각화의 서막이다.

### 보충 - select와 enter의 차이

한 가지 재미있는 사실을 짚고 넘어가자. 이번에는 HTML에 이러한 위 예제의 자바스크립트 코드를 실행하기 전에 세 개의 "p" 요소가 있다고 가정하자. body 아래의 HTML 코드는 아래와 같다.

```
<p>abc</p>
<p>abc</p>
<p>abc</p>
```

이 상태에서 원래의 예제 코드를 실행시키면,

```
var dataset = [ 5, 10, 15, 20, 25 ];

d3.select("body")          // 1
  .selectAll("p")          // 2
  .data(dataset)           // 3
  .enter()                 // 4
  .append("p")             // 5
  .text("New paragraph!"); // 6
```

그 결과는 아래와 같다.

```
abc
abc
abc
New panagraph!
New panagraph!
```

분명히 데이터의 요소는 5개인데, 문단은 2개밖에 출력되지 않았다. 이 결과가 의아하다면 `enter()`를 이해하지 못 했기 때문이다. 먼저 "p" 요소가 하나도 없을 때 `enter()`의 결과를 보자.

> ![p 요소가 없을 때 enter() 반환결과](http://i.imgur.com/4zVidIA.png)

그리고 "p" 요소가 3개가 있을 때 `enter()` 메서드의 결과를 살펴보자.

> ![p 요소가 이미 있을 때 enter() 반환결과](http://i.imgur.com/vXWaKzy.png)

앞서 이야기했다시피 `enter()`는 **바인드된 데이터들 중에 아직 실제 문서 요소를 가지지 못 하는 것들을 찾아내서 가상의 객체로 만들어 반환해준다.** 따라서, 이미 "p" 요소가 있을 경우 `selectAll()`의 결과는 더 이상 빈 d3 selection 객체가 아니라 이미 존재하는 p 요소 3개가 선택된 상태가 된다. 따라서 d3는 우선적으로 이 요소들에 데이터가 연결되어있다고 생각하고, 나머지 아직 연결된 문서 요소가 없는 데이터에 대해서만 가상의 객체를 생성한다. 결과적으로, 미리 존재하는 요소들은 무시된다.

그렇다면 이미 존재하는 요소에 대해서 `enter()` 메서드를 사용하면 이를 조작할 수 없다는 의미가 된다. 이 때는 `selectAll()` 이후, 혹은 `data()` 메서드로 데이터 바인드 이후 반환되는 결과를 바로 조작하면 된다.

```
abc
abc
abc
New panagraph!
New panagraph!
```

즉, 이 상태에서 데이터를 통해 문서 요소를 조작하기 위해서는 다음과 같이 할 수 있다.

```
var dataset = [ 5, 10, 15, 20, 25 ];

d3.select("body")
  .selectAll("p")
  .data(dataset)
  .text(function(d){return d + "!"});
```

그러면 아래와 같은 결과를 얻을 수 있을 것이다.

```
5!
10!
15!
20!
25!
```

## 결론

여러 d3 예제들을 살펴보게 되면 존재하지 않는 요소를 선택하고 데이터를 바인드하는 경우가 많다. 이런 예제를 보면 selectAll과 append에서 왜 굳이 같은 요소를 사용하는 지 의문이 들것이다. 이 글에서는 여기서 무슨 일이 벌어지고 있는 건지, 무엇을 선택해야하는 하는 건지에 대해서 다뤘다. 실제로 여기서하는 작업은 빈 d3 selection 객체를 선택하는 일이고, 여기에 데이터를 바인드하고 바인드된 데이터에 대한 시각적 요소를 생성한다. 이것이 빈 HTML에서 javascript만으로 시각화를 시작하는 기본적인 방법이다. 이를 이해하고 나면 좀 더 수월하게 시각화를 **시작**할 수 있을 것이다.
