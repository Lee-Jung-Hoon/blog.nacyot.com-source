---
title: "루비와 파이썬에서 함수 호출과 함수 참조에 대한 차이"
date: 2014-12-17 01:35:00 +0900
author: nacyot
tags: ruby, python, 루비, 파이썬, 문법, 함수 호출, 함수 참조
published: true
---

<blockquote class="twitter-tweet" data-conversation="none" lang="ko"><p>파이썬 프로그래머는 이 코드를 보면 a가 출력될 거라고 예상하는 것 같다. 루비 프로그래머라면 당연히 ab고...</p>&mdash; nacyot (@nacyo_t) <a href="https://twitter.com/nacyo_t/status/544497910436466689">2014년 12월 15일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

반응이 있어서(?) 조금 정리해봅니다.

```ruby
def a
  print 'a'
end

def b
  print 'b'
end

def f(arg1, arg2)
  arg1
end

f(a,b)
```

실제로 저 코드를 보시면 무엇이 출력될 것이라고 예상되시나요? 재미있게도 이 코드는 자신이 주로 사용하는 언어에 따라서 그 결과가 다르게 보일 수 있습니다.

저는 루비를 주로 사용해왔고, 이 코드를 보면 그냥 당연히 ab가 출력될 것이라고 생각합니다. 더욱이 이 코드는 Ruby 코드이기 때문에 실제로 실행해봐도 ab가 출력됩니다. 이 코드를 이해하기 위한 핵심은 아래 코드에서

```ruby
f(a, b)
```

a와 b가 실제로는 메서드 호출이라는 점입니다. 루비에서는 a, b와 같은 이름이 주어지면 먼저 현재 맥락에서 이러한 이름을 가진 변수를 찾고, 변수를 찾지 못 하면 이러한 이름을 가진 메서드를 찾아서 호출합니다. 즉, f가 호출되는 시점에, `a`와 `b`는 각각 메서드 호출로 평가되어 그 반환값으로 치환됩니다. 따라서 이 시점에 `a`와 `b`가 실행되고, ab가 출력됩니다. 그리고 루비에서는 `return` 메서드를 명시적으로 사용하지 않을 경우 메서드 본문의 마지막 문장의 평가 결과가 반환된다는 규칙에 따라 `print 'a'`의 평가 결과인 `nil`이 반환됩니다. 따라서 `a` 메서드는 a를 출력하고, nil을 반환하고, b 역시 같은 원리로 동작합니다. 이에 따라 실제로 `f(a, b)`는 `f(nil, nil)`을 호출한 것과 같습니다. 그리고 f함수 안에서 `arg1`은 nil이기 때문에 `f(a, b)`는 결과적으로 nil을 반환합니다.

Python 프로그래머에게 ab라는 출력 결과는 의아할 것입니다. 이 코드를 파이썬으로 치환해해보면 아래와 같습니다.

```python
def a():
    print 'a'

def b():
    print 'b'

def f(arg1, arg2):
    arg1()

f(a, b)
```

실제로 이 코드를 파이썬에서 실행하면 a가 출력됩니다. 이렇게 보면 앞선 루비 코드가 ab를 출력하는 일이 왜 의아한 일인지 알 수 있습니다. 이제 반대 입장에서 이는 루비 프로그래머 입장에서 보면 의아한 일입니다.

어째서 이런 일이 일어난 걸까요. 파이썬에서는 `a`와 `b`가 함수 호출이 아닙니다. a라는 이름으로 함수를 정의하고 나면 `a`를 통해서 함수 자체에 접근할 수 있습니다. 즉 `f(a, b)`에서 `a`와 `b`는 루비와 달리 함수 호출이 아니라, 함수 참조 자체를 f 함수에 넘기는 일이 됩니다. 따라서 f함수 내에서 `arg1()`은 실제로는 `a()`과 같은 표현이고, 따라서 a만 출력됩니다.

<blockquote class="twitter-tweet" data-conversation="none" lang="ko"><p><a href="https://twitter.com/nacyo_t">@nacyo_t</a> 아무 일도 일어나지 않을 것 같은데요..?</p>&mdash; xymz (@extinctspecies_) <a href="https://twitter.com/extinctspecies_/status/544805229816860672">2014년 12월 16일</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

이런 의견도 있었는데, 루비 코드를 파이썬 코드로 (뇌 내에서) 포팅할 때 f 함수의 본문을 `arg1`로 보느냐 `arg()`로 보느냐의 차이에서 오는 것으로 보입니다. `arg1()`로 해석하면 `a()`와 같이 함수 호출이 되어 a를 출력하지만, `arg1`로 보면 단순히 함수 자체를 평가하는 일이 되서 아무일도 일어나지 않습니다(파이썬에는 루비와 같은 마지막 식을 반환한다는 규칙도 없으므로 아무것도 반환되지도 않습니다).

## 결론

루비와 파이썬은 생각보다 다르다, 는 걸로.

