FROM alpine:latest
RUN apk add --update wget curl openjdk8 python git && \
    mkdir /data/git &&\
    echo "git clone" &&\
    git clone https://github.com/aol/moloch.git /data/git &&\
    cd /data/git &&\
    USEPFRING=no ESMEM="512M" DONOTSTART=yes MOLOCHUSER=daemon GROUPNAME=daemon PASSWORD=password INTERFACE=eth0 BATCHRUN=yes ./easybutton-singlehost.sh &&\
    rm -rf /var/cache/apk/*
