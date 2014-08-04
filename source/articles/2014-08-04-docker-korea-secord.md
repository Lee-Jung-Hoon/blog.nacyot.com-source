---
title: Docker Korea 스터디 그룹 두번째 모임
author: nacyot
date: 2014-08-05 00:15:03 +0900
tags: Docker, Docker Korea, 도커, 스터디, Remotty, 스페이스 노아, 포럼, 토즈, 리모티, Service Discovery, Ghost, 고스트, 메트릭스, 로그, Graphite, Grafana, Elasticsearch, Kibana, 파이썬, consul, CoreOS, etcd, Fleet
published: true
---

얼마 전 '도커 코리아'라는 이름으로 스터디를 진행한다는 이야기를 전한 바 있습니다. 그 후로 시간이 흘러 지난 8월 2일에 도커 코리아 두번째 모임을 가졌습니다. 이번 스터디는 시범적인 차원에서 공개적으로 진행되었습니다. 단 아직 정기적인 스터디 지원이 확정되지 않아, 이번 모임은 소정의 참가비와 부족한 부분은 리모티 재정의 지원으로 이루어졌습니다. 리모티 팀원들을 비롯해 총 16분이 참석해 자리를 빛내주셨습니다 :)

<!--more-->

이 글에서는 스터디 그룹에서 공유한 내용들을 간략히 정리합니다.

## 도커를 이용한 파이썬 모듈 배포하기

<iframe src="//www.slideshare.net/slideshow/embed_code/37580971" width="600" height="440" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="https://www.slideshare.net/litiblue/ss-37580971" title="도커를 이용한 파이썬 모듈 배포하기" target="_blank">도커를 이용한 파이썬 모듈 배포하기</a> </strong> from <strong><a href="http://www.slideshare.net/litiblue" target="_blank">JunSeok Seo</a></strong> </div>

<iframe width="600" height="440" src="//www.youtube.com/embed/RRT58hbDXNs" frameborder="0" allowfullscreen></iframe>

먼저 Litiblue 님이 Docker를 이용해 파이썬 모듈을 배포한 경험에 대해서 발표해주셨습니다. 이 발표에서는 도커에 대한 전반적인 소개와 일반적인 서버에 직접 어플리케이션을 배포하는 것과 그로 인해 생기는 문제점을 도커를 통해서 어떻게 해결할 수 있는 지에 대해서 이야기해주셨습니다. 예를 들어 Litiblue 님이 배포하고자 했던 파이선 어플리케이션에는 APScheduler와 RPyC라는 라이브러리에 의존성이 있는데, 이러한 라이브러리들이 파이썬의 버전에 따라서 사용법이나 실행경로가 바뀌면서 생길 수 있는 있다고 합니다. 이러한 문제들을 도커를 통해서 어떻게 해결할 수 있는지 보여주셨습니다.

## 도커로 고스트 블로그 플랫폼 5분만에 설치하기

<iframe src="//slides.com/meoooh/setup-ghost-via-docker/embed" width="600" height="440" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

<iframe width="600" height="445" src="//www.youtube.com/embed/MGXMRJP4LhQ" frameborder="0" allowfullscreen></iframe>

다음으로 Han 님께서 '도커로 고스트 블로그 플랫폼 5분만에 설치하기'를 발표해주셨습니다. 최근에 유행하는 Ghost라고 하는 유명한 블로그 플랫폼이 있습니다만, 이 블로그 플랫폼을 도커를 써서 어떻게 배포할 수 있는 지에 대해서 다루고있습니다. 5분만에 배포하기라고 쓰고, 고스프 플랫폼 도커로 배포하면서 겪은 삽질기로 내용이 변모한 감이 없지 않아있었습니다만 :) 도커 파일 최적화, 이미지간 연결, .dokcerignore 파일의 사용법 등 도커를 사용하면서 필연적으로 궁금하게 되고, 활용해야만한 하는 많은 이야기들을 담고 있습니다.

## 도커(Docker) 메트릭스 & 로그 수집

