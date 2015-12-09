---
title: 루비와 익명 함수 -  블록(block), Proc(절차, procedure) 객체와 람다(lambda) 함수의 차이 이해하기
date: 2015-12-08 01:36:00 +0900
author: nacyot
tags: programming, lambda, ruby, proc, block, anonymous_function, javascript
categories: programming
title_image: http://i.imgur.com/TVYlS05.png
published: true
toc: true
comment: true
---

> [루비 Advent Calendar 2015](https://ruby-korea.github.io/advent-calendar/) 7일차로 참석합니다.

루비에서 가장 특징적이고 많이 사용되는 문법이 바로 블록입니다. 루비에서는 블록 문법을 통해서 하나의 익명 함수를 손쉽게 함수에 넘겨줄 수 있습니다. 대부분의 반복문을 비롯해 인터페이스로도 자주 사용되기 때문에 익명 함수 개념을 이해하는 것은 매우 중요합니다. 블록을 사용하지 않더라도 루비에서는 명시적으로 익명 함수 객체를 생성할 수 있습니다. 익명 함수를 만드는 두 가지 대표적인 방법이 바로 Proc 객체와 `lambda`문을 사용하는 것입니다. 이 글에서는 루비에서의 익명 함수와 Proc 객체와 `lambda`문으로 생성된 익명 함수의 차이점을 살펴보겠습니다.

<!--more-->

## Proc(절차, Procedure) 객체 이해하기

루비에서는 Proc 클래스를 통해서 익명 함수를 생성할 수 있습니다. 여기서 Proc은 Procedure의 줄임말로 어떤 처리 과정(절차)을 담고있다는 의미입니다. Proc 또한 일반적인 루비 클래스와 다르지 않으므로 Prow.new 메서드를 통해서 객체를 생성할 수 있습니다.

```ruby
Proc.new
# ArgumentError: tried to create Proc object without a block
```

설명이 조금 까다로워집니다만, `Proc.new` 메서드는 블록을 통해서 절차(루비 표현식들)를 넘겨받습니다. 설명이 귀찮아진다는 의미는 블록 자체도 익명 함수기 때문입니다. 루비에서는 메서드 뒤에  `do...end` 형태로 블록이라는 특별한 문법을 사용할 수 있습니다. `do`와 `end` 사이에는 루비 표현식이 들어갑니다. 이 `do...end` 사이의 표현식들은 실행되지 않은 채로 익명 함수로서 그대로 실행하는 메서드에 전달됩니다. 여기서는 이 부분에 대해서는 다루지 않을 것입니다. 어쨌건 루비 표현식들이 고스란히 함수로 전달된다는 것이 중요합니다.

`Proc.new`도 블록을 통해서 익명 함수를 전달받습니다.

```ruby
Proc.new do
  puts 'Hello, world!'
end
# => #<Proc:0x007f99f12c6bf8@(pry):2>
```

`Proc.new`는 Proc 객체를 반환합니다. 이 생성자 메서드는 넘겨받은 익명 함수에 대해서 어떠한 일도 하지않고, 익명 함수를 그대로 저장을 합니다. 앞서 말했듯이 블록에 쓰여진 루비 표현식은 곧바로 실행되지 않습니다. 따라서 `puts 'Hello, world!'`는 출력되지 않습니다.

### Proc 객체 실행하기

이 Proc 객체는 이제 원하는 시점에 언제라도 실행할 수 있습니다. 다음 예제에서는 이 Proc 객체를 변수에 대입하고 실행하는 방법을 살펴보겠습니다. Proc 객체를 실행하는 방법은 크게 3가지가 있습니다. 첫번째는 `.call()` 메서드 호출입니다. 제일 명확한 표현법입니다. 이외에도 `.()`과 `[]`와 같은 조금은 낯설게 보이는 방법도 있습니다. 기본적으로 `.call()`과 다르지 않습니다.

```ruby
# 여기서는 편의상 do...end 대신 { }을 사용했습니다
p = Proc.new { puts 'Hello, world!'}

p.call()
# Hello, world!

p.()
# Hello, world!

p[]
# Hello, world!
```

형태는 다르지만 모두 같은 방식으로 동작하는 걸 알 수 있습니다.

파이썬이나 자바스크립트 같은 언어를 사용해왔다면 이런 표현이 거슬릴 지도 모릅니다. 자바스크립트에서는 익명 함수와 기명함수의 실질적인 차이가 없습니다. 따라서 자바스크립트에서는 아래의 두 방법으로 함수를 선언한 결과가 실질적으로 같습니다.

```javascript
// 일반적인 함수 선언
function hello1(){ console.log('Hello, world!') }

// 익명 함수를 사용한 함수 선언
var hello2 = function(){ console.log('Hello, world!) };
```

함수를 호출하는 방법도 같습니다.

```javascript
hello1()
// Hello, world!

hello2()
// Hello, world!
```

이는 루비와는 명백히 다릅니다. 위의 루비 예제에서는 익명 함수(Proc 객체)를 proc에 대입했습니다만, 함수처럼 직접 호출하는 것은 불가능합니다.

```ruby
p()
# NoMethodError: undefined method `a' for main:Object
```

파이썬이나 자바스크립트에서는 함수 이름으로 접근하면 함수 자체에 접근할 수 있고 이를 직접 호출할 수 있지만 루비에서는 그렇지 않습니다. NoMethodError 예외가 발생하는 이유는 간단합니다. 말그대로 p라는 이름으로 정의된 함수가 존재하지 않기 때문입니다. 이 이유를 이해하기 위해서는 루비의 메서드 호출 방식을 이해할 필요가 있습니다만, 여기서는 익명 함수와 기명 함수가 존재하는 공간이 다르다는 정도에서 넘어가겠습니다.

이 주제에 대해서는 [루비와 파이썬에서 함수 호출과 함수 참조에 대한 차이](http://blog.nacyot.com/articles/2014-12-17-diffrence-of-ruby-and-python/)에서 좀 더 자세히 다루고 있으니 참고해주시기 바랍니다.

## 블록

블록은 엄밀히 말하면 Proc 객체는 아닙니다(이에 대해서는 뒤에서 설명합니다). 단, 메서드 선언시에 `&` 연산자를 통해서 블록을 명시적으로 Proc 객체로 받아올 수 있습니다.

```ruby
def hello(&b)
  b.call()
end

hello do
  puts 'Hello, world!
end'
# Hello, world!
```

## proc

Kernel#proc 메서드도 있습니다. 이 메서드는 `Proc.new`와 같습니다.

```ruby
p = proc { puts 'Hello, world!' }
p.call()
# Hello, world!
```

## Proc 객체와 람다(lambda)

흥미롭게도(그리고 혼란스럽게도) 루비에는 `lambda`라고 하는 Proc 객체를 생성하는 또 다른 방법이 존재합니다. 먼저 `lambda`를 통해서 Proc 객체를 만들어보겠습니다.

```ruby
l = lambda{ puts 'Hello, world!' }

l.class
# Proc

l.call()
# Hello, world!
```

루비 1.9부터는 신택스 슈가인 `->`를 사용할 수도 있습니다.

```ruby
->{ puts 'Hello, world!' }
```

왜 `lambda`가 존재하는 걸까요? 람다라는 표현을 거슬러 올라가면 람다 대수가 나옵니다. 람다 대수는 알론조 처치에 의해 만들어진 수학 체계입니다. 이 체계가 흥미로운 것은 하나의 인자를 받는 함수들만을 사용하면서, 튜링 컴플리트하다는 점입니다. 즉, 완전히 수학적이면서 튜링 머신에서 가능한 모든 계산이 가능하다는 의미입니다. 단, 여기서 `lambda`라는 표현은 엄밀한 의미에서 수학적인 표현이라기보다는 루비 이전의 언어들에서 익명 함수를 의미할 때 사용해오던 관용구라고 이해하는 게 좋습니다. 루비에서는 이렇게 생성된 객체가 일반적인 Proc 객체보다 좀 더 함수답게 작동한다는 차이점을 가지고 있습니다.

### Proc#lambda? 를 사용한 lambda 여부 확인

먼저 본격적으로 차이점을 알아버기 전에 일반적인 Proc 객체와 `lambda`로 만들어진 객체를 구분하는 방법을 살펴보겠습니다. Proc 객체의 `lambda?` 메서드로 `lambda`로 생성된 함수인지를 확인할 수 있습니다.

```ruby
Proc.new{}.lambda? # => false
proc{}.lambda?     # => false
lambda{}.lambda?   # => true
->{}.lambda?       # => true
```

참고로 일반적인 메서드를 객체화해서 Proc 객체로 변환하면 lambda Proc 객체가 됩니다.

```ruby
def hello; end
hello_method = method(:hello)
hello_method.to_proc.lambda? # => true
```

더 자세한 내용은 [루비 문서](http://ruby-doc.org/core-1.9.3/Proc.html#method-i-lambda-3F)에서 확인할 수 있습니다.

### 인자 검사 방식의 차이

그 첫 번째 차이점으로 `lambda`로 만들어진 Proc 객체는 인자 개수를 엄격하게 검사합니다. 일반적으로 블록에서는 블록 인자라는 독특한 방법으로 인자를 받습니다. 여기서는 하나의 인자를 받는 Proc 객체를 만들고, 인자 개수를 바꿔가며 실행해보겠습니다.

```ruby
hello = Proc.new { |name| puts 'Hello, #{name}!'}
hello.call()
# Hello, !

hello.call('Jack')
# Hello, Jack!

hello.call(1, 2, 3, 4, 5)
# Hello, 1!
```

정의에서는 하나의 인자를 사용하지만, 인자 개수가 달라지더라도 에러가 발생하지 않습니다. 이런 점에서 Proc 객체는 이름 그대로 **절차**만 저장된 객체라고 할 수 있습니다. 반면  `lambda`로 만든 Proc 객체는 다르게 작동합니다.

```ruby
hello = lambda(name){ puts "Hello, #{name}!" }

# 신택스 슈가를 사용할 때는 다음과 같이 정의합니다
->(name){ puts "Hello, #{name}!"}

hello.call()
# ArgumentError: wrong number of arguments (0 for 1)

hello.call('Jack')
# hello, Jack!

hello.call(1,2,3,4,5)
# ArgumentError: wrong number of arguments (5 for 1)
```

인자를 넘기지 않거나 더 많은 인자를 넘긴 경우 `ArgumentError` 예외가 발생한 것을 볼 수 있습니다.

### return 작동 방식의 차이

`proc`과 `lambda`의 또 다른 차이 점은 `return`의 작동방식입니다. 먼저 일반적은 Proc 객체가 동작하는 방식을 살펴보겠습니다.

```ruby
def return_two(&p)
  p.call
  return 2
end

return_two(&Proc.new { return 1 })
# LocalJumpError: unexpected return
```

밖에서 Proc 객체를 넘겨받으면 `LocalJumpError` 예외를 발생시킵니다. 이는 `return`이 어떤 맥락에서 해석되어야하는 지가 불분명하기 때문입니다.(Proc 객체? 아니면 Proc 객체를 실행하는 문맥?)

다음은 밖에서 넘겨받는 대신 안에서 Proc 객체를 생성하는 예제입니다.

```ruby
def return_two()
  p = Proc.new { return 1 }
  p.call
  return 2
end

return_two
# => 1
```

이번에는 1을 반환합니다. 놀랍게도 Proc 객체의 `return` 문이 `return_two`의 `retrun`으로 실행된 것을 알 수 있습니다. 이런 의도로 Proc 객체를 쓰는 일은 아마 거의 없을 듯 합니다.

그럼 이번에는 `lambda`로 만든 Proc 객체를 실행해보죠

```ruby
def return_two(&p)
  p.call
  return 2
end

return_two(&lambda{ return 1 })
# => 2
```

이번에는 2를 반환했습니다. 좀 더 자세히 살펴보기 위해서 `p.call`의 반환값을 출력해보겠습니다.

```ruby
def return_two(&p)
  puts p.call
  return 2
end

return_two(&lambda{ return 1 })
# 1
# => 2
```

`p.call`의 반환값이 1이 되는 것을 알 수 있습니다. 이를 통해서 `lambda` 함수에서 `return` 문을 사용하면 Proc 객체, 즉 익명 함수 자체의 반환이 되는 것을 알 수 있습니다. 따라서 `lambda` 함수에서는 1을 반환하고, `return_two` 함수에서는 의도한 대로 넘겨준 lambda Proc 객체와는 무관하게 2를 반환합니다.

### break 작동 방식의 차이

`break`도 `return`과 비슷한 차이가 있습니다. Proc 객체에서 break를 사용하면 LocalJumpError 예외를 발생시킵니다. `return` 문의 경우와 마찬가지입니다.

```ruby
0.upto(3, &Proc.new{|i| puts i; break if i == 2 })
# 0
# 1
# 2
# 3
# LocalJumpError: break from proc-closure
```

반면에 lambda를 사용하면 break는 lambda Proc 객체 안으로 한정됩니다. 따라서 반복문 안에서 아무런 영향도 끼치지 않고 `i==2` 조건을 만족할 때 lambda 안에서 break가 실행될 뿐입니다.

```ruby
0.upto(3, &lambda{|i| puts i; break if i == 2 })
# 0
# 1
# 2
# 3
# => nil
```

### 블록과 Proc 객체의 차이

블록은 Proc과 비슷하지만 엄밀히 말하면 Proc 객체와는 조금 다릅니다. 블록은 메서드와 결합된 문맥에서만 존재하기 때문에 이를 Proc 객체로 만들기는 어렵습니다. 다음 예제에서는 반복자를 통해서 break가 어떻게 다르게 작동하는 지를 살펴봅니다. 블록에서는 break가 정상적으로 작동합니다.

```ruby
0.upto(10) { |i| puts i; break if i == 3 }
# 0
# 1
# 2
# 3
# => nil
```

이번에는 정확히 같은 일을 하는 Proc 객체를 넘겨줍니다. 

```ruby
0.upto(10, &Proc.new{ |i| puts i; break if i == 3 })
# 0
# 1
# 2
# 3
# LocalJumpError: break from proc-closure
```

LocalJumpError가 발생합니다. 이는 넘겨진 함수가 클로저로 실행되는데, 그 안에서 break를 사용하고 있기 때문에 발생하는 예외입니다. 순수한(?) 블록에서는 이 문제를 적절히 해결해주는 걸 알 수 있습니다.

## 결론

여기까지 배운 지식을 활용하면 다음과 같은 이상해보이는 구문이 정상적인 루비 구문이라는 걸 이해할 수 있습니다.

```ruby
->(){}[]
# nil
```

이게 요지는 아닙니다만, 루비에서 블록과 익명 함수 개념에 대한 이해는 아무리 강조해도 지나치지 않습니다. 많이들 어려움을 느끼는 부분도 Proc과 lambda처럼 비슷해보이면서도 다른 것들입니다. 특히 proc이나 lambda는 Kernel 클래스에 있어서 문법처럼 보이기도 하고 함수처럼 보이기도 하고 분명 헷갈리기 쉬운 요소입니다. 나아가 lambda에는 `->`라는 신택스 슈가도 있고, 이러한 익명 함수를 실행시키는 방법으로는 `.call()`, `.()`, `[]`와 같이 세 가지나 준비되어 있습니다. 처음 보면 당황스러울 수도 있지만 루비에서는 다들 많이 사용되는 표현이므로 확실히 익혀두는 게 좋습니다.

## 참고자료

* [Ruby 2.2.0 リファレンスマニュアル(레퍼런스 매뉴얼) - module function Kernel.#lambda](http://docs.ruby-lang.org/ja/2.2.0/method/Kernel/m/proc.html)
* [ruby-doc.org - Proc](http://ruby-doc.org/core-2.2.0/Proc.html)
