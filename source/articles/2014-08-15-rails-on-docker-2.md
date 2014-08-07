---
title: "도커(Docker)로 루비 온 레일스 어플리케이션 배포하기 (2) 도커 이미지 배포하기"
date: 2014-08-15 05:10:00 +0900
author: nacyot
tags: ruby, docker, rails, deploy, devops, haproxy, digital ocean, dockerfile, 루비, 도커, 레일스, 배포, 서버, 서버 운영
published: false
---

## 레일스 어플리케이션 이미지 배포하기

### 이미지 배포하기

#### hub.docker.com

* hub.dokcer.com
  * 구 index.docker.io
  * 많은 오픈소스들이 도커 이미지로 공유됨
  * 일부 오픈소스는 프로젝트에서 공식 지원
    * strider-cd, 도커 관련 프로젝트들

* https://registry.hub.docker.com/u/nacyot/docker-yobi
  * https://github.com/nacyot/docker-yobi
  * Dockerfile만 올리면 알아서 자동 빌드
  * commit 후크

* 올리는 과정
  * Dockerfile 있는 저장소 생성
  * Docker Hub에서 Github 연동

```
# 이미지 받아오기
docker pull nacyot/docker-yobi
docker images | grep nacyot/docker-yobi

# 컨테이너 실행
docker run --name YOBI -d -p 3001:9000 nacyot/docker-yobi

# 로그 보기
docker logs -f YOBI
```

* YOBI 사이트 접속 및 기본 설정
* 로그인 및 프로젝트 생성

```
cd ../hello-yobi
git remote -v
git push origin master
```

* 프로젝트 페이지 확인

```
# YOBI 삭제
docker stop YOBI
docker rm YOBI
```

### Private Docker Registry Server

* Docker registry
  * https://github.com/dotcloud/docker-registry
  * Docker Image 제공

#### docker-registry server

```
# 디지털 오션 클라이언트 설치
# gem install tugboat

# 가상 서버 생성
tugboat create registry -s 66 -i 3668014 -r 6 -k 102859

# 서버 실행 확인
tugboat droplets | grep registry
ping 128.199.252.140
# ssh-keygen -f "/home/nacyot/.ssh/known_hosts" -R 128.199.252.140

# registry 서버 접속
ssh root@128.199.252.140
docker version

# registry 이미지 가져오기
docker pull registry
docker run -d -p 5000:5000 registry

# ssh 빠져나오기
exit

# docker-registry 서버 테스트
curl -XGET http://128.199.252.140:5000/
```

#### registry 서버에 이미지 push

```
# registry 등록용 tag 지정
docker tag nacyot/rails-new:0.3 128.199.252.140:5000/rails-new:0.3

# 이미지 push하기
docker push 128.199.252.140:5000/rails-new:0.3
```

#### registry 서버에서 이미지 pull

```
# 가상 서버 실행
tugboat create docker1 -s 66 -i 3668014 -r 6 -k 102859
tugboat droplets | grep docker
ping 128.199.189.203

# ssh 접속
ssh root@128.199.189.208
ssh-keygen -f "/home/nacyot/.ssh/known_hosts" -R 128.199.189.208
docker --version
docker pull 128.199.252.140:5000/rails-new:0.3
docker images
docker run -d --name v0.3 -p 60005:60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" 128.199.252.140:5000/rails-new:0.3
w3m http://localhost:60005
```

#### 아마존 서버

```
ssh ubuntu@ec2-54-178-163-61.ap-northeast-1.compute.amazonaws.com -i ~/.ssh/amazonNacyot.pem
docker --version
docker pull 128.199.252.140:5000/rails-new:0.3
docker images
docker run -d --name v0.3 -p 60005:60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" 128.199.252.140:5000/rails-new:0.3
w3m http://localhost:60005
```

* Stateless Sharde Nothing

### vs chef, vs ami

#### chef

* 관리가능하고 (Cookbook)
* 테스트 가능하며
* 재현 가능하며
* --Stateless하고--
* Scalable한
* --이미지 기반의--
* 어플리케이션 배포

### AMI

* 관리가능하고(AMI Image)
* --테스트 가능하며--
* --재현 가능하며--
* --Stateless하고--
* Scalable한
* 이미지 기반의
* 어플리케이션 배포

### Docker

* 관리가능하고(AMI Image)
* 테스트 가능하며
* 재현 가능하며
* Stateless하고
* Scalable한
* 이미지 기반의
* 어플리케이션 배포

### v0.4 haproxy

#### rails 0.4

```
cd docker-sample-project
git checkout v0.3
git diff v0.4
```

#### haproxy

```
cd ..

# haproxy 이미지 pull
dokcer pull dockerfile/haproxy

# haproxy 환경 설정 파일
cat haproxy/haproxy.cfg

# haproxy 실행하기
docker run -d -p 3000:60000 -v /home/nacyot/Dropbox/writings/rails-on-docker/rails-new-dockerfile/haproxy:/haproxy-override dockerfile/haproxy
```

#### Build

```
cd ../v0.4
diff Dockerfile ../v0.3/Dockerfile
docker build -t nacyot/rails-new:0.4 .
```

#### 서버 실행하기

# rails 서버 실행하기
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4
docker run -d -p 60005 -e DATABASE_URL="mysql2://docker:abcd1234@128.199.255.32/rails_new" nacyot/rails-new:0.4

docker ps
```

### packer

* http://www.packer.io/docs

```
cd ../packer
cat site-cookbooks/apache/recipes/default.rb
cat machine_chef.json
packer build machine
```

* Dokku
* Building
* Dockerfile
