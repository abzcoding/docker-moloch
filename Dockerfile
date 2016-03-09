FROM ubuntu:latest
MAINTAINER Abouzar Parvan <abzcoding@gmail.com>

ENV YARA 3.4.0
ENV GLIB 2.47.4
ENV MAXMIND 1.6.0
ENV LIBPCAP 1.7.2
ENV LIBNIDS 1.24

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
RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - &&\
    apt-get install --yes nodejs &&\
    cd moloch/viewer &&\
    npm update