<iframe src="//www.slideshare.net/slideshow/embed_code/37592250" width="600" height="440" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="https://www.slideshare.net/ext/docker-37592250" title="도커(Docker) 메트릭스 &amp; 로그 수집" target="_blank">도커(Docker) 메트릭스 &amp; 로그 수집</a> </strong> from <strong><a href="http://www.slideshare.net/ext" target="_blank">Daekwon Kim</a></strong> </div>

<iframe width="600" height="440" src="//www.youtube.com/embed/eFPsz0oCLSs" frameborder="0" allowfullscreen></iframe>

마지막 발표는 제가 'Docker와 로그 & 메트릭스 수집'이라는 주제로 발표를 했습니다. 로그 & 메트릭스 수집은 사실 새삼스럽게 나온 문제는 아닙니다만, 이러한 '기존의 문제'가 도커가 나오면서 어떻게 변해야하고, 어떤 방향으로 나아갈 것인지에 대해서 이야기했습니다. ElasticSearch와 Kibana, Graphite와 Grafana를 설치하고 로그 수집을 시연하는 거창한 데모를 준비했습니다만, 훌륭하게 실패하고 다행히 미리 준비해둔 이미지로 대체했습니다 ㅜ

로그 수집과 메트릭스에 관한 이야기는 지금 제일 관심있는 주제인 관계로 이 블로그에서도 자주 이야기해나갈 생각입니다. 기회가 되면 더 보충해나가도록 하죠.

Docker Korea 두번째 모임에서는 이와 같이 3가지 주제에 대해서 공유했습니다.

## Service Discovery 행아웃

오프라인 모임과 더불어 7월 30일에는 온라인 행아웃으로 Service Discovery 도구들에 대해서 이야기했습니다. Docker가 어플리케이션 배포의 복잡도를 확 낮춰주는 어플리케이션이라면 이렇게 배포가 되는 수많은 노드와 서비스들을 관리하는 게 그 다음으로 다뤄야할 주제입니다. 그런 이유로 Service Discovery는 현재 Docker와 함께 뜨거운 화두가 되고 있는 주제 중 하나입니다. 다들 아직 이러한 도구들에 대한 이해가 부족하다는 공감이 있어서 각자 한가지 씩 Service Discovery 도구들을 리뷰하는 시간을 가졌습니다.

https://gist.github.com/nacyot/514b904f7ae569e801e4

<iframe src="//slides.com/subicura/coreos-study/embed" width="600" height="440" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

<iframe src="//slides.com/changhoonjeong/docker-ambassador/embed" width="600" height="440" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

<iframe width="600" height="440" src="//www.youtube.com/embed/jBK3T1-1QdI" frameborder="0" allowfullscreen></iframe>

이 행아웃에서는 Seapy 님이 Docker ambassador 패턴에 대해서 발표해주셨고, 그 다음으로 제가 Consul에 대해서 발표했습니다. 마지막으로 Subicura 님이 CoreOS와 etcd와 fleet를 활용한 간단한 사용 예제를 보여주셨습니다.

아직 확정된 바는 없습니다만, 아마 여기서 논의한 이야기를 각자 좀 더 발전 시켜 다음 모임에서 발표를 하게 되지 않을까 생각하고 있습니다.

## 정리

지난 번 모임이후 진행된 사항을 정리해보았습니다.

다다음주가 황금연휴(?)고, 격주 진행시 pycon과 겹치는 관계로 아마 다음 모임은 23일이 될 것으로 생각하고 있습니다. 아직 스터디 지원 문제나 고정된 장소가 확정되지 않은 상태이긴 한데, 아마 확정되는대로 조만간 세번째 모임도 공지를 할 예정입니다.

모임에 참여해주신 모든 분들 다시 한 번 감사드립니다. 다들 어디 숨어계셨나 했더니 :) Docker Korea는 도커를 비롯해 클라우드나 서버 운영 전반에 관심있으신 분들 모두에게 열려있습니다. 특히 경험 공유나 주제 발표하시고 싶으신 분은 더더욱 우대합니다! 관심있으신 분들은 포럼에 들러주시고 대화방에도 참여해주세요.
