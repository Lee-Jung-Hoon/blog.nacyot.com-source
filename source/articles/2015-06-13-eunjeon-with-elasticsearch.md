---
title: "엘라스틱서치(elasticsearch)에 한글 형태소 분석기 은전한잎(eunjeon) 적용하기"
date: 2015-06-13 06:05:00 +0900
author: nacyot
tags: 엘라스틱서치, elasticsearch, 형태소 분석, eunjeon, 은전한잎, mecab, mecab-ko, docker, 검색엔진
published: true
---

엘라스틱(elastic)에서 개발한 엘라스틱서치(elasticsearch)는 루씬 기반의 검색 서버이다. 동적으로 풀텍스트 검색을 하는 대신에 미리 인덱스를 해서 문장을 검색하기 때문에 매우 빠르게 원하는 결과를 찾을 수 있다. 설치도 간편하며 기본 설정으로 사용해도 충분히 강력하지만 기본적으로 한국어 분석을 지원하지 않는다. 예를 들어 전문 검색을 하고자 할 경우 "아버지가 방에 들어간다"라는 문장을 인덱스해도 "아버지"로는 검색이 안 되고 반드시 "아버지가"로 검색해야만 결과에 출력된다. 이는 엘라스틱서치의 기본 토크나이저가 공백이나 특수문자만으로 단어들을 분리하기 때문이다. 이러한 문제를 해결하기 위해서는 n-gram 분석이나, 형태소 분석과 같은 인덱스를 추가로 지원해야한다. 여기서는 일본어 형태소 분석기 mecab를 한국어에 맞춰 수정한 은전한잎(mecab-ko)을 엘라스틱서치에서 사용하는 방법에 대해서 다룬다.

<!--more-->

## TL;DR

Docker를 사용해 한글 형태소 분석기가 적용된 엘라스틱서치를 바로 사용해볼 수 있다. 필요한 경우 (일반적으로 boot2docker 사용할 경우 사용하는 주소인) `192.168.59.103` 대신 적절한 주소로 대체한다.

```
$ docker run -p 9200:9200 nacyot/elasticsearch-korean:1.6.0
$ curl -XPUT http://192.168.59.103:9200/korean/ -d '{"settings": {"index":{"analysis":{"analyzer":{"korean":{"type":"custom","tokenizer":"mecab_ko_standard_tokenizer"}}}}}}'
$ curl -XGET http://192.168.59.103:9200/korean/_analyze?analyzer=korean\&pretty=true -d '아버지가 방에 들어간다' | jq '.tokens[] | {token: .token, type: .type}'

# 분석 결과

{
  "token": "아버지가",
  "type": "EOJEOL"
}
{
  "token": "아버지",
  "type": "N"
}
{
  "token": "방에",
  "type": "EOJEOL"
}
{
  "token": "방",
  "type": "N"
}
{
  "token": "들어간다",
  "type": "INFLECT"
}
```
  
## 설치하기

엘라스틱서치에서 한글 형태소 분석기를 사용하려면 은전한잎을 설치할 필요가 있다. 다음 설치 방법은 우분투 14.04 운영체제에 오라클 자바 8 버전과 엘라스틱서치가 설치되었다는 것을 전제로 작성되었다. 은전한잎 플러그인은 엘라스틱서치 1.3 ~ 1.6(2015년 6월 현재 최신버전)에서 사용가능하다. 테스트에 사용한 버전은 1.6이다.

### 은전한잎(mecab-ko) 설치

먼저 은전한잎을 설치한다. 은전한잎은 일본어 형태소 분석기 mecab를 한국어에 맞게 수정한 프로젝트로 mecab-ko라는 프로젝트 이름을 가지고 있다. 최신버전 및 자세한 내용은 [저장소][mecab-ko]를 참고하기 바란다.

[mecab-ko]: https://bitbucket.org/eunjeon/mecab-ko

```
# 의존성 설치
$ apt-get install -y automake perl

# mecab-ko 다운로드
$ cd /opt
$ wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz
$ tar xvf mecab-0.996-ko-0.9.2.tar.gz

# 빌드 및 설치
$ cd /opt/mecab-0.996-ko-0.9.2
$ ./configure
$ make
$ make check
$ make install
$ ldconfig
```

### mecab-ko-dic 설치

다음으로 형태소 분석을 위한 사전을 설치한다. 자세한 내용은 [저장소][mecab-ko-dic]를 참조하기 바란다.

[mecab-ko-dic]: https://bitbucket.org/eunjeon/mecab-ko-dic/

```
# mecab-ko-dic 다운로드
$ cd /opt
$ wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.0-20150517.tar.gz
$ tar xvf mecab-ko-dic-1.6.1-20140814.tar.gz

# 빌드 및 설치
$ cd /opt/mecab-ko-dic-1.6.1-20140814
$ ./autogen.sh
$ ./configure
$ make
$ make install
```

### mecab-java 설치

다음므로 tagger와 lexicon의 메모리 누수가 해결된 mecab-java 버전을 설치한다.

```
# 환경 변수 설정
$ export JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

# mecab-java 다운로드
$ cd /opt
$ wget https://mecab.googlecode.com/files/mecab-java-0.996.tar.gz
$ tar xvf mecab-java-0.996.tar.gz

# 빌드 및 설치
$ cd /opt/mecab-java-0.996
$ sed -i 's|/usr/lib/jvm/java-6-openjdk/include|/usr/lib/jvm/java-8-oracle/include|' Makefile
$ make

# 빌드된 파일 이동(elasticsearch 실행시 참조해주어야 함)
$ cp libMeCab.so /usr/local/lib
```

