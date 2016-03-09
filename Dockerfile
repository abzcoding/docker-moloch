FROM ubuntu:latest
MAINTAINER Abouzar Parvan <abzcoding@gmail.com>

ENV NODE 0.10.38

WORKDIR /tmp/docker/build

COPY builddep.txt /tmp/
COPY packages.txt /tmp/

# Install the build dependencies
RUN apt-get update &&\
    xargs apt-get install -y < /tmp/builddep.txt

# Install the moloch dependencies
RUN xargs apt-get install -y < /tmp/packages.txt &&\
    rm /tmp/packages.txt

# Disable Swap in linux kernel
RUN swapoff -a

# Build Moloch [CAPTURE]
RUN git clone https://github.com/aol/moloch.git &&\
    cd moloch &&\
    ./easybutton-build.sh

# Build Moloch [VIEWER]
RUN wget http://nodejs.org/dist/v$NODE/node-v$NODE.tar.gz &&\
    tar -zxf node-v$NODE.tar.gz &&\
    cd node-v$NODE &&\
    ./configure &&\
    make &&\
    make install &&\
    cd /tmp/docker/build/moloch/viewer &&\
    npm update

