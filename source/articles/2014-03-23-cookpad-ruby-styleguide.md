---
title: "쿡패드(Cookpad) 루비(ruby) 스타일 가이드"
date: 2014-03-23 19:40:00 +0900
author: nacyot
license: cc-by
tags: cookpad, ruby, style_guide, programming_language, translation, programming
categories: programming
published: true
title_image: http://i.imgur.com/JF65kMh.jpg
---

이 문서는 Cookpad의 [Ruby Style Guide][cookpad-style-guide]를 [nacyot][nacyot]이 한국어로 번역한 문서입니다. 번역된 문서는 [Github 저장소][cookpad-style-guide-kr]에서 관리되고 있으며 원본은 [여기][cookpad-style-guide]에서 찾아볼 수 있습니다. 이 문서는 [cc-by][cc-by] 라이센스를 따릅니다.

[cookpad-style-guide]: https://github.com/cookpad/styleguide
[cookpad-style-guide-kr]: https://github.com/nacyot/styleguide
[nacyot]: http://nacyot.com
[cc-by]: http://creativecommons.org/licenses/by/3.0/

<!--more-->

# 목차

- [루비(Ruby) 버전](#ruby-version)
- [들여쓰기](#indentation)
- [공백](#whitespaces)
- [빈 행](#empty-lines)
- [문자 인코딩과 매직 코멘트](#character-encoding-and-magic-comments)
- [한 줄의 글자수 제한](#line-columns)
- [숫자](#numbers)
- [문자열](#strings)
- [정규표현식](#regular-expressions)
- [배열](#arrays)- [해시](#hashes)
- [계산식](#operations)
- [대입식](#assignments)
- [제어구조](#control-structures)
- [메소드 호출](#method-calls)
- [BEGIN과 END](#begin-and-end)
- [모듈과 클래스 정의](#module-and-class-definitions)
- [메소드 정의](#method-definitions)
- [변수](#variables)

# 루비(Ruby) 스타일 가이드

## 시작하며

이 문서는 주식회사 쿡패드(Cookpad)의 루비 코드 표준 스타일을 정의한 문서입니다.
이 문서에서는 최소한 실력을 갖춘 Ruby 프로그래머라면 누구라도 읽기 쉬운 코드가 되도록 가독성과 일관성에 무게를 둔 스타일을 정의하고 있습니다. 'bad'가 붙어있는 예제는 사용해서는 안 되는 표현이란 의미보다 일관성을 위해 지양해야할 표현들입니다.

<a name="ruby-version"></a>

## 루비(Ruby) 버전

- **[SHOULD]** 루비 2.0 이상의 버전을 사용하는 프로젝트에서는 키워드 인수, 심볼 리터럴(`%i`)을 비롯한 루비 2.0에서 추가된 기능을 적극 활용한다.

<a name="indentation"></a>

## 들여쓰기

- **[MUST]** 한 단계 들여쓰기는 스페이스 두 번을 사용한다. 들여쓰기로 탭을 사용하지 않는다.
- **[MUST]** 메소드 체인이 졌을 때 마지막 메소드에 블록을 넘겨야한다면, 마지막 메소드를 받는 리시버를 별도의 로컬 변수에 대입하고 이 변수에 메소드를 호출하면서 블록을 넘겨준다.

    ```ruby
    # good
    posts = Post.joins(:user)
      .merge(User.paid)
      .where(created_at: target_date)
    posts.each do |post|
      next if stuff_ids.include?(post.user_id)
      comment_count += post.comments.size
    end

    # bad
    posts = Post.joins(:user)
      .merge(User.paid)
      .where(created_at: target_date).each do |post|
        next if stuff_ids.include?(post.user_id)
        comment_count += post.comments.size
      end
    ```

- **[SHOULD]** 식이 완결되지 않고 줄바꿈이 이루어질 때 줄바꿈된 줄부터는 이전의 행보다 한 단계 더 들여쓴다.

    ```ruby
    # good
    User.active.
      some_scope(foo).
      other_scope(bar)

    # bad
    User.active.
    some_scope(foo).
    other_scope(bar)
    ```

<a name="whitespaces"></a>

## 공백

- **[MUST]** 줄 마지막에 공백을 넣지 않는다.

<a name="empty-lines"></a>

## 빈 행

- **[MUST]** 파일 마지막에 빈 행을 넣지 않는다.

<a name="character-encoding-and-magic-comments"></a>

## 문자 인코딩과 매직 코멘트

- **[MUST]** 특별한 이유가 없다면 인코딩은 UTF-8을 사용한다.
- **[SHOULD]** 루비 2.0 부터 기본 인코딩이 UTF-8이므로 인코딩 지정을 위한 별도의 매직 코멘트는 사용하지 않는다.
- **[MUST]** 매직 코멘트를 사용해야 할 때는 아래 형식을 사용한다.

    ```ruby
    # coding: utf-8
    ```

<a name="line-columns"></a>

## 한 줄의 글자수 제한

- **[SHOULD]** 특별한 이유가 없다면 한 줄은 80자 이하로 작성한다. 이 때 전각 문자는 2글자로 취급한다.
- **[MUST]** 어떠한 경우에도 한 줄은 128자 이내로 작성한다.

<a name="numbers"></a>

## 숫자

- **[SHOULD]** 자리수가 큰 10진수 숫자 리터럴을 사용할 때는 읽기 좋게 3자리마다 밑줄을 넣는다.
  - 예: `1_000_000.001_023`
- **[SHOULD]** 자리수가 큰 2진수나 16진수를 사용할 때는 읽기 좋게 4자리마다 밑줄을 넣는다.
  - 예: `0xABCD_1234`
- **[SHOULD]** 16진수를 사용할 때는 알파벳 대소문자 어떤 것을 사용해도 무관하나 하나의 파일에서는 일관성을 지켜서 사용한다.
- **[SHOULD]** 루비 2.1 이후 버전을 사용한다면 분수 표현은 `r` 접미사를 사용한다.
  - 예: `1/2r #=> (1/2)`
- **[SHOULD]** Ruby 2.0.0 이전 버전을 사용한다면 분수 표현은 `Integer#quo` 메소드를 사용한다.
  - 예: `1.quo(2) #=> (1/2)`
- **[SHOULD]** Ruby 2.1 이후 버전을 사용한다면 복수소 표현은 `i`나 `ri` 접미사를 사용한다.
  - 예: `1 + 2i #=> (1+2i)`

<a name="strings"></a>

## 문자열

- **[SHOULD]** 빈문자열은 `''`을 사용한다.
- **[SHOULD]** 특별한 이유가 없다면 `String.new` 메소드로 문자열을 생성하지 않는다.
- **[MUST]** 문자열 안에서 이스케이프 시켄스가 최소화될 수 있도록 적절한 구분문자열을 선택한다.
- **[SHOULD]** `%` 문법으로 문자열 리터럴을 사용할 때는 괄호를 구분 문자열로 사용한다.이 때 괄호의 종류는 어떤 걸 사용해도 무방하며, 아래와 같은 특별한 경우에는 다른 기호를 구분자로 사용해도 무방하다.

    ```ruby
    OPEN_PARENTHESES = %!({[!    
    ```

- **[MUST]** `Object#to_s`만 호출하는 용도로 위해 문자열 보간(interpolation)을 사용하지 않는다.예) `"#{obj.to_s}"` -> `obj.to_s`
- **[MUST]** 문자열 보간을 사용할 때 중괄호를 생략할 수 있는 경우가 있지만, 생략하지 않고 반드시 중괄호를 사용한다.
- **[SHOULD]** (Ruby 1.9+) Unicode 문자를 이스케이스 시켄스로 입력할 때는 `"\xE3\x8C\xB3"` 방식이 아니라 `"\u{3333}"`와 같이 `\u`를 사용한다.루비 1.8 버전을 지원해야하는 스크립트라면 적용하지 않는다.
- **[SHOULD]** 루프에서 문자열 리터럴을 사용하지 말 것.여기서 루프란 `while`, `until`, `for`을 비롯해 `each`와 같은 블록을 사용하는 반복자 표현을 의미한다.
- **[SHOULD]** 문자열 리터럴들을 `String#+` 메소드를 사용해서 연결하지 않는다.문자열 보간법을 사용한다.
- **[MUST]** 문자열에 파괴적인 연결 연산자인 `+=`를 사용하지 않는다.`String#<<` 메소드나 `String#concat` 메소드를 사용한다.

<a name="regular-expressions"></a>

## 정규표현식

- **[SHOULD]** 역참조하지 않는 그룹은 사용하지 않는다.`(?:...)`을 대신 사용.
- **[SHOULD]** 복잡한 정규표현식을 사용할 때는 `x` 옵션을 사용해 줄바꿈, 공백, 주석 (`(?# ...)`)을 사용해 가독성을 높인다.
  - 자세한 예는 [uri/common.rb 에 정의된 정규표현식](https://github.com/ruby/ruby/blob/trunk/lib/uri/common.rb#L457)을 참조.

<a name="arrays"></a>

## 배열

- **[MUST]** 배열 리터럴을 여러 줄로 작성할 때는 `[`와 첫번째 요소 사이에 하나의 공백을 두고 요소들의 들여쓰기를 맞춘다.

    ```ruby
    # good
    [ :foo,
      :bar,
      :baz
    ]

    # bad
    [:foo,
      :bar,
      :baz
    ]
    ```

- **[MUST]** 대입식에서 배열 리터럴을 여러 줄에 걸쳐 작성할 때는 `[` 뒤에서 줄바꿈하고 요소를 입력하는 줄들은 한단계씩 들여쓰기 하고 배열을 닫는 `]`는 별도의 줄에 적는다. 이 때 `]`는 `[`이 있는 줄의 첫 부분과 들여쓰기를 맞춘다.

    ``` ruby
    # good
    array = [
      :foo,
      :bar,
      :baz,
    ]

    # bad
    array = [ :foo,
              :bar,
              :baz, ]

    # bad
    array = [ :foo,
              :bar,
              :baz,
            ]

    # bad
    array = [
      :foo,
      :bar,
      :baz, ]
    ```

- **[SHOULD]** 여러줄로 된 배열 리터럴을 사용할 때는 마지막 요소 다음에도 `,`를 입력한다.
- **[SHOULD]** 문자열로만 구성된 배열을 만들 때는 `%w(...)`이나 `%W(...)` 문법을 사용한다.

    ```ruby
    # good
    words = %w(foo bar baz)

    # bad
    words = ['foo', 'bar', 'baz']
    ```

- **[MUST]** 빈 배열은 `[]`을 사용한다.
- **[MUST]** 인수 없이 `Array.new` 메소드를 사용하지 않는다.
- **[SHOULD]** 같은 요소를 `n` 개 가진 배열을 초기화할 때는 `Array.new(n, obj)`을 사용한다.`[obj] * n` 을 사용하지 않는다.
- **[SHOULD]** 범위(Range) 리터럴을 배열로 변환할 때는 `Range#to_a` 메소드를 사용하지 않고, `[*range]` 표현을 사용한다.

    ```ruby
    # good
    [*1..10]  #=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    # bad
    (1..10).to_a  #=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    ```

<a name="hashes"></a>

## 해시

- **[MUST]** 해시 리터럴을 한 줄에 작성할 때는 `{` 와 첫번째 요소 사이와 마지막 요소와 `}` 사이에 각각 하나의 공백을 넣는다.

    ```ruby
    # good
    { hoge: 1, fuga: 2 }
    # bad
    {hoge: 1, fuga: 2}
    ```

- **[MUST]** 해시 리터럴에서 Symbol을 key로 사용할 때 HashRocket(Ruby 1.8에서 사용되던 `=>`을 사용한 표현. 예: `{ :foo => 42 }`)문법을 사용하지 않는다.

    ```ruby
    # good
    { first: 42,
      second: 'foo',
    }
    # bad
    { :first => 42,
      :second => 'foo',
    }
    ```

- **[SHOULD]** 해시 리터럴의 key가 symbol이지만 `.`, `-`와 같은 기호를 사용할 때는 HashRokcet 문법만 사용한다.

    ```ruby
    # good
    { :cookpad => 42,
      :'cookpad.com' => 'foo',
    }
    # bad
    { cookpad: 42,
      :'cookpad.com' => 'foo',
    }
    ```

- **[MUST]** 빈 해시는 `{}`를 사용한다.
- **[MUST]** 해시만 따로 여러줄에 걸쳐서 작성할 때는 `{` 다음에 바로 첫번째 요소를 입력하고, 두번째 요소부터는 한 단계 들여쓰기 한다. `}`는 별도의 행에 작성하고, `{`를 입력한 줄의 앞부분과 들여쓰기를 맞춘다.

    ```ruby
    # good
    { first: 42,
      second: 'foo',
    }

    # bad
    {
      first: 42,
      second: 'foo',
    }

    # bad
    { first: 42,
    second: 'foo',
    }
    ```

- **[MUST]** 대입식에서 해시 리터럴을 여러 줄에 걸쳐서 작성할 때는 `{` 뒤에서 줄바꿈하고 각 요소들은 한단계 들여쓰기해서 작성한다. `}`는 별도의 줄에 입력하고 `{`을 입력한 줄의 앞부분과 들여쓰기를 맞춘다.

    ```ruby
    # good
    hash = {
      first: 42,
      second: 'foo',
    }

    # bad
    hash = { first: 42,
             second: 'foo',
           }

    # bad
    hash = { first: 42,
             second: 'foo',
    }

    # bad
    hash = { first: 42,
      second: 'foo',
    }

    # bad
    hash = {
    first: 42,
    second: 'foo',
    }
    ```

- **[SHOULD]** 여러 줄로 걸쳐 해시 리터럴을 작성할 때는 마지막 요소 다음에도 `,`를 넣는다.
- **[SHOULD]** 심볼이 문자열보다 검색 속도가 더 빠르므로, 해키 키로는 문자열보다 심볼을 사용한다.

  ```ruby
  # good
  { foo: 1, bar: 2 }

  # bad
  { 'foo' => 1, 'bar' => 2 }
  ```

- **[SHOULD]** (Ruby 1.9+) 해시 리터컬의 키가 전부 Symbol 리터럴이면 `{ key: value }` 방식을 사용한다.이 때 `:` 뒤에 공백을 넣을 것.

<a name="operations"></a>## 계산식

- **[SHOULD]** 연산자 양쪽에 모두 공백을 사용할 것.단 `**` 연산자를 사용할 때는 양쪽 모두 공백을 넣지 않는다.
- **[MUST]** `and`, `or`, `not`은 사용하지 않는다.
  - 단 `式 or raise 'message'`과 같이 사용할 때 `or`은 사용해도 된다.
- **[MUST]** 조건 연산자를 중첩적으로 사용하지 않는다.
- **[MUST]** 조건 연산자를 여러줄에 작성하지 않는다.

    ```ruby
    # good
    fizzbuzz = if n % 3 == 0
        n % 5 == 0 ?'fizzbuzz' : 'fizz'
      else
        n % 5 == 0 ?'buzz' : "#{n}"
      end

    # bad
    fizzbuzz = n % 3 == 0 ?(n % 5 == 0 ?'fizzbuzz' : 'fizz') : (n % 5 == 0 ?'buzz' : "#{n}")

    # bad
    fizzbuzz = n % 3 == 0 ?      (n % 5 == 0 ?'fizzbuzz' : 'fizz') :
      (n % 5 == 0 ?'buzz' : "#{n}")
    ```

<a name="assignments"></a>

## 대입식

- **[MUST]** 대입 기호(=) 양쪽에는 공백을 넣는다.
- **[MUST]** 대입식에 조건식을 사용하지 않는다.

<a name="control-structures"></a>

## 제어구조

- **[SHOULD]** `if !condition` 대신 `unless condition`을 사용한다.
- **[SHOULD]** `while !condition` 대신 `until condition`을 사용한다.
- **[SHOULD]** `unless`를 사용할 때는 `else`를 사용하지 않는다.
- **[MUST]** `if`, `unless`, `case` 조건식을 사용할 때는 줄바꿈을 사용한다.조건식 본문은 조건식과 같은 줄에 입력하지 않는다.
- **[MUST]** `if`, `unless`, `case`를 사용할 때는 `then`과 `:`를 사용하지 않는다.
- **[MUST]** `while`과 `until` 조건식을 사용할 때는 줄바꿈을 사용한다.조건식 본문은 조건식과 같은 줄에 입력하지 않는다.
- **[MUST]** `while`, `until`문을 사용할 때는 `do`나 `:`를 사용하지 않는다.
- **[SHOULD]** `unless`와 `until` 조건식에는 `||`으로 조건을 연결하지 않는다.
- **[SHOULD]** 조건식과 본문 코드가 짧으면 본문 코드 뒤에 조건 변경자를 사용할 것.
- **[SHOULD]** 조건식이 여러줄로 길어질 때는 조건을 별도의 메소드로 추출하고 적절한 이름을 붙여 사용한다.
- **[MUST]** 대입식에서 제어구조를 사용해야할 때는 본문 코드를 2단계 들여쓰고 마지막 `end`는 본문보다 한단계 덜 들여쓴다.

    ```ruby
    # good
    result = if condition
        body_code
      end

    # good
    result =
      if condition
        body_code
      end

    # bad
    result = if condition
      body_code
    end

    # bad
    result = if condition
               body_code
             end
    ```

- **[MUST]** return, next, break가  의미 있는 값을 리턴하지 않을 때는, 각 키워드 뒤에 어떤 식도 작성하지 않는다.
   - 단 컨트롤러의 액션에서 redirect_to나 render와 같은 계속 처리를 선언하는 메소드는 return이나 next 뒤에서 호출해도 무방하다.

<a name="method-calls"></a>

## 메소드 호출

- **[MUST]** 메소드 호출 시 괄호는  경우를 제외하고는 생략하지 않는다.
- **[MUST]** 인수가 없는 메소드를 호출할 때는 괄호를 생략한다.
- **[MUST]** DSL-like 메소드를 호출할 때는 메소드 호출 시 괄호를 생략해도 무방하다.하지만 첫번째 인수 전체가 괄호로 둘러쌓여있다면 경고가 발생하므로 괄호를 생략하지 않는다.DSL-like 메소드란 아래의 메소드를 의미한다.
   - p, print, puts, require 등의 글로벌 함수
   - attr_reader이나 private 같은 클래스와 모듈 정의에서 선언적으로 사용되는 메소드(Rails 등의 프레임워크에서 제공하는 것을 포함).
   - redirect_to와 render 등 ActionController가 제공하는 액션에 대해 계속 처리를 선언하는 메소드.
   - 이외에 DSL을 위해 준비된 메소드.
- 메소드 호출 안에서 메소드를 호출하는 때는 다른 규칙에 위배되지 않는 한에서 가장 바깥의 메소드 호출에서 괄호를 생략해도 무방하다.
- **[MUST]** 메소드 이름과 메소드 호출을 의미하는 괄호 사이에는 공백을 넣지 않는다.
- **[SHOULD]** 인자 마지막에 해시 리터럴을 사용할 때는 해시 리터럴 괄호를 생략한다.

    ```ruby
    # good
    foo(1, 2, foo: :bar, baz: 42)

    # bad
    foo(1, 2, { foo: :bar, baz: 42 })
    ```

- **[MUST]** 블록의 리턴값이 의미를 가지지 않는 메소드를 호출할 때는 `do`/`end` 방식으로 블록을 사용한다.예) 블록에서 부작용을 일으킬 때(변수 변환 등).
- **[MUST]** 블록의 리턴값이 의미를 가지는 메소드를 호출할 때는 중괄호를 사용해 블록을 사용한다.

    ```ruby
    # good
    puts [1, 2, 3].map {|i|
      i * i
    }

    # bad
    puts [1, 2, 3].map do |i|
      i * i
    end

    # good
    [1, 2, 3].map {|n|
      n * n
    }.each {|n|
      puts Math.sqrt(n)
    }

    # bad
    [1, 2, 3].map do |n|
      n * n
    end.each do |n|
      puts Math.sqrt(n)
    end
    ```

- **[MUST]** 블록을 사용하는 메소드 호출을 한 줄로 작성할 때는 중괄호를 사용한다.
- **[MUST]** `do`/`end`를 사용할 때는 `do 앞뒤로 공백을 넣으며, 블록 인자 뒤에 줄바꿈을 넣고 `end`는 독립된 행으로 작성한다.블록 본문은 한 단계 들여쓰며 `end`의 들여쓰기는 메소드를 호출하는 첫 행에 맞춘다.

    ```ruby
    # good
    [1, 2, 3].each do |num|
      puts num
    end

    # bad
    [1, 2, 3].each do |num|
        puts num
      end

    # bad
    [1, 2, 3].each do |num|
                     puts num
                   end

    # bad
    [1, 2, 3].each do |num| puts num end
    ```

- **[MUST]** 중괄호를 사용하는 블록은 `{` 앞에 공백을 하나 사용한다.
- **[MUST]** 중괄호를 사용하는 블록을 한 줄에 작성하는 경우 `{`이나 블록 인자와 본문 코드, 본문 코드와 `}` 사이에 공백을 하나씩 넣는다.

    ```ruby
    # good
    [1, 2, 3].each {|num| puts num }
    [1, 2, 3].each { |num| puts num }

    # bad
    [1, 2, 3].each {|num| puts num}

    # bad
    [1, 2, 3].each { |num| puts num}

    # good
    10.times { puts 'Hello world' }

    # bad
    10.times {puts 'Hello world' }

    # bad
    10.times {puts 'Hello world'}

    # bad
    10.times { puts 'Hello world'}
    ```

- **[SHOULD]** 메소드를 호출할 때 인자가 길어지면 아래의 규칙에 따라 여러 줄에 나눠서 작성한다.
  - 인자가 길어지면 `(` 바로 다음에 줄바꿈을 넣고 다음 행부터 들여쓰기를 한 단계 깊게 한 행에 하나의 인자를 작성한다. 메소드 호출을 닫을 때는 들여쓰기를 첫 줄과 마찬가지로 하고 `)`를 별도의 줄에 작성한다.

      ```ruby
      Foo.new(
        arg,
        long_argument,
        key: value,
        long_key: long_value,
        pretty_so_much_very_long_key:
          pretty_so_much_very_tooooooooooooooooooooo_long_value,
      )
      ```

  - 인자가 짧을 때는 `(`에 이어서 첫번째 인자를 작성하고, 다음 줄부터는 들여쓰기을 첫번째 인자에 맞추서 인자들을 하나씩 작성한다. 메소드 호출을 마칠 때는 `)`을 마지막 인자 바로 다음에 적는다.

      ```ruby
      Foo.new(arg,
              long_argument,
              key: value,
              long_key: long_value)
      ```

  - DSL 메소드를 여러 줄에 걸쳐서 작성할 때는 첫번째 인수를 메소드 이름 바로 뒤에 적고, 다음 줄부터 들여쓰기를 한단계 깊게 인수를 한 줄에 하나씩 작성한다.

      ```ruby
      ActionMailer::Base.delivery_method :smtp,
          host: 'localhost',
          port: 25
      ```

<a name="begin-and-end"></a>

## BEGIN과 END

- **[MUST]** `BEGIN` 블록과 `END` 블록은 사용하지 않는다.

<a name="module-and-class-definitions"></a>

## 모듈과 클래스 정의

- **[MUST]** 메소드에 별칭을 붙일 때는 `alias`를 사용하지 말고 `alias_method`를 사용한다.
- **[MUST]** `attr`을 사용하지 말고 `attr_accessor`, `attr_reader`, `attr_writer`을 사용한다.
- **[MUST]** 클래스 메소드를 정의할 때는 의미없이 들여쓰기가 깊어지지 않도록 `self.` 문법을 사용한다.하지만 private 메소드와 public 메소드를 모두 사용할 때는 `class << self` 를 사용해도 무방하다.

    ```ruby
    class Foo
      # good
      def self.foo
      end

      # bad
      def Foo.foo
      end
    end
    ```

- **[MUST]** private와 protected 클래스 메소드를 정의할 때는 `class << self` / `end` 안에서 메소드를 정의하고 가시성을 변경한다.

   ```ruby
    class Foo
      # good
      class << self
        def foo
        end
        private :foo
      end

      # bad
      def self.foo
      end
      class <<self
        private :foo
      end
    end
   ```

- **[MUST]** 메소드가 정의되어있을 때 메소드 이름을 인수로 `private`나 `protected`나 `public` 메소드를 호출해 메소드의 가시성을 변경할 때는 메소드 정의와 가시성 변경 메소드 사이에 빈 줄을 두지 않는다.

    ```ruby
    class Foo
      # good
      def foo
      end
      private :foo

      # bad
      def foo
      end

      private :foo
    end
    ```

- **[MUST]** `private`나 `protected`나 `public`을 인수 없이 사용할 때는 들여쓰기를 메소드 정의와 같게 하고 메소드 호출 앞뒤로 한 줄을 띄워준다.

    ```ruby
    # good
    class Foo
      def foo
      end

      private

      def bar
      end
    end

    # bad
    class Foo
      def foo
      end

    private

      def bar
      end
    end

    # bad
    class Foo
      def foo
      end

      private

        def bar
        end
    end

    # bad
    class Foo
      def foo
      end

      private
      def bar
      end
    end
    ```

- **[SHOULD]** 외부에 노출되는 클래스와 모듈의 메소드 및 변수에 대한 문서는 Markdown으로 작성한다.
- **[MUST]** 문서화를 위한 주석과 메소드 정의 사이에 빈 줄을 넣지 않는다.
- **[MUST]** 문서화는 [TomDoc](http://tomdoc.org/) 포맷을 따른다.
- **[MUST]** 하나의 클래스를 여러가지 목적으로 사용하지 않는다.

<a name="method-definitions"></a>

## 메소드 정의

- **[MUST]** 메소드를 정의할 때 인수 리스트의 괄호는 생략하지 않는다.인수가 없는 메소드를 정의할 때는 괄호를 사용하지 않는다.
- **[MUST]** 메소드와 인수 리스트의 괄호 사이에는 공백을 넣지 않는다.
- **[SHOULD]** 메소드 본문에 주석을 필요한 코드를 작성하지 않는다.
  - 메소드 본문에 주석을 남기기보단 별도의 메소드로 추출해서 이름을 붙이는 게 가독성을 향상시킨다.
  - 수식에 대한 보충이나 출처는 본문에 주석을 남겨도 무방하다.
- **[MUST]** 하나의 메소드로 여러가지 일을 하지 않는다.
- **[MUST]** 인수를 삭제하지 않는다.

    ```ruby
    # good
    def your_method(str)
      new_str = str.sub('xxx', 'yyy')
    end

    # bad
    def your_method(str)
      str.sub!('xxx', 'yyy')
    end
    ```

<a name="variables"></a>

## 변수

- **[MUST]** 글로별 변수를 (`$foo`) 임의로 정의하지 않는다.
- **[MUST]** 클래스 변수(`@@foo`)를 사용하지 않는다. 클래스 변수 대신 `class_attribute`를 사용한다.
- **[MUST]** 변수 이름에는 영어 단어를 생략해서 사용하지 않는다.단, 변수명이 너무 길어질 때는 단어의 첫문자를 제외한 모음을 생략하거나 일반적인 약어를 사용해도 무방하다.관습적인 변수 이름인 `i`나 `j`와 같은 변수는 사용해도 좋다.
- **[SHOULD]** 하나의 변수를 여러 가지 용도로 사용해서는 안 된다.이러한 경우엔 메소드를 분리한다.
- **[SHOULD]** 지역 변수 스코프(유효범위)를 가능하면 작게 만든다.지역 변수가 존재하지 않는 메소드가 좋은 메소드이다.

## 이 외(분류하기 어려운 규칙)

- **[MUST]** 파괴적인 메소드를 사용할 때는 그 영향 범위를 최소한으로 한정한다.

