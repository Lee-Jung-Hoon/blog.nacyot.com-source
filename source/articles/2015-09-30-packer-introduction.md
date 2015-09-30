---
title: 패커(Packer)로 도커(Docker) 이미지 빌드 및 AMI 자동 빌드 시스템 구축
date: 2015-09-30 11:46:00 +0900
author: nacyot
tags: packer, docker, aws, docker_seoul_meetup, software, infrastructure
categories: software, infrastructure
title_image: http://i.imgur.com/yFhEkck.png
published: true
canonical: "http://blog.remotty.com/blog/2015/09/30/paekeopackerro-dokeodocker-imiji-bildeu-mic-ami-jadong-bildeu-siseutem-gucug/"
---

[패커(Packer)][packer]는 범용적 머신/컨테이너 이미지 생성기이다. 이미지는 일반적으로 가상머신의 특정한 상태를 그대로 저장해서 만들어진다. Packer에서는 Builder 컴포넌트를 통해 다양한 플랫폼을 지원하고, Provisioner 컴포넌트를 통해 다양한 도구로 이미지를 빌드할 수 있다. 이 글은 2015년 9월 5일 네번째 [Docker Seoul Meetup][meetup_4th]에서 발표한 내용을 기반으로 작성되었으며, Packer에 대한 기본적인 기능들과 간단한 사용법에 대해서 소개한다.

[packer]: https://www.packer.io/
[meetup_4th]: http://forum.opencontainer.co.kr/t/open-container-seoul-meetup-4th/420

<!--more-->