이런 시각 차이는 두 가지 점에서 기인하는 듯 합니다. 하나는 단순한 문법 차이고, 하나는 언어 디자인 자체에 있습니다. 파이썬에서는 함수 정의와 다른 객체들에 대해 실질적인 차이 없이 접근할 수 있습니다만, 그런데 루비에서는 그렇지 않습니다. 루비에서 `self.method(:a)`와 같이 메서드 객체를 참조하는 방법이 있긴합니다만, 다른 객체처럼 동등한 방법으로 접근할 방법은 없습니다. 오히려 그렇게 하면 메서드가 호출되어 버립니다. 심지어 `self.method(:a)`와 같이 참조한 메서드를 호출하는 방법도 그냥 호출하면 안되고 `.call` 메서드를 통해서 호출해야합니다.

[아샬 님의 글](https://www.facebook.com/ahastudio/posts/10152981560200929)도 참조해주세요.

## 이 코드에 대해 나눈 대화 전문

<span style="color:blue">**l?????**</span> : 와 루비 이상해요<br/>
<span style="color:darkgreen">**nacyot**</span> : 네???<br/>
<span style="color:blue">**l?????**</span> : <br/>

```ruby
def a
  print 'a'
end

def b
  print 'b'
end

def f(arg1, arg2)
  arg1
end

f(a,b)
```

<span style="color:blue">**l?????**</span> : 이거 결과가<br/>
<span style="color:blue">**l?????**</span> : ㅋ<br/>
<span style="color:blue">**l?????**</span> : 아니<br/>
<span style="color:blue">**l?????**</span> : 이렇게 되면 당연히<br/>
<span style="color:blue">**l?????**</span> : 상식적으로(?)<br/>
<span style="color:blue">**l?????**</span> : a만 출력되야 하는거 아닌가요?<br/>
<span style="color:darkgreen">**nacyot**</span> : 왜 그렇게 생각하시는 거죠?<br/>
<span style="color:darkgreen">**nacyot**</span> : 궁금하네요. 왜 그렇게 생각하신 건지<br/>
<span style="color:blue">**l?????**</span> : ㅋㅋ<br/>
<span style="color:blue">**l?????**</span> : 파이썬을 써서<br/>
<span style="color:blue">**l?????**</span> : 파이썬에서는 a, b 가 그냥 함수인 변수인데 루비는 아닌가보죠?<br/>
<span style="color:blue">**l?????**</span> : 왠지 도발한 느낌인데 ㅋㅋ<br/>
<span style="color:darkgreen">**nacyot**</span> : 함수인 변수라는 게 무슨 말인지 모르겠네요;;;<br/>
<span style="color:darkgreen">**nacyot**</span> : 도발이라는 건 아니고...<br/>
<span style="color:blue">**l?????**</span> : 파이썬은 저렇게 하면<br/>
<span style="color:blue">**l?????**</span> : a가 결과잖아요<br/>
<span style="color:darkgreen">**nacyot**</span> : 루비 <strike>게이</strike>로서 이해가 안 되요.<br/>
<span style="color:blue">**l?????**</span> : 근데 루비는 ab가 나와서<br/>
<span style="color:darkgreen">**nacyot**</span> : 그런가요?<br/>
<span style="color:darkgreen">**nacyot**</span> : 파이썬에선 왜 a가 나오죠?<br/>
<span style="color:blue">**l?????**</span> : 왜냐하면<br/>
<span style="color:blue">**l?????**</span> : 안에서<br/>
<span style="color:blue">**l?????**</span> : arg1만 호출하니까<br/>
<span style="color:blue">**l?????**</span> : f라는 함수 안에서는<br/>
<span style="color:darkgreen">**nacyot**</span> : args1로 a가 넘어가는 거예요?<br/>
<span style="color:blue">**l?????**</span> : 네<br/>
<span style="color:darkgreen">**nacyot**</span> : "a"<br/>
<span style="color:darkgreen">**nacyot**</span> : 음. 파이썬도<br/>
<span style="color:blue">**l?????**</span> : a라는 함수인 변수가<br/>
<span style="color:blue">**l?????**</span> : 넘어가니<br/>
<span style="color:darkgreen">**nacyot**</span> : 아하.<br/>
<span style="color:blue">**l?????**</span> : arg1가<br/>
<span style="color:darkgreen">**nacyot**</span> : a라는 함수가 넘어가니.<br/>
<span style="color:blue">**l?????**</span> : a가 되는거죠<br/>
<span style="color:blue">**l?????**</span> : 네<br/>
<span style="color:purple">**s?????**</span> : a는<br/>
<span style="color:purple">**s?????**</span> : a()<br/>
<span style="color:purple">**s?????**</span> : a = a()<br/>
<span style="color:darkgreen">**nacyot**</span> : 파이썬 얘기 듣게요.<br/>
<span style="color:darkgreen">**nacyot**</span> : 근데<br/>
<span style="color:darkgreen">**nacyot**</span> : 그렇게 되면 arg1은 뭐죠? 함수 안에서.<br/>
<span style="color:darkgreen">**nacyot**</span> : 이건 그냥 함수잖아요.<br/>
<span style="color:blue">**l?????**</span> : 그냥 함수죠<br/>
<span style="color:blue">**l?????**</span> : 네<br/>
<span style="color:darkgreen">**nacyot**</span> : 함수 호출도 아니고.<br/>
<span style="color:blue">**l?????**</span> : 파이썬은 그냥 함수<br/>
<span style="color:blue">**l?????**</span> : 아<br/>
<span style="color:blue">**l?????**</span> : 파이썬은 물론<br/>
<span style="color:darkgreen">**nacyot**</span> : 그럼 왜 a가 찍히죠?<br/>
<span style="color:blue">**l?????**</span> : ()가 있어야 ..<br/>
<span style="color:darkgreen">**nacyot**</span> : 아.<br/>
<span style="color:darkgreen">**nacyot**</span> : ㅇㅋ 이해했습니다.<br/>
<span style="color:blue">**l?????**</span> : 루비는 ()가 없어도 호출 되길래<br/>
<span style="color:purple">**s?????**</span> : 음<br/>
<span style="color:blue">**l?????**</span> : 원래 루비는 그렇게 호출하나보다 라고 생각을 ..<br/>
<span style="color:darkgreen">**nacyot**</span> : 루비 해설해 드릴게요.<br/>
<span style="color:purple">**s?????**</span> : 루비는 함수를 넘기려면 어떻게 하지<br/>
<span style="color:darkgreen">**nacyot**</span> : 루비는 함수를 못 넘깁니다.<br/>
<span style="color:darkgreen">**nacyot**</span> : 리터럴로는<br/>
<span style="color:blue">**l?????**</span> : 아 ..<br/>
<span style="color:darkgreen">**nacyot**</span> : 파이썬은 자바스크립트랑 비슷해요.<br/>
<span style="color:purple">**s?????**</span> : 아 뭔가 꼼수같은 방법 없나요?<br/>
<span style="color:darkgreen">**nacyot**</span> : 저 소스 다시 써주세요.ㅜ<br/>
<span style="color:purple">**s?????**</span> : 애초에 그렇게 안해서 그런가 ㅋ<br/>
<span style="color:darkgreen">**nacyot**</span> : <br/>

```ruby
def a
  print 'a'
end
```

<span style="color:darkgreen">**nacyot**</span> : 를 이해할 필요가 있는데.<br/>
<span style="color:blue">**l?????**</span> : <br/>

```ruby
def a
  print 'a'
end

def b
  print 'b'
end

def f(arg1, arg2)
  arg1
end

f(a,b)
```

<span style="color:darkgreen">**nacyot**</span> : a를 호출하면 a가 찍히겠죠?<br/>
<span style="color:blue">**l?????**</span> : 넵<br/>
<span style="color:darkgreen">**nacyot**</span> : 그러니까 f(a, b)에서<br/>
<span style="color:darkgreen">**nacyot**</span> : 실제는 f(a(), b())이 되서,<br/>
<span style="color:darkgreen">**nacyot**</span> : a,b는 미리 출력됩니다.<br/>
<span style="color:blue">**l?????**</span> : 헐<br/>
<span style="color:blue">**l?????**</span> : 그런거구나<br/>
<span style="color:darkgreen">**nacyot**</span> : 그럼 어떻게 f()가 호출되는 거냐면.<br/>
<span style="color:darkgreen">**nacyot**</span> : <br/>

```ruby
def a
  print 'a'
end
```

<span style="color:purple">**s?????**</span> : a -> a() 요것만 생각하면 이해가 쉬우실듯 ㅋㅋ<br/>
<span style="color:darkgreen">**nacyot**</span> : 이 메서드의<br/>
<span style="color:darkgreen">**nacyot**</span> : 반환값이<br/>
<span style="color:darkgreen">**nacyot**</span> : nil이에요.<br/>
<span style="color:darkgreen">**nacyot**</span> : 그러니까  실제로는 f(a,b)라고 생각하셨지만, 이 시점에서 함수 호출과 반환값으로 치환이 이루어지는 거죠.<br/>
<span style="color:darkgreen">**nacyot**</span> : 따라서 ab가 출력되고<br/>
<span style="color:blue">**l?????**</span> : 아<br/>
<span style="color:blue">**l?????**</span> : 헐 ..<br/>
<span style="color:blue">**l?????**</span> : 실제 인자는 반환값이군요<br/>
<span style="color:darkgreen">**nacyot**</span> : f(nil, nil)을 호출하는 겁니다.<br/>
<span style="color:blue">**l?????**</span> : 아 ..<br/>
<span style="color:blue">**l?????**</span> : 이해가 한 방에 됐네요 감사합니다. ㅜ<br/>
<span style="color:darkgreen">**nacyot**</span> : f 내부에서 args1이 nil이 되니까.<br/>
<span style="color:darkgreen">**nacyot**</span> : 저 함수는 ab를 출력하고 반환값이 nil이 되는 거죠<br/>