### 엘라스틱서치 mecab-ko 플러그인 설치

마지막으로 엘라스틱서치에서 사용할 수 있도록 mecab-ko를 설치한다. `<ELASTICSEARCH_PATH>`에는 엘라스틱서치가 설치된 경로를 넣어준다.

```
<ELASTICSEARCH_PATH>/bin/plugin --install analysis-mecab-ko-0.17.0 --url https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.17.0.zip
```

## 형태소 분석을 통한 한국어 문장 검색

먼저 엘라스틱서치를 앞서 빌드한 `mecab-java`를 참조시켜서 실행한다.

```
$ elasticsearch -Djava.library.path=/usr/local/lib
```

한글 분석기가 정상적으로 작동하는 지 확인하기 위해 우선 기본 분석기를 통해서 문장을 분석해본다.

```
$ curl -XGET http://0.0.0.0:9200/_analyze?pretty=true -d '아버지가 방에 들어간다.'

# 분석 결과

{
  "tokens": [
    {
      "token": "아버지가",
      "start_offset": 0,
      "end_offset": 4,
      "type": "<HANGUL>",
      "position": 1
    },
    {
      "token": "방에",
      "start_offset": 5,
      "end_offset": 7,
      "type": "<HANGUL>",
      "position": 2
    },
    {
      "token": "들어간다",
      "start_offset": 8,
      "end_offset": 12,
      "type": "<HANGUL>",
      "position": 3
    }
  ]
}
```

처음에 얘기한대로 문장이 "아버지가" 통째로 분석된다. 이렇게 되면 "아버지"로는 이 문장을 검색할 수 없다.

```
# 데이터 입력
$ curl -XPUT 'http://0.0.0.0:9200/default/text/1' -d '{"text": "아버지가 방에 들어간다"}'

# '아버지'로 검색
$ curl -XGET 'http://0.0.0.0:9200/default/_search' -d '{"query":{"term": {"text": "아버지"}}}}' | jq .hits
{
  "total": 0,
  "max_score": null,
  "hits": []
}

# '아버지가'로 검색
$ curl -XGET 'http://0.0.0.0:9200/default/_search' -d '{"query":{"term": {"text": "아버지가"}}}}' | jq .hits
{
  "total": 1,
  "max_score": 0.15342641,
  "hits": [
    {
      "_index": "default",
      "_type": "text",
      "_id": "1",
      "_score": 0.15342641,
      "_source": {
        "text": "아버지가 방에 들어간다"
      }
    }
  ]
}
```

이번에는 `korean`이라는 이름으로 `mecab_ko_standard_tokenizer`가 적용된 인덱스를 생성한다.

```
$ curl -XPUT http://0.0.0.0:9200/korean/ -d '{
  "settings" : {
    "index":{
      "analysis":{
        "analyzer":{
          "korean":{
            "type":"custom",
            "tokenizer":"mecab_ko_standard_tokenizer"
          }
        }
      }
    }
  },
  "mappings": {
    "text" : {
      "properties" : {
        "text" : {
          "type" : "string",
          "analyzer": "korean"
        }
      }
    }
  }
}'
```

이 인덱스를 통해서 한국어 문장을 분석해본다.

```
$ curl -XGET http://0.0.0.0:9200/korean/_analyze?analyzer=korean\&pretty=true -d '아버지가 방에 들어간다' | jq '.tokens[] | {token: .token, type: .type}'

{
  "token": "아버지가",
  "type": "EOJEOL"
}
{
  "token": "아버지",
  "type": "N"
}
{
  "token": "방에",
  "type": "EOJEOL"
}
{
  "token": "방",
  "type": "N"
}
{
  "token": "들어간다",
  "type": "INFLECT"
}
```

이번에는 "아버지"나 "방"이 명사로 분석된 것을 알 수 있다. 이렇게 인덱스가 되면 정상적으로 검색이 가능하다.

```
# 데이터 입력
$ curl -XPUT 'http://0.0.0.0:9200/korean/text/1' -d '{"text": "아버지가 방에 들어간다"}'

# '아버지'로 검색
$ curl -XGET 'http://0.0.0.0:9200/korean/_search' -d '{"query":{"term": {"text": "아버지"}}}}' | jq .hits
{
  "total": 1,
  "max_score": 0.15342641,
  "hits": [
    {
      "_index": "korean",
      "_type": "text",
      "_id": "1",
      "_score": 0.15342641,
      "_source": {
        "text": "아버지가 방에 들어간다"
      }
    }
  ]
}
```

앞서 확인한 분석 결과대로 검색이 되는 것을 알 수 있다.

## 결론

일반적으로 동적으로 풀텍스트 서치를 하는 경우 원하는 결과가 검색될 가능성은 높지만, 매우 비효율적이고 검색 대상이 많아질수록 느려진다. 반면에 이른바 검색엔진으로 분류되는 도구들은 미리 텍스트를 분석해 인덱스를 만들기 때문에 매우 효율적으로 검색이 가능하다. 단, 인덱스를 의도한대로 만들어야만 원하는 검색결과를 얻을 수 있다. 앞서 살펴보았듯이 한글 문장을 검색하고자 한다면, 적절히 형태소 분석을 통한 한글 인덱스와 n-gram 인덱스를 만들어줄 필요가 있다. 엘라스틱서치에서는 analyzer와 mapping을 통해서 각 인덱스와 타입들에 대해서 섬세하고 풍부한 인덱스 기능을 지원하고 있다. 이러한 기능들을 잘 활용한다면 의도한 대로 검색 결과를 얻을 수 있을 것이다.
