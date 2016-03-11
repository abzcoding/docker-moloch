FROM alpine:latest

MAINTAINER Abouzar Parvan <abzcoding@gmail.com>

WORKDIR /tmp/docker/build

RUN buildDeps='curl \
               git \
               g++ \
               libffi-dev \
               zlib-dev \
               make' \
  && set -x \
  && apk add --update $buildDeps \
                      python \
  && echo "Build Moloch [CAPTURE]" \
  && git clone https://github.com/aol/moloch.git \
  && cd moloch \
  && ./easybutton-build.sh \
  && cd \
  && echo "Build Moloch [VIEWER]" \
  && wget http://nodejs.org/dist/v0.10.38/node-v0.10.38.tar.gz \
  && tar -zxf node-v0.10.38.tar.gz \
  && cd node-v0.10.38 \
  && ./configure \
  && make \
  && make install \
  && cd /tmp/docker/build/moloch/viewer \
  && npm update \
  && git clone https://github.com/aol/moloch.git /moloch \
  && cd /moloch \
  && mkdir -p files \
  && cd files \
  && wget https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv \
  && wget http://www.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
  && gunzip GeoIPASNum.dat.gz \
  && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
  && gunzip GeoIP.dat.gz \
  && rm -f *.gz \
  && sed -i -e 's/CHANGEME_ESHOSTNAME/elasticsearch/g' /moloch/config.ini \
  && sed -i -e 's/GeoIP\.dat/files\/GeoIP\.dat/g' /moloch/config.ini \
  && sed -i -e 's/GeoIPASNum\.dat/files\/GeoIPASNum\.dat/g' /moloch/config.ini \
  && sed -i -e 's/ipv4-address-space\.cvs/files\/ipv4-address-space\.csv/g' /moloch/config.ini \
  && echo "Clean up unnecessary files" \
  && apt-get purge -y --auto-remove $buildDeps \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
