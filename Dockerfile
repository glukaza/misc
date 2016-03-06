FROM centos:7
RUN yum update -y

RUN yum install -y \
    epel-release \
    wget

RUN wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
RUN rpm -Uvh erlang-solutions-1.0-1.noarch.rpm

RUN yum install -y erlang

ADD /webserver/ /opt/

EXPOSE 8008