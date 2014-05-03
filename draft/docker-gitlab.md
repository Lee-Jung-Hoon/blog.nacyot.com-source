--- title: 도커(Docker)로 Gitlab 설치하기 plang: description: tags: related_keywords: ---  ubuntu@ip-172-31-29-137:~$ docker run -e MYSQL_PASS="edomu.datenyn;bhuatupema" -d -p 3306:3306 -v /opt/docker/graphite:/var/lib/mysql tutum/mysql
d00650de8daf6a7784ea32543269101750d4d3c1a7e266a09ffa00f8dcfa4d22
ubuntu@ip-172-31-29-137:~$ dokcer ps
No command 'dokcer' found, did you mean:
Command 'docker' from package 'docker' (universe)
dokcer: command not found
ubuntu@ip-172-31-29-137:~$ docker ps
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS              PORTS                    NAMES
d00650de8daf        tutum/mysql:latest   /run.sh             11 seconds ago      Up 9 seconds        0.0.0.0:3306->3306/tcp   grave_nobel
ubuntu@ip-172-31-29-137:~$

$ sudo apt-get install mysql-client

docker run -e MYSQL_PASS="qlenfrl999" -d -v /opt/docker/graphite:/var/lib/mysql tutum/mysql /bin/bash -c "/usr/bin/mysql_install_db"

ubuntu@ip-172-31-29-137:~$ docker run -e M^CQL_PASS="qlenfrl999" -d -v /opt/docker/graphite:/var/lib/mysql tutum/mysql /bin/bash -c "/usr/bin/mysql_install_db"
ubuntu@ip-172-31-29-137:~$ sudo mkdir -p /opt/docker-data/mysql/
ubuntu@ip-172-31-29-137:~$  docker run -e MYSQL_PASS="qlenfrl999" -d -v /opt/docker-data/mysql:/var/lib/mysql tutum/mysql /bin/bash -c "/usr/bin/mysql_install_db"
50d263ec998276c1597ebaa9e4c7211c44ec388db3866d30a7ba941203d239dd
ubuntu@ip-172-31-29-137:~$ dokcer ps
No command 'dokcer' found, did you mean:
Command 'docker' from package 'docker' (universe)
dokcer: command not found
ubuntu@ip-172-31-29-137:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ubuntu@ip-172-31-29-137:~$ docker run -e MYSQL_PASS="edomu.datenyn;bhuatupema" -d -p 3306:3306 -v /opt/docker-data/mysql:/var/lib/mysql tutum/mysql
447e4454de2917b383461c79508ae9e014256d9cc10616fa06cff717bd6d2f85
ubuntu@ip-172-31-29-137:~$ docker ps
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS              PORTS                    NAMES
447e4454de29        tutum/mysql:latest   /run.sh             2 seconds ago       Up 1 seconds        0.0.0.0:3306->3306/tcp   agitated_fermat
ubuntu@ip-172-31-29-137:~$ docker logs 447e
=> Creating MySQL admin user with preset password


ubuntu@ip-172-31-29-137:~$ mysql -h 0.0.0.0 -uadmin -P 3306 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.5.35-0ubuntu0.13.10.2 (Ubuntu)

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

docker pull ubuntu
docker pull tutum/mysql:latest
docker pull sameersbn/gitlab:latest

ubuntu@ip-172-31-29-137:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
sameersbn/gitlab    latest              0f00319148d7        35 minutes ago      973.7 MB
tutum/mysql         latest              194bb842efe0        4 weeks ago         370.7 MB
ubuntu              13.10               25593492b938        11 days ago         192.6 MB
ubuntu              saucy               25593492b938        11 days ago         192.6 MB
ubuntu              13.04               ab4344e23e3a        11 days ago         176.2 MB
ubuntu              raring              ab4344e23e3a        11 days ago         176.2 MB
ubuntu              12.10               f697cdc2ef19        11 days ago         172.7 MB
ubuntu              quantal             f697cdc2ef19        11 days ago         172.7 MB
ubuntu              10.04               e20bcab99567        11 days ago         183 MB
ubuntu              lucid               e20bcab99567        11 days ago         183 MB
ubuntu              latest              c0fe63f9a4c1        11 days ago         229.7 MB
ubuntu              12.04               c0fe63f9a4c1        11 days ago         229.7 MB
ubuntu              precise             c0fe63f9a4c1        11 days ago         229.7 MB

