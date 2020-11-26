FROM ubuntu:18.04 AS afl-dyninst
MAINTAINER vh@thc.org

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
        build-essential \
        gcc \
        g++ \
        make \
        cmake \
        m4 \
        clang \
        llvm \
        git \
        ca-certificates \
        tar \
        gzip \
        vim \
        curl \
        apt-utils \
        libelf-dev \
        libelf1 \
        libiberty-dev \
        libboost-all-dev \
        libtbb2 \
        libtbb-dev \
    && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/dyninst/dyninst \
        && cd dyninst && mkdir build && cd build \
        && cmake .. \
        && make -j4 \
        && make install

RUN git clone https://github.com/vanhauser-thc/AFLplusplus \
        && cd AFLplusplus \
        && make source-only \
        && make install \
        && cd ..

RUN mkdir -p /path/to/dyninst/ && ln -s /dyninst/build /path/to/dyninst/build-directory

RUN git clone https://github.com/vanhauser-thc/afl-dyninst \
        && cd afl-dyninst \
        && ln -s ../AFLplusplus afl \
        && make \
        && make install \
        && cd .. \
        && echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig \
        && echo "export DYNINSTAPI_RT_LIB=/usr/local/lib/libdyninstAPI_RT.so" >> .bashrc

RUN rm -rf afl-dyninst AFLplusplus dyninst

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so
