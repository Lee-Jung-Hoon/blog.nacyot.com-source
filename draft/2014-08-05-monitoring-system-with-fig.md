---
title: 피그(Fig)를 통한 도커 컨테이너 일괄 실행하기
author: nacyot
date: 2014-08-05 00:15:03 +0900
tags: 
published: false
---

## fig 소개

## fig 설치

http://www.fig.sh/install.html


이전 글 "그라파이트(Grahpite) + 그라파나(Grafana) 모니터링 시스템 구축 with Docker"의 요약은 같습니다.

```
$ docker run --name whisper nacyot/whisper
$ docker run -d -p 2003:2003 -p 2004:2004 -p 7002:7002 --volumes-from whisper -e NODE_NAME=cache nacyot/carbon-cache
$ docker run -d -p 8000:80 -e CARBONLINK_HOSTS="172.17.42.1:7002" --volumes-from whisper nacyot/graphite-web
$ docker run -d -p 9200:9200 -p 9300:9300 dockerfile/elasticsearch
$ docker run -d -p 8001:8000 nacyot/grafana
```

```
whisper:
image: nacyot/whisper
 
carboncache:
image: nacyot/carbon-cache
ports:
  - "2003:2003"
  - "2004:2004"
  - "7002:7002"
volumes_from:
  - whisper
environment:
  - NOME_NAME=cache
 
graphiteweb:
image: nacyot/graphite-web
ports:
  - "8000:80"
environment:
  - CARBONLINK_HOSTS=172.17.42.1:7002
volumes_from:
  - whisper
 
elasticsearch:
image: dockerfile/elasticsearch
ports:
  - "9200:9200"
  - "9300:9300"
 
grafana:
image: nacyot/grafana
ports:
  - "8001:8000"
```

이전 글에서는 포함하지 않고 있습니다만, 여기에 Kibana 컨테이너도 추가해줍니다.

```
kibana:
image: nacyot/kibana
ports:
  - "8002:8002"
```


```
$ fig up
```
