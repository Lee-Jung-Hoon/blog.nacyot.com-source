---
title: "알아두면 도움이 되는 55가지 루비(Ruby) 기법"
date: 2013-11-24 12:00:00 +0900
author: nacyot
license: <a href="http://creativecommons.org/licenses/by-nc/2.1/jp/"><imgsrc="http://i.creativecommons.org/l/by-nc/2.1/jp/88x31.png" title="cc-by-nc"></a>
tags: ruby, 루비, 프로그래밍 언어, 번역, kyoendo
---

이 글은 [kyoendo](http://melborne.github.io/) 씨의 55 Trivia Notations you should know in Ruby 문서를 [nacyot](http://nacyot.com)이 번역한 글입니다. 번역된 문서는 [gist](https://gist.github.com/nacyot/7624036)에서 관리되고 있습니다. 원본은 [여기](http://melborne.github.io/2013/03/04/ruby-trivias-you-should-know-4/)에서 찾아볼 수 있으며 [cc-by-nc](http://creativecommons.org/licenses/by-nc/2.1/jp/) 라이센스에 따라 공개되어있습니다. 번역본 또한 같은 라이센스를 따릅니다.

<!--more-->

----

Ruby는 즐거운 언어입니다. Ruby를 사용하다보면 매뉴얼에도 나와있지 않은
'**작은 발견**'을 만나게 됩니다. 이러한 '발견'은 프로그램의 질이나
효율 개선에 직접적으로 연결되지 않을 지도 모릅니다. 좋기는 커녕 팀
단위로 프로그래밍을 하는 동안에는 사용하지 않는 게 좋을 지도
모릅니다. 하지만 다른 시각에서 생각해보면, 어떤 언어에 아직 모르는
영역이 남아있다는 건 이 언어에 대한 흥미를 잃지 않게 만들어주는 중요한
요인이라는 것도 의심의 여지가 없습니다. 즉 '발견'은 언어를 즐겁게 만들어줍니다 .

이 블로그에서는 '알아두면 도움이 되는 루비 기법'이라는 주제로 지금까지 3 편의 글을 써왔습니다.

> [알아두면 도움이 되는 21가지 루비 기법](http://melborne.github.com/2011/06/22/21-Ruby-21-Trivia-Notations-you-should-know-in-Ruby/)
>
> [제 2탄! 알아두면 도움이 되는 12가지 루비 기법](http://melborne.github.com/2012/02/08/2-12-Ruby-12-Trivia-Notations-you-should-know-in-Ruby/)
>
> [제 3탄! 알아두면 도움이 되는 12가지 루비 기법](http://melborne.github.com/2012/04/26/ruby-trivias-you-should-know/)

이 기법들은 인터넷에서 발견한 것, 트위터에서 배운 것, 스스로 발견한 것들을 모은 것들입니다. 이런 기법들을 접할 때마다 제 입에서는 '아하', '우와' 같은 감탄사가 절로 나왔습니다.

여기서는 위에서 다룬 45개의 기법과 추가적으로 새로운 10가지 기법을
합쳐 55가지 기법을 소개합니다. 전체적인 내용을 재구성했으면 비교적
이해하기 쉬운 내용을 앞에 배치하고 약간 어려운 부분을 뒤에
배치했습니다. 몇몇 설명에 대해서는 좀 더 간결하게 수정했습니다. 여기서는 언어를
어떻게 사용해야할 것인가, 혹은 어떻게 읽기 쉬운 코드를 작성할 수
있을까 하는 어려운 문제는 제쳐두고 일단 재미나 보이는 기법들에 대해
이렇게 작성할 수 있구나 하면서 즐기셨으면 합니다. Ruby 버전은 1.9나 2.0을 대상으로 합니다.

---

그리고 이 글은 E-Books으로도 출간되었습니다. 이 글을 E-Books 형식으로 천천히
음미하고 싶으신 분은 구입을 고려해주세요. epub 형식은 물론 Kindle에서
사용 가능한 mobi 형식도 포함되어 있습니다.


<a href="http://melborne.github.io/books/">
  <img src="http://melborne.github.io/assets/images/2013/03/ruby_trivia_cover.png" alt="trivia" style="width:200px" />
</a>

> [M'ELBORNE BOOKS](http://melborne.github.io/books/ 'M'ELBORNE BOOKS')

### 1. Array 객체의 스택 메소드
 x
`Array#<<` 메소드는 인수를 하나만 받습니다만 `Array#push`는 여러개의
인수를 받을 수 있습니다. 또한 `Array#pop`는 한 번에 여러개의 값을 pop 할 수 있습니다.`Array#unshift` `Array#shift`도 마찬가지입니다.

```ruby
 stack = []
 stack.push 1, 2, 3 # => [1, 2, 3]
 stack.pop 2 # => [2, 3]
 stack # => [1]
 stack.unshift 4, 5, 6 # => [4, 5, 6, 1]
 stack.shift 3 # => [4, 5, 6]
 stack # => [1]
```

또한 특정 위치에서 여러개의 값을 가져올 때는 `Array#values_at`이 편리합니다.

```ruby
 lang = %w(ruby python perl haskell lisp scala)
 lang.values_at 0, 2, 5 # => ["ruby", "perl", "scala"]
```

이 메소드는 Hash 객체에서도 사용할 수 있습니다.

```ruby
lang = {ruby:'matz', python:'guido', perl:'larry', lisp:'mccarthy'}

lang.values_at :ruby, :perl # => ["matz", "larry"]
```

### 2. Kernel#Array
서로 다른 타입을 가진 인수를 일괄적으로 처리할 때는 `Kernel#Array`가 편리합니다.

```ruby
 Array 1 # => [1]
 Array [1,2] # => [1, 2]
 Array 1..5 # => [1, 2, 3, 4, 5]
 
 require "date"
 def int2month(nums)
   Array(nums).map { |n| Date.new(2010,n).strftime "%B"  }
 end
 
 int2month(3) # => ["March"]
 int2month([2,6,9]) # => ["February", "June", "September"]
 int2month(4..8) # => ["April", "May", "June", "July", "August"]
```

### 3. 요소 구분 콤마
배열과 해시의 각 요소를 구분하는 기호로 콤마를 사용하는데 마지막 요소의 콤마는 무시됩니다.

```ruby
 p designers = [
                 "John McCarthy",
                 "Yukihiro Matsumoto",
                 "Larry Wall",
                 "Alan Kay",
                 "Martin Odersky",
               ]
 
 # >> ["John McCarthy", "Yukihiro Matsumoto", "Larry Wall", "Alan Kay", "Martin Odersky"]
 
 p designers = {
                 :lisp => "John McCarthy",
                 :ruby => "Yukihiro Matsumoto",
                 :perl => "Larry Wall",
                 :smalltalk => "Alan Kay",
                 :scala => "Martin Odersky",
               }
 
 # >> {:lisp=>"John McCarthy", :ruby=>"Yukihiro Matsumoto", :perl=>"Larry Wall", :smalltalk=>"Alan Kay", :scala=>"Martin Odersky"}
```

요소를 자주 추가/삭제하거나 파일에서 eval을 할 때 유용합니다.

### 4. 해시 리터럴
Ruby 1.9에는 새로운 해시 리터럴이 추가되었지만, 예전 방식과 혼용해서 사용할 수 있습니다.

```ruby
 designers1 = {
               :lisp => "John McCarthy",
               :ruby => "Yukihiro Matsumoto",
               :perl => "Larry Wall",
               :smalltalk => "Alan Kay",
               :'C++' =>  "Bjarne Stroustrup",
             }
 
 designers2 = {
               java: "James Gosling",
               python: "Guido van Rossum",
               javascript: "Brendan Eich",
               scala: "Martin Odersky",
             }
 
 designers = designers1.merge designers2
  # => {:lisp=>"John McCarthy", :ruby=>"Yukihiro Matsumoto", :perl=>"Larry Wall", :smalltalk=>"Alan Kay", :"C++"=>"Bjarne Stroustrup", :java=>"James Gosling", :python=>"Guido van Rossum", :javascript=>"Brendan Eich", :scala=>"Martin Odersky"}
```

### 5. Enumerable#each_with_object
Enumerable#inject는 편리한 메소드지만 블록에서 조건은 지정을 하는 경우에도 각 반복에서 결과값이 중첩될 객체가 리턴되는 것이 보장되어야만 합니다.

```ruby
 designers.inject([]) { |mem, (lang, name)| mem << [name,lang].join('/') if lang[/l/]; mem }
  # => ["John McCarthy/lisp", "Larry Wall/perl", "Alan Kay/smalltalk", "Martin Odersky/scala"]
```

블록 마지막의 '; mem'부분입니다.

`Enumerable#each_with_object`를 이러한 문제를 사용하면 간단히 해결할 수 있습니다.

```ruby
 designers.each_with_object([]) { |(lang, name), mem| mem << [name,lang].join('/') if lang[/l/] }
  # => ["John McCarthy/lisp", "Larry Wall/perl", "Alan Kay/smalltalk", "Martin Odersky/scala"]
```

이름이 길어서 가능하면 사용하고 싶지 않습니다만...

### 6. splat 전개
Ruby에서 알파벳 배열을 만들 때는 보통 아래와 같은 방법을 사용합니다.

```ruby
 (1..20).to_a # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
 ('a'..'z').to_a # => ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
 (1..10).to_a + (20..30).to_a # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
```

이러한 표현은 `*`(splat) 전개를 사용해 아래와 같이 바꿔쓸 수 있습니다.

```ruby
 [*1..20] # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
 [*'a'..'m'] # => ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"]
 [*1..10, *20..30] # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
```

### 7. 전치 콜론
문자열을 심볼로 변환할 때는 일반적으로, String#intern이나
String#to_sym 메소드를 사용합니다만 문자열 리터럴에 앞에 콜론을 놓는
방법도 있습니다.

```ruby
 'goodbye'.intern # => :goodbye
 'goodbye'.to_sym # => :goodbye
 
 :'goodbye' # => :goodbye
 
 a = 'goodbye'
 :"#{a}" # => :goodbye
```


### 8. Enumerator#with_index
임의의 리스트를 표준 출력할 때 각 리스트의 순서를 나타내는 인덱스 숫자가 필요할 때 일반적으로 `Enumerator#with_index`를 사용합니다.

```ruby
names = Module.constants.take(10)
names.each_with_index { |name, i| puts "%d: %s" % [i+1, name] }
# >> 1: Object
# >> 2: Module
# >> 3: Class
# >> 4: Kernel
# >> 5: NilClass
# >> 6: NIL
# >> 7: Data
# >> 8: TrueClass
# >> 9: TRUE
# >> 10: FalseClass
```


`i+1`를 사용하는 게 영 맘에 들지 않습니다. 여기에 공감하시는 분들을 위해 `Enumerator#with_index` 메소드가 있습니다.

```ruby
names = Module.constants.take(10)
names.each.with_index(1) { |name, i| puts "%d: %s" % [i, name] }
# >> 1: Object
# >> 2: Module
# >> 3: Class
# >> 4: Kernel
# >> 5: NilClass
# >> 6: NIL
# >> 7: Data
# >> 8: TrueClass
# >> 9: TRUE
# >> 10: FalseClass
```

with_index는 index의 offset을 인수로 받습니다. comparable한 객체를 받아주면 더욱 좋겠습니다만.

### 9. Integer#times
`times`는 특정 횟수만큼 반복하고 싶을 때 사용합니다.

```ruby
you_said = 'てぶくろ'
6.times { puts you_said.reverse!} # => 6
# >> ろくぶて
# >> てぶくろ
# >> ろくぶて
# >> てぶくろ
# >> ろくぶて
# >> てぶくろ
```

times는 블록을 받지 않으면 Enumerator를 리턴합니다. 따라서 여러개의
객체를 생성할 때 사용할 수 있습니다. 20개의 RGB 컬러 샘플을 만든다고 해보죠.

```ruby
20.times.map { [rand(256), rand(256), rand(256)] } # => [[45, 190, 194], [94, 43, 125], [6, 104, 181], [144, 92, 114], [34, 161, 214], [96, 69, 241], [216, 246, 133], [6, 237, 131], [194, 95, 214], [177, 252, 202], [184, 149, 142], [184, 166, 45], [41, 108, 115], [176, 100, 138], [124, 213, 89], [173, 123, 34], [137, 31, 47], [54, 92, 186], [118, 239, 217], [150, 184, 240]]
```

### 10. String#succ / Integer#succ
Excel과 같이 A에서 부터 차례대로 문자로된 인덱스를 생성하려면 어떻게
해야할까요?최근에 비슷한 문제를 접했습니다. Ruby에선 `String#succ` 또는 `next`가 있으니 간단히 해결 가능합니다.

```ruby
col = '@'
60.times.map { col = col.succ } # => ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ", "BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH"]
```

### 11. Comparable.between?

값이 특정 범위 안에 있는 지 여부를 판단할 때 사용됩니다. 보통은 다음과 같이 사용합니다.

```ruby
pos = 48
status =
  if 0 <= pos && pos <= 50
    :you_are_in
  else
    :you_are_out
  end
status # => :you_are_in
```

이렇게 짜놓고 CoffeeScript를 보면 분한 마음이 듭니다. 하지만 안심해주세요. Ruby에는 `between?` 메소드가 있습니다.

```ruby
pos = 48
status =
  if pos.between?(0, 50)
    :you_are_in
  else
    :you_are_out
  end
status # => :you_are_in

pos = 'D'
grade =
  if pos.between?('A', 'C')
    :you_are_good!  else
    :try_again!  end
grade # => :try_again!
```


저는 case 파 입니다만...

```ruby
pos = 48
status =
  case pos
  when 0..50
    :you_are_in
  else
    :you_are_out
  end
status # => :you_are_in
```

### 12. Array#first/last
`Array#first/last`는 가져올 요소의 수를 인수로 받습니다.

```ruby
arr = [*1..100]
arr.first(5) + arr.last(5) # => [1, 2, 3, 4, 5, 96, 97, 98, 99, 100]
```

Range 객체에서도 같은 메소드를 지원하고 있으니, 위의 예제는 아래와 같이 작성할 수도 있습니다.

```ruby
range = (1..100)
range.first(5) + range.last(5) # => [1, 2, 3, 4, 5, 96, 97, 98, 99, 100]
```

### 13. 변수 nil 초기화
여러 변수를 `nil`으로 초기화하려는 경우에 어떻게 하시나요?이렇게
하시나요?

```ruby
a, b, c, d, e, f, g, h, i, k = [nil] * 10

[a, b, c, d, e, f, g, h, i, k].all?(&:nil?) # => true
```

하지만 다중 대입을 할 때는 값이 없으면 nil이 지정되므로 아래 코드면 충분합니다.

```ruby
a, b, c, d, e, f, g, h, i, k = nil

[a, b, c, d, e, f, g, h, i, k].all?(&:nil?) # => true
```

### 14. 해시 키
해시 리터럴은 다음과 같이 작성합니다.

```ruby
{a: 1, b: 2, c: 3, a: 4, e: 5} # => {:a=>4, :b=>2, :c=>3, :e=>5}
```

눈치 채셨나요?실수로 키를 중복해서 사용해도 에러는 발생하지 않습니다.

특히 배열을 해시로 변환할 때는 주의가 필요합니다.

```ruby
arr = [a: 1, b: 2, c: 3, a: 4, e: 5]
Hash[ *arr ] # => {:a=>4, :b=>2, :c=>3, :e=>5}
```

### 15. 메소드 인수의 인수
Ruby에서 인수를 받는 메소드를 호출할 때는 괄호를 생략할 수 있습니다만, 인수가 심볼일 때는 메소드 이름과 인수 사이의 공백도 생략할 수 있습니다.

```ruby
 def name(sym)
   @name = sym
 end

 name:charlie # => :charlie
```

이렇게 작성하면 더욱 선언적으로 보입니다.

하지만 이걸 변수에 넣거나 puts로 출력하는 경우엔 제대로 읽어들이지 못 하기 때문에 한정적인 방법이라고 할 수 있습니다.

또한 * &의 뒤의 스페이스는 무시되므로 아래와 같이 작성할 수 있습니다.

```ruby
 def teach_me(question, * args, & block)
   google(question, * args, & block)
 end

 a, b, * c = 1,2,3,4
 c # => [3,4]
```

그래서 어쨌다는 걸까요...


### 16. 부정
부정의 의미로 사용되는 `!` 혹은 `not`이 맘에 드시지 않는 분? 

그렇다면 `BaiscObject#!`가 있습니다!

```ruby
 true.!# => false
 false.!# => true
 1.!# => false
 'hello'.!.!# => true
```
...

다음으로 넘어가죠...

### 17. % 노테이션
String#%을 사용하면 문자열을 

```ruby
 lang = [:ruby, :java]
 "I love %s, not %s" % lang # => "I love ruby, not java"
```

뿐만 아니라 해시도 받을 수 있습니다.

```ruby
 lang = {a: :java, b: :ruby}
 "I love %{b}, not %{a}" % lang # => "I love ruby, not java"
```

### 18. 문자열 분리
문자열을 각 문자 별로 분리할 때는 `String#split`나 `String#chars` 메소드를 사용할 수 있습니다.

```ruby
 alpha = "abcdefghijklmnopqrstuvwxyz"
 alpha.split(//) # => ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
 
 alpha.chars.to_a # => ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
```

또한 ruby 2.0에선 chars 메소드를 사용한 후에 별도로 to_a를 호출해주지 않아도 됩니다.

하지만 문자열을 여러개의 문자를 기준으로 분리할 때는 `String#scan`이 편리합니다.

```ruby
 alpha.scan(/.../) # => ["abc", "def", "ghi", "jkl", "mno", "pqr", "stu", "vwx"]
 alpha.scan(/.{1,3}/) # => ["abc", "def", "ghi", "jkl", "mno", "pqr", "stu", "vwx", "yz"]
 
 number = '12345678'
 def number.comma_value
   reverse.scan(/.{1,3}/).join(',').reverse
 end
 number.comma_value # => "12,345,678"
```

### 19. Array#*
`Array#*`에 정수를 넘겨주면 배열을 해당하는 수만큼 반복한 배열을 리턴합니다만, 문자열을 넘겨주면 문자열을 조인하고 그 사이에 해당하는 문자열로 연결해줍니다.

```ruby
 [1, 2, 3] * 3 # => [1, 2, 3, 1, 2, 3, 1, 2, 3]
 
 [2009, 1, 10] * '-' # => "2009-1-10"
```

그럼 이 지식을 활용해 다음 예제에서 x의 출력을 맞춰보세요!

```ruby
*a, b, c = %w(1 2 3 4 5)

x = a * b + c

puts x
```

### 20. Array#uniq
배열에서 중복된 값들을 제외할 때 `Array#uniq` 메소드를 사용하곤합니다. 이 때 uniq 메소드에 블록을 넘겨 조건을 지정할 수 있습니다.

```ruby
 Designer = Struct.new(:name, :lang)
 data = {'matz' => :ruby, 'kay' => :smalltalk, 'gosling' => :java, 'dhh' => :ruby}
 designers = data.to_a.map { |name, lang| Designer[name, lang] }
 
 designers # => [#<struct Designer name="matz", lang=:ruby>, #<struct Designer name="kay", lang=:smalltalk>, #<struct Designer name="gosling", lang=:java>, #<struct Designer name="dhh", lang=:ruby>]

 designers.uniq.map(&:name) # => ["matz", "kay", "gosling", "dhh"]
 designers.uniq{ |d| d.lang }.map(&:name) # => ["matz", "kay", "gosling"]
```

아, 그렇죠. No 19의 정답은 "142435"입니다.

### 21. 모든 배열 요소의 동일 여부 확인
배열의 모든 요소가 같은지 확인할 때 Array#uniq 메소드를 사용할 수 있습니다.

```ruby
[1, 1, 1, 1, 1, 1, 1, 1, 1, 1].uniq.size==1 # => true
[1, 1, 1, 1, 1, 1, 1, 2, 1, 1].uniq.size==1 # => false
```

조건을 지정하고 싶을 땐 uniq에 블록을 넘겨주는 방법이 좋습니다.

```ruby
%w(street retest setter tester).uniq { |w| w.chars.sort }.size==1 # => true
```


### 22. 문자열 리스트 %w

문자열 리스트를 만들 때 %w를 사용하면 편리합니다. 이 때 공백 문자를 포함하고 싶으면 백슬래시로 이스케이프 해줄 수 있습니다.

```ruby
 designers = %w(John\ McCarthy Yukihiro\ Matsumoto Larry\ Wall Alan\ Kay Martin\ Odersky)
 designers # => ["John McCarthy", "Yukihiro Matsumoto", "Larry Wall", "Alan Kay", "Martin Odersky"]
```

### 23. 동적 상속

Ruby 클래스의 상속은 `<` 기호를 사용하는데 이때 우변에 클래스 상수나 클래스를 리턴하는 식을 지정할 수 있습니다.

```ruby
 class Male
  def laugh
    'Ha ha ha!'
  end
 end

 class Female
  def laugh
    'Fu fu fu..'
  end
 end

 class Me < [Male, Female][rand 2]
 end

 Me.superclass # => Female
 Me.new.laugh # => 'Fu fu fu..'
```

환경에 따라 IO를 바꾸는 예제입니다.

```ruby
 def io(env=:development)
   env==:test ?StringIO : IO
 end

 env = :test

 class MyIO < io(env)
 end

 MyIO.superclass #=> StringIO
```

즉 Ruby에서는 조건에 따라 상속하려는 클래스를 동적으로 바꿀 수 있습니다.

### 24. 대문자 메소드
Ruby는 메소드 이름으로 영어 소문자를 사용하는데 영어 대문자도 사용할
수 있습니다. 대문자 메소드는 상수처럼 보이기도 합니다.

```ruby
 class Google
   def URL
     'www.google.com'
   end
   private :URL

   def search(word)
     get( URL(), word)
   end
 end
```

상수는 속상된 서브 클래스에서도 참조 가능하지만 이를 비공개로 하고
싶을 때는 어떨까요. 바로 이럴 때 대문자 메소드를 이용해보는 겁니다.

인수가 없을 때도 괄호가 생략 불가능한 단점은 있지만, 관련된 복잡한 상수를 정의할 때도 편리하게 사용할 수 있습니다.

```ruby
 class Google
   def search(word, code=:us)
     get( URL(code), word )
   end

   def URL(code)
     { us: 'www.google.com',
       ja: 'www.google.co.jp' }[code]
   end
   private :URL
```

「상수 메소드」라는 이름은 어떨까요.

### 25. 함수 부분 적용
비슷한 메소드를 여러번 만드는 건 DRY 원칙에 위배됩니다.`Proc#curry`를
사용하면 이러한 문제를 피할 수 있습니다. 계절 판정 예제입니다.

```ruby
 require "date"
 
 season = ->range,date{ range.include?Date.parse(date).mon }.curry
 
 is_spring = season[4..6]
 is_summer = season[7..9]
 is_autumn = season[10..12]
 is_winter = season[1..3]
 
 is_autumn['11/23'] # => true
 is_summer['1/1'] # => false
```

이럴 때 변수명에 `?`를 사용할 수 있으면 좋겠다는 생각을 해봅니다.

### 26. Proc에 의한 case 조건
Proc은 call 메소드를 사용해 실행할 수 있는데 이 메소드는
`Proc#===`라는 다른 이름을 가지고 있습니다. 앞선 계절 판정 함수를 case
식으로 작성하면 아래와 같습니다.

```ruby
 for date in %w(2/4 11/23 6/14 8/3)
   act = 
     case date
     when is_spring; 'Wake up!'
     when is_summer; 'Cool down!'
     when is_autumn; 'Read!'
     when is_winter; 'Sleep!'
     end
   puts "#{date} => #{act}"
 end
 # >> 2/4 => Sleep! # >> 11/23 => Read! # >> 6/14 => Wake up! # >> 8/3 => Cool down!
```

인수가 넘어가는 게 암묵적으로 이루어져서 case 식이 깔끔하게 느껴집니다.

### 27. Struct 클래스
속성만 있는 클래스를 생성할 때는 `Struct`가 편리합니다.

```ruby
 module Fortune
   class Teller
     require "date"
     def self.ask(name, age, occupation)
       Date.today.next_day(rand 10)
     end
   end
 end
 
 class Person < Struct.new(:name, :age, :occupation)
   def length_of_life(date)
     (Fortune::Teller.ask(name, age, occupation) - Date.parse(date)).to_i
   end
 end
 
 charlie = Person.new('charlie', 13, :programmer)
 charlie.length_of_life('2013/3/1') # => 6
```

Struct.new는 블록을 받을 수 있어 아래와 같이 사용할 수도 있습니다.

```ruby
 Person = Struct.new(:name, :age, :occupation) do
   def length_of_life(date)
     (Fortune::Teller.ask(name, age, occupation) - Date.parse(date)).to_i
   end
 end

 charlie = Person.new('charlie', 13, :programmer)
 charlie.length_of_life('2013/3/1') # => 3
```

### 28. Struct의 기본 값

한 번 더 Struct 이야기입니다. 이번엔 Beverage 객체를 만들어 보겠습니다.

```ruby
class Beverage < Struct.new(:name, :cost)
end

# 혹은 Beverage = Struct.new(:name, :cost)

starbucks = Beverage.new(:staba, 430) # => #<struct Beverage name=:staba, cost=430>
heineken = Beverage.new(:heineken, 580) # => #<struct Beverage name=:heineken, cost=580>
```

여기서 `new`에 인수를 넘기지 않으면 속성값에는 nil이 지정됩니다.

```ruby
Beverage.new # => #<struct Beverage name=nil, cost=nil>
```

가능하면 클래스와 마찬가지로 기본 값을 설정하고 싶죠. 그럴 땐 이렇게 합니다.

```ruby
class Beverage < Struct.new(:name, :cost)
  def initialize(name=:water, cost=0)
    super(name, cost)
  end
end

starbucks = Beverage.new(:staba, 430) # => #<struct Beverage name=:staba, cost=430>
heineken = Beverage.new(:heineken, 580) # => #<struct Beverage name=:heineken, cost=580>

water = Beverage.new # => #<struct Beverage name=:water, cost=0>
```


### 29. retry와 인수 기본값
rescue를 사용할 때는 `retry`를 사용해서 메소드를 재실행할 수 있습니다.
이를 메소드 인수의 기본 값과 연관지어 편리하게 사용할 수 있습니다.

```ruby
 require "date"
 def last_date(date, last=[28,29,30,31])
   d = Date.parse date
   Date.new(d.year, d.mon, last.pop).day rescue retry
 end
 
 last_date '2013/6/1' # => 30
 last_date '2012/2/20' # => 29
 last_date '2013/2' # => 28
```

이 예제에서는 31일부터 Date 객체를 생성해 예외가 발생하면 retry를 통해 전 날의 Date객체 생성을 시도합니다.

사실 마지막 날이 알고 싶은 거면 아래 코드면 충분합니다만...

```ruby
 Date.new(2013,2,-1).day # => 28
```


### 30. Array#zip
`Array#zip`을 알고계시나요?여러개의 배열을 한 줄 한 줄 늘여놓고 열단위로 묶어주는 메소드입니다.

```ruby
[1, 2, 3].zip([4, 5, 6], [7, 8, 9]) # => [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

[:A, :B, :C].zip([:E, :F, :G], [:H, :I, :J]) # => [[:A, :E, :H], [:B, :F, :I], [:C, :G, :J]]
```

zip은 일반적으로 하나나 그보다 많은 배열들을 인수로 받는데 값이 연속되는 경우엔 Range를 사용할 수 있습니다.

```ruby
[1, 2, 3].zip(4..6, 7..9) # => [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

[:A, :B, :C].zip(:E..:G, :H..:J) # => [[:A, :E, :H], [:B, :F, :I], [:C, :G, :J]]
```

또한 zip은 블록을 넘겨받을 수 있습니다.

```ruby
[1, 2, 3].zip(4..6, 7..9) { |xyz| puts xyz.inject(:+) } # => nil
# >> 12
# >> 15
# >> 18

[:A, :B, :C].zip(:E..:G, :H..:J) { |xyz| puts xyz.join } # => nil
# >> AEH
# >> BFI
# >> CGJ
```

단 리턴값은 nil이므로 블록에서 처리하는 방법으로밖에 사용할 수 없습니다.

### 31. Enumerable#zip
zip 메소드는 Enumerable 클래스에도 있습니다.

```ruby
(1..3).zip(4..6, 7..9) # => [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

(:A..:C).zip(:E..:G, :H..:J) # => [[:A, :E, :H], [:B, :F, :I], [:C, :G, :J]]
```

Struct도 Enumerable 객체이므로 아래와 같은 것도 가능합니다.

```ruby
water = Beverage.new  # => #<struct Beverage name=:water, cost=0>
starbucks = Beverage.new(:staba, 430) # => #<struct Beverage name=:staba, cost=430>
heineken = Beverage.new(:heineken, 580) # => #<struct Beverage name=:heineken, cost=580>

water.zip(starbucks, heineken) # => [[:water, :staba, :heineken], [0, 430, 580]]
```

### 32. ARGF
ARFG는 훌륭합니다. 이는 커맨드 라인 인수를 파일명으로 받아들여 지정된
파일 객체를 가져옵니다. 그런데 이 객체의 클래스가 뭔지 알고계시나요? 이를 확인하려면 class 메소드를 보내보면 되겠죠.

```ruby
ARGF.class # => ARGF.class
```

네. 정답은 `ARFG.class`입니다.

그럼 new 하면 ARGF가 만들어질까요.

```ruby
ARGF.class # => ARGF.class
MYARGF = ARGF.class.new  # => ARGF
MYARGF.class # => ARGF.class

puts MYARGF.filename
```

만들어집니다! 하지만 제대로 작동하지 않습니다.

```sh
% ruby argf_test.rb abc.txt
-
```

칫!

### 33. Object#tap
`tap`은 이 블록의 평가 결과를 버리는 희안한 메소드인데 그 결과가
필요할 때가 있습니다. 그럴 땐 break를 사용하면 됩니다. (thanks to knu 님).

```ruby
average = [56, 87, 49, 75, 90, 63, 65].tap { |sco| break sco.inject(:+) / sco.size } # => 69
```

컵라면을 좋아하는 당신께 아래의 코드를 헌정합니다.

```ruby
puts "Eat!".tap { sleep 180 } # 3분 후에 'Eat!'
```

### 34. 사용하지 않는 변수
배열 데이터를 그냥 버리고 싶을 때가 있죠.

```ruby
header, *data = DATA.each_line.map { |line| line.chomp.split }
header # => ["name", "age", "job"]
data # => [["charlie", "12", ":programmer"], ["tommy", "17", ":student"], ["nick", "27", ":doctor"]]

__END__
name age job
charlie 12 :programmer
tommy 17 :student
nick 27 :doctor
```

그런데 여기서 `header` 변수를 사용하지 않으면 경고가 나옵니다.

```ruby
header, *data = DATA.each_line.map { |line| line.chomp.split } # !> assigned but unused variable - header
data # => [["charlie", "12", ":programmer"], ["tommy", "17", ":student"], ["nick", "27", ":doctor"]]
```

이를 피하기 위해 변수명을 `_`(밑줄)로 지정합니다.

```ruby
_, *data = DATA.each_line.map { |line| line.chomp.split }
data # => [["charlie", "12", ":programmer"], ["tommy", "17", ":student"], ["nick", "27", ":doctor"]]
```

만약 이미 2.0을 사용하고 계시다면 변수 이름 앞에 `_`를 붙여주기만 하면 됩니다.

```ruby
_header, *data = DATA.each_line.map { |line| line.chomp.split }
```

### 35. 파일 뽑아내기
여러 파일이 있을 때 특정한 조건에 맞는 딱 하나의 파일을 찾아내 다른
변수에 저장하고 싶다고 해보죠. `Array#delete` 메소드를 사용하면 될 것 같은데, 실제론 어떨까요.

```ruby
files = ['Gemfile', 'LICENSE.txt', 'README.md', 'Rakefile', 'bin', 'lib', 'maliq.gemspec', 'pkg', 'spec']

gemspec = files.delete(/\.gemspec$/)
gemspec # => nil
files # => ["Gemfile", "LICENSE.txt", "README.md", "Rakefile", "bin", "lib", "maliq.gemspec", "pkg", "spec"]
```

안타깝지만 생각처럼 되지 않습니다. 이는 Array#delete가 `==`으로 동일 여부를 판단하기 때문입니다.

그렇다면 `Array#partition`과 다중 대입을 사용해보죠.

```ruby
gemspec, files = files.partition { |f| f.match(/\.gemspec$/) }
gemspec # => ["maliq.gemspec"]
files  # => ["Gemfile", "LICENSE.txt", "README.md", "Rakefile", "bin", "lib", "pkg", "spec"]
```

다 된 것 같긴 한데 gemspec 파일을 배열로 돌려주는 게 조금 아쉽네요. 하지만 다중 대입 + 괄호를 사용하면 해결할 수 있습니다.

```ruby
(gemspec, *_), files = files.partition { |f| f.match(/\.gemspec$/) }
gemspec # => "maliq.gemspec"
files # => ["Gemfile", "LICENSE.txt", "README.md", "Rakefile", "bin", "lib", "pkg", "spec"]
```

### 36. Symbol에 주석 사용하기
심볼에도 주석을 달고 싶다고 생각해보신 적은 없나요? 그렇다면 이렇게 해보세요.

```ruby
sym = :#this symbol is nice
hello

sym # => :hello
```

대체 이걸 어디에 쓰시려고...

### 37. Kernel#loop
끝없이 반복하고 싶은 경우엔 `Kernel#loop`에 블록을 넘겨주면 됩니다.

```ruby
 require "prime"

 prime = Prime.each

 n = 0
 loop do
   printf "%d " % prime.next
   break if n > 10
   n += 1
 end
 # >> 2 3 5 7 11 13 17 19 23 29 31 37 
```

여기선 loop에 블록을 넘기지 않으면 Enumerator가 리턴됩니다. 이를
이용하면 loop에 인덱스를 추가할 수 있습니다.( thanks to @no6v 님)

```ruby
 loop # => #<Enumerator: main:loop>
 
 loop.with_index do |_,n|
   printf "%d " % prime.next
   break if n > 10
 end
 # >> 2 3 5 7 11 13 17 19 23 29 31 37 
```

블록의 첫번째 인수가 nil이 되어버립니다만.


### 38. BasicObject#instance_eval
`instance_eval`은 객체 생성을 DSL처럼 할 때 자주 사용됩니다.

```ruby
class Person
  def initialize(&blk)
    instance_eval(&blk)
  end
  def name(name)
    @name = name
  end
  def age(age)
    @age = age
  end
  def job(job)
    @job = job
  end
  def profile
    [@name, @age, @job] * '-'
  end
end

t = Person.new do
  name 'Charlie'
  age  13
  job  :programmer
end

t.profile # => "Charlie-13-programmer"
```

하지만 이러한 콘텍스트를 일시적으로 바꾸는 방법은 DSL이 아니라도
편리하게 사용할 수 있습니다. 테스트 결과의 평균값을 구해보죠. 우선은 일반적인 방법으로.

```ruby
scores = [56, 87, 49, 75, 90, 63, 65]
scores.inject(:+) / scores.size # => 69
```

짧은 코드인데 scores 변수가 3번이나 나옵니다.

instance_eval을 사용하면 score를 사용하지 않을 수 있습니다.

```ruby
[56, 87, 49, 75, 90, 63, 65].instance_eval { inject(:+) / size } # => 69
```


다음으로 표준편차 sd를 구해보죠. 우선은 일반적인 방법으로

```ruby
scores = [56, 87, 49, 75, 90, 63, 65]
avg = scores.inject(:+) / scores.size
sigmas = scores.map { |n| (avg - n)**2 }
sd = Math.sqrt(sigmas.inject(:+) / scores.size) # => 14.247806848775006
```

instance_eval로.
```ruby
scores = [56, 87, 49, 75, 90, 63, 65]
sd = scores.instance_eval do
  avg = inject(:+) / size
  sigmas = map { |n| (avg - n)**2 }
  Math.sqrt(sigmas.inject(:+) / size)
end
sd # => 14.247806848775006
```

비슷한 변수를 블록 안에 집어넣는 것은 물론 블록에서 식이 정리되니 더 보기 좋지 않나요?

### 39. 정규 표현식 : 이름 있는 참조
정규 표현식 안에서 `()`를 부분 매치에 사용할 수 있습니다. 더욱이 이 매치에 이름을 붙이고 싶으면 `?\<pattern\>`을 사용하면 됩니다.

```ruby
langs = "python lisp ruby haskell erlang scala"
m = langs.match(/(?<lang>\w+)/) # => #<MatchData "python" lang:"python">
m['lang'] # => "python"
```

그리고 정규표현 리터럴을 좌변에 사용하면 이를 지역 변수처럼 사용할 수
있습니다.

```ruby
langs = "python lisp ruby haskell erlang scala"
if /(?<most_fun_lang>r\w+)/ =~ langs
  printf "you should learn %s!", most_fun_lang
end
# >> you should learn ruby!
```

### 40. 정규표현:POSIX 문자 클래스
Ruby 1.9에서 `\w`는 일본어에 매치하지 않습니다.1.9에서 일본어에도 매치시키기 위해서는 POSIX 문자 클래스 `word`를 사용하는 방법이 있습니다.

```ruby
need_japanese = "this-日本語*is*_really_/\\変わってる!"
need_japanese.scan(/\w+/) # => ["this", "is", "_really_"]
need_japanese.scan(/[[:word:]]+/) # => ["this", "日本語", "is", "_really_", "変わってる"]
```

### 41. String#match
`String#match`는 MatchData 객체를 리턴하므로 다음과 같이 사용할 수 있습니다.

```ruby
date = "2012february14"
m = date.match(/\D+/)
mon, day, year = m.to_s.capitalize, m.post_match, m.pre_match
"#{mon} #{day}, #{year}" # => "February 14, 2012"
```

하지만 match는 블록을 받으므로 다음과 같이 사용해도 됩니다.

```ruby
date = "2012february14"
mon, day, year = date.match(/\D+/) { |m| [m.to_s.capitalize, m.post_match, m.pre_match] }
"#{mon} #{day}, #{year}" # => "February 14, 2012"
```

### 42. String#unpack
문자열을 정해진 길이를 기준으로 나누고 싶을 땐 어떻게 하는 게
좋을까요? 먼저 정규표현식을 사용해보죠.

```ruby
a_day = '20120214'
a_day.match(/(.{4})(.{2})(.{2})/).captures # => ["2012", "02", "14"]
```

`String#unpack`를 사용하면 좀 더 간단히 해결할 수 있습니다. (thanks to @no6v 님)

```ruby
a_day = '20120214'
a_day.unpack('A4A2A2') # => ["2012", "02", "14"]
```


### 43. Enumerable#each_with_object
Enumerable#map 메소드를 활용하는 방법으로 블록 대신에 `&`에 심볼을 붙이는 기술이 알려져 있습니다.

```ruby
langs = ["ruby", "python", "lisp", "haskell"]
langs.map(&:capitalize) # => ["Ruby", "Python", "Lisp", "Haskell"]
```

하지만 이 기술은 인수를 받는 메소드는 사용할 수 없다는 문제가 있습니다.

```ruby
langs = ["ruby", "python", "lisp", "haskell"]
langs.map(:+, 'ist') # => 
# ~> -:2:in `map': wrong number of arguments (2 for 0) (ArgumentError)
# ~> 	from -:2:in `<main>'
```

이럴 땐 `each_with_object` 메소드를 사용할 수 있습니다.

```ruby
langs = ["ruby", "python", "lisp", "haskell"]

langs.each_with_object('ist').map(&:+) # => ["rubyist", "pythonist", "lispist", "haskellist"]

[1, 2, 3].each_with_object(10).map(&:+) # => [11, 12, 13]
(1..5).each_with_object(2).map(&:**) # => [1, 4, 9, 16, 25]
```

이름이 조금 길죠. 그것보다 네. 그냥 map에 블록을 넘기세요.

그리고 이런 방법도 있습니다. (thanks to @tmaeda 님)

```ruby
[1, 2, 3].map(&10.method(:+)) # => [11, 12, 13]
```
리시버와 인수가 역전되므로 용도는 한정적입니다만.

### 44. Float::INFINITY
임의의 수열을 만들고자 할 때 하지만 크기가 미리 정해지지 않는 경우가
있습니다. 일단은 `Enumerator`로 시도해보죠.

```ruby
sequence = Enumerator.new { |y| i=1; loop { y << i; i+=1 } }

sequence.take(10) # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
100.times.map { sequence.next } # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
```

단 `Enumerator`를 사용하지 않아도 비슷한 작업을 할 수 있는데, 이 때 무한을 의미하는 상수 `Float::INFINITY`를 사용합니다.

```ruby
sequence = 1..Float::INFINITY
sequence.take(10) # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

seq = sequence.to_enum
100.times.map { seq.next } # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
```

Infinity는 0으로 나눠서 얻을 수 있으니 아래와 같이 작성할 수도 있습니다.

```ruby
(1..1.0/0).take(10) # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

1.step(1.0/0, 1.5).take(20) # => [1.0, 2.5, 4.0, 5.5, 7.0, 8.5, 10.0, 11.5, 13.0, 14.5, 16.0, 17.5, 19.0, 20.5, 22.0, 23.5, 25.0, 26.5, 28.0, 29.5]
```

### 45. Enumerable#grep
case의 동일성 판단은 `===` 메소드를 사용합니다.

```ruby
temp = 85
status =
  case temp
  when 1..40;   :low
  when 80..100; :Danger
  else :ok
  end
status # => :Danger

class Trivia
end
t = Trivia.new

klass =
  case t
  when String; 'no good'
  when Array;  'no no'
  when Trivia; 'Yes!Trivia!'
  end
klass # => "Yes!Trivia!"
```

예는 `Range#===`와 `Module#===`를 사용한 동일성 판정입니다.

사실 `Enumerable#grep`에 의한 패턴 매치도 ===로 동일 여부를 판단합니다.

```ruby
numbers = 5.step(80, 5).to_a # => [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80]
numbers.grep(20..50) # => [20, 25, 30, 35, 40, 45, 50]

t1, t2, t3, t4, t5 = 'trivia', Trivia.new, [:trivia], {trivia:1}, Trivia.new

[t1, t2, t3, t4, t5].grep(Trivia) # => [#<Trivia:0x000001008613b0>, #<Trivia:0x000001008610e0>]
```

### 46. String#gsub

문자열에서 나타나는 부분 문자열이 나타나는 회수가 필요한 경우가
있습니다. 보통은 `String#scan`을 사용하면 됩니다.

```ruby
DATA.read.scan(/hello/i).count # => 48

__END__
You say "Yes", I say "No".
You say "Stop" and I say "Go, go, go".
Oh no.
You say "Goodbye" and I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello, hello, hello".
I don't know why you say goodbye, I say hello.
I say "High", you say "Low".
You say "Why?" And I say "I don't know".
Oh no.
You say "Goodbye" and I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello, hello, hello".
(Hello, goodbye, hello, goodbye. Hello, goodbye.)
I don't know why you say "Goodbye", I say "Hello".
(Hello, goodbye, hello, goodbye. Hello, goodbye. Hello, goodbye.)
Why, why, why, why, why, why, do you
Say "Goodbye, goodbye, bye, bye".
Oh no.
You say "Goodbye" and I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello".
You say "Yes", I say "No".
(I say "Yes", but I may mean "No").
You say "Stop", I say "Go, go, go".
(I can stay still it's time to go).
Oh, oh no.
You say "Goodbye" and I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello, hello, hello".
I don't know why you say "Goodbye", I say "Hello-wow, oh. Hello".
Hela, heba, helloa. Hela, heba, helloa. Hela, heba, helloa.
Hela, heba, helloa. (Hela.) Hela, heba, helloa. Hela, heba, helloa.
Hela, heba, helloa. Hela, heba, helloa. Hela, heba, helloa.
```
훌륭한 가사네요.

하지만 `String#gsub`는 블록을 넘기지 않으면 Enumerator 객체를 리턴하니 같은 일을 할 수 있습니다.

```ruby
DATA.read.gsub(/hello/i).count # => 48

__END__
You say "Yes", I say "No".
You say "Stop" and I say "Go, go, go".
Oh no.
You say "Goodbye" and I say "Hello, hello, hello".
....
```


### 47. 클래스 메소드 정의
클래스나 모듈의 메소드를 정의할 때는 일반적으로 아래와 같이 합니다.

```ruby
class Calc
  class << self
    def >>(exp)
      eval exp
    end
  end
end

Calc >> '1 + 2' # => 3
Calc >> '10 ** 2' # => 100
```

바깥 쪽 클래스의 정의를 `Class.new`나 `Module.new`을 사용하면 다음과 같이 작성할 수도 있습니다.

```ruby
class << Calc = Class.new
  def >>(exp)
    eval exp
  end
end

Calc >> '123 / 4.0' # => 30.75
Calc >> '2 * Math::PI' # => 6.283185307179586
```

이 자체는 별 게 없습니다반 `Calc.>>`라는 메소드 이름이 irb 스러워서 좋지 않나요?

### 48. true, false, nil
Ruby에서 다루는 모든 데이터는 객체라 숫자도 클래스도
그리고 `true`, `false`, `nil`도 모두 객체라는 건 알고 계시겠죠. 따라서 당연하게도 이러한 객체들은 메소드를 가지고 있고 메소드를 추가할 수도 있습니다.

```ruby
def true.true?  'Beleive me. you are true.'
end

def false.true?  'I said, you are false!'
end

my_point, your_point = 87, 35
border = 60
my_result = my_point > border
your_result = your_point > border

my_result # => true
my_result.true?# => "Beleive me. you are true."
your_result # => false
your_result.true?# => "I said, you are false!"
```

`nil`에도 메소드를 정의해보죠.`===` 메소드를 정의해서 case에서 사용해보죠.

```ruby
def nil.===(other)
  other.nil?|| other.empty?end

def proceed(obj)
  Array(obj).join.split(//).join('*')
end

full = "I'm full."
empty = ""
_nil_ = nil

objects = [full, empty, _nil_, %w(I am full), [], {:hello => 'world'}, {}]

for obj in objects
  case obj
  when nil
    puts "Stop it!`#{obj.inspect}` is empty or nil."
  else
    puts proceed obj
  end
end
# >> I*'*m* *f*u*l*l*.
# >> Stop it!`""` is empty or nil.
# >> Stop it!`nil` is empty or nil.
# >> I*a*m*f*u*l*l
# >> Stop it!`[]` is empty or nil.
# >> h*e*l*l*o*w*o*r*l*d
# >> Stop it!`{}` is empty or nil.
```
너무 심취했나요.


### 49. 강제 타입 변환 coerce
숫자 리스트에 n배를 곱하면 각각의 요소가 n배가 되는 객체가 필요하다고
해보죠. Array를 상속한 NumList로 이를 구현해보겠습니다.

```ruby
class NumList < Array
  def *(n)
    map { |e| e * n }
  end
end

numlist = NumList[1, 2, 3]

numlist * 3 # => [3, 6, 9]
```

욕심을 내서 곱하는 수를 앞에 놓아도 작동하도록 만들어보겠습니다.

```ruby
3 * numlist # => 
# ~> -:15:in `*': NumList can't be coerced into Fixnum (TypeError)
# ~> 	from -:15:in `<main>'
```

당연히 `Fixnum#*` 메소드는 인수로 NumList 객체를 받을 수 없으므로
에러가 납니다. 설마 Fixnum#* 수정하시진 않겠죠. 어떻게 해야할까요.

이를 때는 `coerce`(강제 타입 변환)을 사용할 수 있습니다.

```ruby
class NumList < Array
  def *(n)
    map { |e| e * n }
  end

  def coerce(n)
    [self, n]
  end
end

numlist = NumList[1, 2, 3]

numlist * 3 # => [3, 6, 9]
3 * numlist # => [3, 6, 9]
```

Fixnum#* 메소드는 인수가 형변환이 불가능할 경우 객체의 coerce 메소드를 호출하는데 이를 이용하는 방법입니다.


### 50. DATA.rewind
DATA는 \_\_END\_\_ 이후의 부분을 File 객체로 불러들인 객체입니다.
따라서 rewind 메소드를 사용할 수 있는다. 이는 \_\_END\_\_ 이후의 첫
행으로 돌아가는 게 아니라 전체 파일의 첫 행으로 돌아갑니다. 따라서 이를 사용하면, 아차차.. Quine를 만들 수 있습니다.

```ruby
#!/usr/bin/env ruby
require "g"
def evaluate(str)
  op = %w(\+ \* \/)
  digit = /-*\d+/
  if m = str.match(/(#{op})\s+(#{digit})\s+(#{digit})/)
    op, a, b = m.captures
    inner = a.to_i.send(op, b.to_i)
    str = m.pre_match + inner.to_s + m.post_match
    evaluate(str)
  else
    str
  end
end
g evaluate("+ * 3 4 5")
DATA.rewind
puts DATA.to_a
__END__
```

이 코드를 실행하면 evaluate의 결과가 출력되는 것과 함께 코드 자체가 표준 출력으로 출력됩니다.

### 51. Ruby 키워드
Ruby 키워드는 언어의 예약어가 아니므로 명시적인 문맥에서 사용하기만 한다면
메소드 이름으로 사용하는 것도 가능합니다. 여기에서는 `case`, `if`, `for`을 Trivia 클래스에서 정의해보겠습니다.

```ruby
class Trivia
  def case(klass)
    case self
    when klass; 'You are my sunshine.'
    else 'No, you are Alien for me'
    end
  end

  def if(bool, arg)
    if bool
      yield arg
    else
      arg.reverse
    end
  end
  
  def for(list)
    list.map { |e| yield e }
  end
end

t = Trivia.new

t.case(Trivia) # => "You are my sunshine."
t.case(Array) # => "No, you are Alien for me"

t.if(true, 'my name is charlie') { |str| str.upcase } # => "MY NAME IS CHARLIE"
t.if(false, 'my name is charlie') { |str| str.upcase } # => "eilrahc si eman ym"

t.for([*1..10]) { |i| i**2 } # => [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```

### 52. YAML 태그 지정
사용자 데이터를 다루는 프로그램을 만들 때 프로그램과 데이터를 분리하기 위해 `yaml 라이브러리`를 사용하면 편리합니다.

```ruby
require "yaml"

langs_array = YAML.load(DATA)
puts langs_array.map { |lang| "My favorite language is " + lang }

# >> My favorite language is Ruby
# >> My favorite language is Lisp
# >> My favorite language is C++

__END__
---
- Ruby
- Lisp
- C++
```

여기서 `!ruby/`으로 시작하는 태그를 사용하면 문자열에 해당하는
클래스를 지정할 수 있는데 `!ruby/object:<클래스 이름>` 태그를 사용하면
임의의 클래스를 지정할 수도 있습니다. Language 클래스 객체로 YAML 데이터를 읽어와보겠습니다.

```ruby
 require "yaml"
 class Language
   attr_accessor :name, :born, :designer
   def profile
     [name, born, designer] * '-'
   end
 end
 
 members = YAML.load(DATA)
 
 puts members.map { |member| member.profile }
 
 # >> Ruby-1993-Yukihiro Matsumoto
 # >> Lisp-1958-Joh McCarthy
 # >> C++-1983-Bjarne Stroustrup
 
 __END__
 --- 
 - !ruby/object:Language
   name: Ruby
   born: 1993
   designer: Yukihiro Matsumoto
 - !ruby/object:Language
   name: Lisp
   born: 1958
   designer: Joh McCarthy
 - !ruby/object:Language
   name: C++
   born: 1983
   designer: Bjarne Stroustrup
```

### 53. 단항연산자 ~ (tilde)
단항연산자 `~`는 사실 메소드인데 이 메소드가 어디서 정의되어있는 지 
아시나요? 맞습니다. `Fixnum`과 `Bignum`에서 NOT 연산을 하기 위해 만들어진 연산자입니다.

```ruby
~1 # => -2
~2 # => -3
~3 # => -4
~7 # => -8

1.to_s(2) # => "1"
2.to_s(2) # => "10"
3.to_s(2) # => "11"
7.to_s(2) # => "111"

(~1).to_s(2) # => "-10"
(~2).to_s(2) # => "-11"
(~3).to_s(2) # => "-100"
(~7).to_s(2) # => "-1000"
```

`Regexp`에도 정의되어있습니다. 이 메소드는 gets에서 입력을 받아 `$_`와 패턴 매치를 하기위해 사용됩니다.

```ruby
$_ = 'Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.'

pos = ~ /\w{8,}/
puts "8+long-word `#{$&}` appeared at #{pos}"

# >> 8+long-word `programming` appeared at 31
```

단항연산자의 특이한 점은 리시버가 메소드 뒤에 오는 점입니다. 이런
특징을 활용해 편리한 메소드들을 잔뜩 정의해서 써야만 하겠죠. 연산 우선 순위도 높아 메소드 체인에서도 문제 없이 사용할 수 있습니다.

```ruby
class String
  def ~
    reverse
  end
end

class Symbol
  def ~
    swapcase
  end
end

class Array
  def ~
    reverse
  end
end

class Hash
  def ~
    invert
  end
end

~'よるなくたにし なんてしつけいい' # => "いいけつしてんな しにたくなるよ"

s = 'godtoh'
~s.swapcase # => "HOTDOG"

~:Hello # => :hELLO

~[1,2,3,4] # => [4, 3, 2, 1]

~{ruby: 1, lisp: 2} # => {1=>:ruby, 2=>:lisp}
```

뭐 확실히 `~`만으론 메소드의 의도를 파악하기 힘듭니다만...

### 54. 멀티 바이트 메소드
1.9부터 메소드 이름에 멀티 바이트 문자를 사용할 수 있는데 실제 활용
사례는 별로 없습니다. 이래서는 Ruby가 불쌍해지니 이러한 방법을 포교해보죠.

```ruby
class String
  def ©(name='anonymous')
    self + " - Copyright © #{name} #{Time.now.year} All rights reserved. -"
  end

  def 
    self + ' - Designed by Apple in California -'
  end
end

'this is my work'.©(:Charlie) # => "this is my work - Copyright © Charlie 2012 All rights reserved. -"

poetry = <<EOS
Ruby is not a Gem
Gem is not a Jam
Jam is not a Jelly
Jam is about Traffic
Gem is about Library
Ruby is about Language!EOS

puts poetry.©

# >> Ruby is not a Gem
# >> Gem is not a Jam
# >> Jam is not a Jelly
# >> Jam is about Traffic
# >> Gem is about Library
# >> Ruby is about Language!# >>  - Copyright © anonymous 2012 All rights reserved. -

'hello, apple'. # => "hello, apple - Designed by Apple in California -"
```

``는 Mac keyboard에서 `~$k`(Option+Shift+k)를 누르면 나옵니다. (역주:
이 기호는 애플 상표 기호로, Mac에서만 제대로 나옵니다.)

`Numeric`에는 화폐 메소드를 추가해보죠. 여기서는 `def method`를 사용해 일일히 클래스를 다시 여는 번거로움을 줄여보겠습니다.

```ruby
def def_method(name, klass=self.class, &body)
  blk = block_given??body : ->{ "#{name}: not implemented yet." }
  klass.class_eval { define_method("#{name}", blk) }
end

currencies = %w(¥ € £ $).zip [:JPY, :EUR, :GBP, :USD]
currencies.each do |cur, sym|
  def_method(cur, Numeric) do
    int, dec = Exchange(self, sym).to_s.split('.')
    dec = dec ?".#{dec[/.{1,2}/]}" : ''
    cur + int.reverse.scan(/.{1,3}/).join(',').reverse + dec
  end
end

def Exchange(num, _for_)
  num * {USD:1.0, JPY:81.3, EUR:0.76, GBP:0.62}[_for_]
end

123.45.¥ # => "¥10,036.48"
1000000.¥ # => "¥81,300,000.0"
123.€ # => "€93.48"
1000000.€ # => "€760,000.0"
123.45.£ # => "£76.53"
1000000.£ # => "£620,000.0"
```

뭐 입력이 좀 힘들긴 합니다만..


### 55. 비밀 메소드
위의 예처럼 Ruby에서는 키워드나 기호를 메소드 이름에 사용할 수
있습니다만 사용하지 못 하는 것도 있습니다. 예를 들어, `.`, `,`, `@`, `=`, `(`, `#`, `$` 는 메소드 이름에서 사용할 수 없습니다.

```ruby
def .
end
# ~> -:1: syntax error, unexpected '.'

def ,
end
# ~> -:1: syntax error, unexpected ','

def @
end
# ~> -:1: syntax error, unexpected $undefined

def =
end
# ~> -:1: syntax error, unexpected '='

def (
end
# ~> -:2: syntax error, unexpected keyword_end

def #
end
# ~> -:4: syntax error, unexpected $end

def $
end
# ~> -:1: syntax error, unexpected $undefined
```

보통은 여기서 납득하고 넘어가겠죠. 하지만 `define_method`를 사용하면 이러한
기호들도 메소드 이름으로 사용할 수 있습니다. 먼저 def_method를 사용해 이런 메소드를 정의해보죠.

```ruby
def def_method(name, klass=self.class, &body)
  blk = block_given??body : ->{ "#{name}: not implemented yet." }
  klass.class_eval { define_method("#{name}", blk) }
end

class Trivia
  
end

methods = [".", ",", "@", "=", "(", "#", "$"]
methods.each { |meth| def_method meth, Trivia }

Trivia.public_instance_methods(false) # => [:".", :",", :"@", :"=", :"(", :"#", :"$"]
```

되죠?

하지만 이 메소드들에는 치명적인 단점이 하나 있습니다.

그건...

호출이 불가능하는 겁니다! ^^;

```ruby
t = Trivia.new

t.. # => 
t., # => 
t.@ # => 
t.= # => 
t.( # => 
t.# # => 
t.$ # => 

# ~> -:42: syntax error, unexpected ')'
# ~> ...1335430361_15646_549583 = (t..);$stderr.puts("!XMP1335430361...
# ~> ...                               ^
# ~> -:43: syntax error, unexpected ','
# ~> ..._1335430361_15646_549583 = (t.,);$stderr.puts("!XMP133543036...
# ~> ...                               ^
# ~> -:44: syntax error, unexpected $undefined
# ~> ..._1335430361_15646_549583 = (t.@);$stderr.puts("!XMP133543036...
# ~> ...                               ^
# ~> -:45: syntax error, unexpected '='
# ~> ..._1335430361_15646_549583 = (t.=);$stderr.puts("!XMP133543036...
# ~> ...                               ^
# ~> -:48: syntax error, unexpected $undefined
# ~> ..._1335430361_15646_549583 = (t.$);$stderr.puts("!XMP133543036...
# ~> ...                               ^
# ~> -:65: syntax error, unexpected $end, expecting ')'
```

단 `Object#send`나 `Method#call` 메소드를 사용해 호출하는 건 가능한데 귀찮습니다.

```ruby
t = Trivia.new

t.send '.' # => ".: not implemented yet."
t.method(',').call # => ",: not implemented yet."

def_method('@', Trivia) do |num|
  "#{self.class}".center(num, '@')
end

def_method('(', Trivia) do |str|
  "( #{str} )"
end

t.send '@', 12 # => "@@@Trivia@@@"
t.send '(', 'I love Ruby'  # => "( I love Ruby )"
```
즉 이러한 기호들을 사용한 메소드는 일반적인 방법으로는 정의하거나
호출하는 게 불가능하지만, 일반적이지 않은 특별한 방법을 사용하면
정의할 수도 있고 호출할 수도 있는 특수한 메소드들이라고 할 수
있습니다. 저는 이러한 메소드들을 특수한 방법으로 숨겨진 메소드, 즉
`비밀(hidden)` 메소드라고 이름 붙였습니다. 어디에 사용할 지는... 저도 잘 모르겠습니다..


이상으로 Ruby 55가지 기법을 설명했습니다. 새로운 발견은 있으셨나요? 

(추신：2013-03-31)@no6v 님 이름이 @no6v1 님으로 되어있었습니다. 수정했습니다. 죄송합니다.

---

<a href="/books/">
  <img src="http://melborne.github.io/assets/images/2013/03/ruby_trivia_cover.png" alt="trivia" style="width:200px" />
</a>

<a href="http://gum.co/owIqH" class="gumroad-button">E-Book 알아두면 도움이 되는 55가지 루비 기법 EPUB/MOBI판</a><script type="text/javascript" src="https://gumroad.com/js/gumroad-button.js"></script><script type="text/javascript" src="https://gumroad.com/js/gumroad.js"></script>

이 링크는 Gumroad의 상품 구매 페이지입니다. 클릭하면 오버레이 윈도우가
뜨고 여기서 카드 정보를 입력하면 구입이 가능합니다. 구입을 하려면 카드
정보와 이메일 주소를 입력해야합니다. 구입이 정상적으로 완료되면 입력한 이메일로 다운로드 가능한 링크가 보내집니다.

