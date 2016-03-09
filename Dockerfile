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

# Download and Configure glib
RUN IFS='.' read -r -a glib_array <<< "$GLIB" &&\
    wget http://ftp.gnome.org/pub/gnome/sources/glib/$glib_array[0].$glib_array[1]/glib-$GLIB.tar.xz &&\
    tar -xf glib-$GLIB.tar.gz &&\
    cd glib-$GLIB &&\
    ./configure --disable-xattr --disable-shared --enable-static --disable-libelf --disable-selinux &&\
    rm -rf /tmp/docker/build/*

# Build and install yara
RUN wget https://github.com/plusvic/yara/archive/v$YARA.tar.gz &&\
    tar xzf v$YARA.tar.gz &&\
    cd yara-$YARA &&\
    ./bootstrap.sh &&\
    ./configure --with-crypto --enable-cuckoo --enable-magic &&\
    make &&\
    make install &&\
    cd yara-python &&\
    python setup.py build &&\
    python setup.py install &&\
    rm -rf /tmp/docker/build/*

# Build and Configure Maxmind GeoIP
RUN wget http://www.maxmind.com/download/geoip/api/c/GeoIP-$MAXMIND.tar.gz &&\
    tar -zxf GeoIP-$MAXMIND.tar.gz &&\
    cd GeoIP-$MAXMIND &&\
    libtoolize -f &&\
    ./configure --enable-static &&\
    rm -rf /tmp/docker/build/*

# Build and Install libpcap
RUN wget http://www.tcpdump.org/release/libpcap-$LIBPCAP.tar.gz
    tar -zxf libpcap-$LIBPCAP.tar.gz &&\
    cd libpcap-$LIBPCAP &&\
    ./configure --disable-dbus &&\
    rm -rf /tmp/docker/build/*

# Build and Install libnids
RUN wget http://downloads.sourceforge.net/project/libnids/libnids/$LIBNIDS/libnids-$LIBNIDS.tar.gz &&\
    tar -zxf libnids-$LIBNIDS.tar.gz &&\
    cd libnids-$LIBNIDS &&\
    ./configure --disable-libnet --disable-glib2 &&\
    rm -rf /tmp/docker/build/*

# Build Moloch [CAPTURE]
RUN git clone https://github.com/aol/moloch.git &&\
    cd moloch/capture &&\
    ./configure &&\
    make

# Build Moloch [VIEWER]
RUN curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash - &&\
    apt-get install --yes nodejs &&\
    cd moloch/viewer &&\
    npm update

