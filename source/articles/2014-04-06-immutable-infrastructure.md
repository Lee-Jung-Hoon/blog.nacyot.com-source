---
title: "이미지 기반 어플리케이션 배포 패러다임 Immutable Infrastructure"
date: 2014-04-06 03:20:32 +0900
author: nacyot
---

얼마 전 4월 2일에 [프로그래머 그룹][programer]에서 Immutable Infrastructure을 주제로 발표했습니다. Immutable Infrastructure란 분명한 실체를 지칭하기보다는 한 번 설정하고 (거의) 변경하지 않는 이미지 기반의 어플리케이션 배포 패러다임을 뜻하는 단어입니다. 다수의 서버를 동적으로 관리하는 클라우드를 기반으로 어떻게 하면 좀 더 효과적이고 유연하게 배포할 수 있을가 하는 고민에서 나온 패러다임이라고 할 수 있습니다. 따라서 기존에 서버를 지속적으로 '관리'한다는 데서 벗어나 어떻게하면 서버를 잘 쓰고 버리는 지를 다룹니다. 지금까지는 AWS AMI를 통한 오토 스케일링에서 보듯이 이러한 패러다임이 현상적으로만 존재했는데, Heroku, Travis 등에서는 이러한 패러다임을 이미 적극 채용하고 있으며, 특히 Chef, Puppet, Docker, Vagrant, Packer, Serf와 같은 도구들은 Immutable Infrastructure라는 패러다임을 실제 어플리케이션 배포에 적용할 수 있도록 도와줍니다. 이 글에서는 발표자료와 관련된 관련된 리소스들을 소개합니다.

* [Immutable Infrastructure 발표 자료][slides]

[programer]: https://www.facebook.com/groups/programer.io/
[slides]: /presentations/immutable_infrastructure

<!--more-->

## Cloud

* [Amazon Web Service][aws]
* [Heroku][heroku]
* [Cloud Design Pattern Wiki][cdp]
* [CDP 한국어 발표자료][tamakawa]
* [Digital Ocean][digital_ocean]
* [Tugboat Gem][tugboat]
* [RRRSpec][rrrspec]
* [Cookpad Blog : RRRSpec 한글 번역][rrrspec]
* [AWS Command Line Interface][awscli]

[aws]: http://aws.amazon.com/
[heroku]: https://www.heroku.com/
[cdp]: http://en.clouddesignpattern.org/index.php/Main_Page
[tamakawa]:  http://www.slideshare.net/kentamagawa/aws-cloud-design-pattenr-korean-cdp-seminar-in-korea
[digital_ocean]: [https://digitalocean.com/]
[rrrspec]: https://github.com/cookpad/rrrspec
[rrrspec_kr]: https://gist.github.com/marocchino/9738532
[tugboat]: https://github.com/pearkes/tugboat
[awscli]: http://aws.amazon.com/cli/

## Immutable Infrastructure

* [The Twelve-Factor App][12_factor]
* [Heroku][heroku]
* [Travis CI][travis]
* [Trash Your Servers and Burn Your Code: Immutable Infrastructure and Disposable Components][disposable]
* [itchell Hashimoto, HashiCorp][ii_hashi]
* [BlueGreeDeployment][bluegreen]


[12_factor]: http://12factor.net/
[heroku]: http://heroku.com
[Travis]: http://travis-ci.org
[disposable]: http://chadfowler.com/blog/2013/06/23/immutable-deployments/
[ii_hashi]: http://www.slideshare.net/profyclub_ru/8-mitchell-hashimoto-hashicorp
[bluegreen]: http://shop.oreilly.com/product/0636920026358.do

## Configuration Management

* [Chef][chef]
* [Puppet][puppet]
* [Ansible][ansible]
* [Chef Solo 입문 도서][chef_solo]
* [Knife Solo][knife_solo]
* [Berfshelf][berfshelf]
* [ServerSpec][serverspec]
* [Circleci Serverspec][infrastructure_as_code]
* [H3 2012 - Just Do IT, Chef 언제까지 손으로 일일이 할텐가?][h3_chef_youtube]

[puppet]: http://puppetlabs.com/
[ansible]: http://www.ansible.com/home
[chef]: http://www.getchef.com/chef/
[chef_solo]: http://book.daum.net/detail/book.do?bookid=KOR9788994506890&introCpID=YE
[knife_solo]: http://matschaffer.github.io/knife-solo/
[berfshelf]: http://berkshelf.com/
[serverspec]: http://serverspec.org/
[infrastructure_as_code]: https://github.com/naoya/circleci-serverspec/pull/1
[h3_chef_youtube]: http://www.youtube.com/watch?v=ruAdx8-1a5s

## Docker

* [Docker][docker]
* [Top 10 Startups Built on Docker][10_start]
* [Drone][drone]
* [Drone.io][drone.io]
* [Dokku][dokku]
* [About docker in GDG Seoul][gdg]
* [도커(Docker) 튜토리얼 : 깐 김에 배포까지][docker_introduction]
* [Docker 치트 시트][docker_cheat_sheet]
* [Docker 간단 가이드][docker_simple]
* [Deview Lightweight Linux Container Docker][docker_deview]

[docker]: https://www.docker.io/
[10_start]: http://www.centurylinklabs.com/top-10-startups-built-on-docker/
[drone]: https://github.com/drone/drone
[drone.io]: https://drone.io
[dokku]: https://github.com/progrium/dokku
[gdg]: http://www.slideshare.net/modestjude/about-docker-in-gdg-seoul
[docker_introduction]: http://blog.nacyot.com/articles/2014-01-27-easy-deploy-with-docker/
[docker_cheat_sheet]: https://gist.github.com/nacyot/8366310
[docker_simple]: http://www.slideshare.net/raccoonyy/docker-28358999
[docker_deview]: http://deview.kr/2013/detail.nhn?topicSeq=45

# Vagrant

* [Vagrant][vagrant]
* [Vagrant AWS Provider][ec2_provider]
* [Vagrant Digital Ocean Provider][do_provider]
* [Vagrant Docker Provider][docker_provider]
* [H3 2012 - 내컴에선 잘되던데? - vagrant로 서버와 동일한 개발환경 꾸미기 슬라이드][h3_vagrant]
* [H3 2012 - 내컴에선 잘되던데? - vagrant로 서버와 동일한 개발환경 꾸미기 영상][h3_vagrant_youtube]
* [Book Vagrant: Up and Running][vagrant_up_and_run]

[vagrant]: http://www.vagrantup.com/
[ec2_provider]: https://github.com/mitchellh/vagrant-aws
[do_provider]: https://github.com/smdahlen/vagrant-digitalocean
[docker_provider]: https://github.com/fgrehm/docker-provider
[h3_vagrant]: http://www.slideshare.net/kthcorp/h3-2012-vagrant
[h3_vagrant_youtube]: http://www.youtube.com/watch?v=BWHX7u5NEtE
[vagrant_up_and_run]: http://shop.oreilly.com/product/0636920026358.do

## Packer

* [Packer][packer]

[packer]: http://www.packer.io/

## Serf

* [Serf][serf]

[serf]: http://www.serfdom.io/
