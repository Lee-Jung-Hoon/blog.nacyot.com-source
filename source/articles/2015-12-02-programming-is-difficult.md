---
title: 프로그래밍은 왜 어려운가 - 벤 프라이(Ben Fry)의 Distellamap으로 생각해보는 다익스트라의 'GOTO문은 해롭다(Go To Statement Considered Harmful)' 
date: 2015-12-03 00:10:00 +0900
author: nacyot
tags: article, ben_fry, edsger_dijkstra, goto, programming, atari_2600, abstraction, visualization, human, computer, program, process
categories: article
title_image: http://i.imgur.com/xwuGSjK.pngg
published: true
toc: false
comment: false
---

최근에 현대카드 디자인 라이브러리에서 열린 [Designing with Data][design_data] 전시를 보고 왔는데 그 중에서 Ben Fry의 [Distellamap](http://benfry.com/distellamap/)이라는 작품이 유독 인상깊었습니다.

이 작품은 Atari 2600 게임 코드(어셈블리) 전체를 한 평면에 놓고 코드가 점프하는 지점들을 연결한 작품입니다. 얼핏 봐도 알 수 있지만 프로그램 내에서도 아주 많은 선들로 연결되어있습니다. 프로그램은 선형적으로 실행되지 않는다는 걸 노골적으로 보여주고 있죠.

[design_data]: http://design.hyundaicardcapital.com/771

<!--more-->

---

개인적으로 **프로그래밍은 왜 어려운가**라는 주제에 관심이 있는데, 이 작품은 프로그램의 실행 로직을 사람이 쫓아갈 수 없는 프로세스의 본질적인 비선형성을 잘 보여주고 있습니다. 제가 CS 전공이 아니라 정확하지는 않을 수 있지만, 이는 GOTO이라는 아주 저수준의 제어구조에서 오는 특징이기도 합니다. 실제로 현대적인 프로그래밍 언어들인 GOTO와 같은 저수준 제어구조를 의도적으로 배제하는 대신에 함수, 반복문, 조건문과 같은 고수준의 제어 추상화 구문을 제공합니다.

프로그래머들은 대개 GOTO문은 나쁘다고 배우는데, 그 이유까지 생각해보기는 쉽지 않습니다. 저는 distellamap이 보여주는 GOTO의 비선형성을 보면서 GOTO가 왜 나쁜지 다시 한 번 생각해보았습니다. GOTO의 가장 큰 특징은 비선형성에 있다고 생각했는데, 사실 고수준의 제어문을 도입한다고 하더라도 프로세스의 비선형성은 전혀 사라지지 않는다는 사실을 깨달았습니다.

제가 내린 결론은 이렇습니다. GOTO는 비선형성 때문에 나쁜 게 아니라 섬세하지 않기 때문에 나쁩니다. GOTO는 어떤 지점에서라도 어디로라도 갈 수 있습니다. 반면에 고수준 제어구조에서는 점프할 수 있는 곳이 엄격하게 한정됩니다. 또한 콜스택을 통해서 깊이라는 개념도 가지고 있습니다. 즉, 정도의 차이는 있지만 GOTO도 고수준 제어문도 비선형적인 프로세스로 실행된다는 사실 자체는 다르지 않습니다.

---

다익스트라의 악명 높은(?) [Go To Statement Considered Harmful][goto_harmful]는 한 구절 한 구절 주옥 같은데, 흥미로운 구절 하나를 인용해볼까합니다.

[goto_harmful]: http://www.u.arizona.edu/~rubinson/copyright_violations/Go_To_Considered_Harmful.html

> My second remark is that our intellectual powers are rather geared to master static relations and that our powers to visualize processes evolving in time are relatively poorly developed. For that reason we should do (as wise programmers aware of our limitations) our utmost to shorten the conceptual gap between the static program and the dynamic process, to make the correspondence between the program (spread out in text space) and the process (spread out in time) as trivial as possible.

> 내 두번째 주장은 우리의 지적 능력은 정적인 관계에 더 잘 들어맞고, 시간에 따른 진행과정을 시각화하는 능력은 상대적으로 덜 발달했다는 점이다. 이러한 이유로 우리는 (자신의 한계를 알고 있는 현명한 프로그래머로서) 정적인 프로그램과 동적인 프로세스 사이의 간극을 줄이기 위해 최선을 다해야 하며, 이를 통해 프로그램(텍스트 공간에 흩뿌려진)과 (시간에 흩뿌려진) 진행과정 사이를 가능한 일치시켜야 한다.

여기서 다익스트라는 아주 명시적으로 정적인 프로그램과 동적인 프로세스 사이의 갭에 대한 이야기를 하고 있습니다. 저는 프로그램과 프로세스가 각각 프로그래밍의 인간적인 면과 기계적인 면에 대응한다고 봅니다. 즉 프로그램은 인간의 사고 방식에 대응하며, 프로세스는 컴퓨터의 실행 방식에 대응합니다. GOTO 조차도 이미 충분히 추상화되어있는 형태라 컴퓨터의 실행방식보다는 인간의 사고 방식에 훨씬 더 가깝습니다. 따라서 프로그래밍이 어려운 가장 근본적인 이유는 인간의 사고 방식과 프로그램의 실행 모델이 전혀 다르기 때문이 아닐까요.

더욱 흥미로운 점이 있습니다. 프로그래밍 언어는 이러한 추상화된 제어구조를 더 섬세하게 다룰 수 있는 형태로 발전해나가고 있는데, 문제는 사실 그러한 이상적인 추상화는 사람들의 일반적인 사고 흐름에서 빗겨나 있습니다. 제가 앞서 말한 인간의 사고 방식은 엄밀히 말하면 사람들의 일반적인 사고의 흐름이라기보다는 아주 이상적인 잘 추상화된 사고 방식에 가깝습니다. 결국에 다익스트라가 말한 것에 덧붙여 한 가지 분열이 더 발생합니다. 우리는 프로그래밍을 이해하기 위한 세가지 접근방식에 대해 생각해볼 필요가 있습니다.

1. 사람들의 일반적인 사고 방식
2. (텍스트 상에서) 프로그래밍 언어에서 추구하는 이상적인 추상화를 구현하기 위한 사고방식
3. (시간 상에서) 기계가 실제로 작동한 방식

안타깝게도 이 세가지는 자동적으로 일치하지 않습니다. 오히려 이것들을 화해시키는 거의 불가능에 가깝습니다.

---

[![Java Callstack](http://i.imgur.com/g1ipwVA.png)](https://twitter.com/bombasstard/status/659870778410823680)

이러한 분열은 디버깅이 프로그래밍과 다른 형태의 사고 방식을 요구하는 데서도 드러납니다. 디버깅은 프로그래밍의 연장선 상에 있다고 여겨지곤 합니다. 하지만 디버깅은 프로그래밍과는 아주 다른 능력을 요구합니다. 프로그래머는 정적인 프로그램을 작성하지만 디버깅을 통해서 프로세스가 실행되는 중간 과정에 개입하게 됩니다. 디버깅은 콜스택을 추적하기 때문에 내가 작성한 프로그램이 실제로 얼마나 깊은 위치에서 실행되는 지를 보여줍니다. 일반적으로 소스 코드 위에서 한 단계 두 단계 정도를 쫓아가도 수십단계를 쫓아가며 프로그램의 구조를 이해하는 경우는 드뭅니다. 그런데 바로 그런 방식이 컴퓨터(프로세스)가 프로그램을 실행하는 방식입니다. 즉 사고의 흐름과 컴퓨터의 실행 모델의 접점은 내가 만든 프로그램의 실행 구조를 내가 직접 쫓아가는 게 아주 어렵다는 걸 깨닫게 해줍니다. 더욱이 이상적인 추상화를 위해 구축된 복잡한 구조는 프로그램 실행이 아주아주 깊은 구조에서 이루어지는 경향을 만듭니다.

---

흥미롭게도 고수준 프로그래밍 언어를 사용하는 프로그래머들은 디버깅을 제외하면 컴퓨터의 실행 방식에 개입할 일이 거의 없습니다. 그래서 이런 영역은 대개 언어가 위임 받아서 다뤄집니다. 문제는 이상적인 추상화를 다루는 두번째 영역으로 이관됩니다. 실제로 루비를 만든 [마츠는 초심자를 위한 프로그래밍 언어][beginner_programming]라는 글에서 두번째 관점에서 초심자들의 한계를 이야기하면서 초심자들이 선호하는 언어에 대해서 이야기합니다. 이전에 짧게 언급했던 Clojure를 만든 리치 히키의 [Simple made easy][simple_made_easy]라는 발표도 두번째 관점에서 함수형 프로그래밍 언어가 어떻게 객체지향적 언어보다 우월한지를 보여줍니다. 특히 객체지향과 함수형 프로그래밍이라는 두 개의 큰 맥락은 두 번째 영역이 어떻게 발전해왔는지를 잘 보여줍니다. 어쨌건 공통된 특징은 고수준 언어일수록 언어적인 표현성과 섬세하게 나눠지는 비선형적인 코드 구성을 중요시한다는 점입니다. 프로세스는 여전히 가동되지만 가려져버리고, 저수준 언어에서보다 덜 중요한 것으로 여겨집니다.

[simple_made_easy]: http://www.slideshare.net/evandrix/simple-made-easy
[beginner_programming]: http://wiki.nacyot.com/documents/programming_language_for_beginner/

---

> 컴퓨터가 이해할수 있는 코드는 어느 바보나 다 작성할 수 있다. 좋은 프로그래머는 사람이 이해할 수 있는 코드를 짠다 - 마틴 파울러

프로그래밍은 왜 어려운가, 좀 더 쉬운 부분부터 짚어보면 추상화가 어렵기 때문입니다. 이 글에서 이야기했던 개념들로 설명하자면 인간의 일반적인 사고방식과 프로그래밍적 추상화가 다르기 때문입니다. 이는 수학이 어려운 이유와도 비슷하다고 생각합니다. 하지만 수학적인 사고방식에 가까운 함수형 프로그래밍 언어보다는 절차형 언어에 기반한 객체지향 언어가 업계에서 지배적이었던 걸 생각해보면 이러한 추상화에 대한 감각이 반드시 수학적인 사고방식을 요하는 것은 아닙니다. 분명한 건 어쨌거나 객체지향이든 람다 칼큘러스든 일반인들이 이해하기는 곧바로 이해하기는 굉장히 비직관적이고 어려운 개념이라는 점입니다. 이를 위해서 많은 사람들이 비유를 시도하지만, 대개는 혼란을 더하거나 중요한 개념에 대한 잘못된 인식을 심어주곤 합니다.

하지만 추상화가 어려운 건 프로그래밍이 어려운 일부밖에 설명하지 못 합니다. 저는 오랫동안 프로그래밍을 해왔지만 많은 부분에 있어서 컴퓨터는 내가 제어할 수 없다는 공포심 같은 것을 가지고 있습니다.

다시 distellamap으로 돌아가보겠습니다. 추상화가 어려움에도 불구하고 프로그래밍이 어려운 좀 더 본질적인 이유는, distellamap이 더 잘 보여주고 있다고 생각합니다. 프로그래머가 작성한 프로그램과 컴퓨터가 실행하는 프로세스는 일치하지 않습니다. 이러한 관계는 어지간해서는 보기 힘듭니다. 왜냐면 추상화에서 가장 중요한 교훈은 항상 최소한의 블록을 독립적으로 프로그래밍하는 일이기 때문입니다. 프로그래머는 각각의 블록이 자신의 역할만 제대로 하도록 프로그램을 작성합니다.

그래서 처음 프로그래밍을 배우는 사람에게 가르치기 어려운 것 중에 하나가 바로 어디에 무엇이 위치해야하는 지입니다. 왜 어렵냐면 코드가 프로그램 상에서 어디에 있는 지는 별로 중요하지 않기 때문입니다. 어디에 있어야 하는지, 어떤 순서여야 하는지 이런 당위성에 대한 주장은 모두 거짓말입니다. 코드는 어디에 있어도 무차별합니다(단, 이 주장은 대개 사실이지만 폭력적입니다). 심지어 프로젝트 디렉터리 구조는 그저 관습에 불과합니다. 대부분의 현대적인 프로그래밍 언어 해석기들은 파일의 위치 같은 것은 크게 신경 쓰지 않습니다. 사실 메모리에 로드되고 나면 프로세스는 파일 시스템의 위치나 순서에 구애받지 않기 때문이라는 게 더 적절한 표현일지도 모릅니다. 순서나 구조에 어떠한 당위성도 없기 때문에 사람들이 어려워하는 건 어떻게 보면 당연한 일입니다. 프로그래머들 역시 그렇게 해야된다는 건 알지만 왜 그렇게 해야하는 건지는 설명하기 어렵습니다. distellamap이 드러내는 프로세스의 비선형적 실행 구조는 이러한 잘 설명되지 않는 공백들을 보여줍니다.

안타깝게도 프로그램을 작성한 사람의 사고방식과 프로세스가 실행되는 방식이 자동적으로 일치하는 일은 영원히 일어나지 않겠죠. 그렇기 때문에 다시 한 번 다익스트라의 교훈을 되새길 필요가 있지 않을까요.

> we should do (as wise programmers aware of our limitations) our utmost to shorten the conceptual gap between the static program and the dynamic process

> 이러한 이유로 우리는 (자신의 한계를 알고 있는 현명한 프로그래머로서) 정적인 프로그램과 동적인 프로세스 사이의 간극을 줄이기 위해 최선을 다해야 하며, 이를 통해 프로그램(텍스트 공간에 흩뿌려진)과 (시간에 흩뿌려진) 진행과정 사이를 가능한 일치시켜야 한다.

## 관련된 글

* [Go To Statement Considered Harmful by Edsger W. Dijkstra (1968)][goto_original]
* [Go To Statement Considered Harmful:
A Retrospective by David R. Tribble (2005)][goto_retro]
* [Considered harmful][conharm] 
* [마이크로소프트웨어 창간 20주년 기념 :: 고전을 찾아서 ①  - 다익스트라, 왜 goto에 시비(?)를 거는가? ][maso]

[goto_original]: http://www.u.arizona.edu/~rubinson/copyright_violations/Go_To_Considered_Harmful.html
[goto_retro]: http://david.tribble.com/text/goto.html
[maso]:http://www.phpschool.com/gnuboard4/bbs/board.php?bo_table=old_talkbox&wr_id=289198
[conharm]: https://en.wikipedia.org/wiki/Considered_harmful

<br/>

P.S. 리뷰해주신 [raccoony][raccoony] 님 감사합니다.

[raccoony]: https://raccoonyy.github.io/
