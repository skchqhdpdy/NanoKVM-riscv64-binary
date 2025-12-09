FROM ubuntu:24.04

# 실제 서버 설치 경로를 빌드 시 지정 가능
ARG INSTALL_DIR=/root/tools/autoconf
ENV PREFIX=$INSTALL_DIR
ENV PATH=$PREFIX/bin:$PATH

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    m4 \
    perl \
    pkg-config \
    bison \
    flex \
    texinfo \
    autoconf \
    automake \
    libtool \
    git \
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    make \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# autoconf 소스 다운로드
RUN wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz \
    && tar xzf autoconf-2.71.tar.gz

WORKDIR /build/autoconf-2.71

# cross-compile 환경 변수
ENV CC=riscv64-linux-gnu-gcc
ENV CXX=riscv64-linux-gnu-g++
ENV AR=riscv64-linux-gnu-ar
ENV AS=riscv64-linux-gnu-as
ENV LD=riscv64-linux-gnu-ld
ENV RANLIB=riscv64-linux-gnu-ranlib
ENV STRIP=riscv64-linux-gnu-strip

# configure 시 PREFIX를 지정
RUN ./configure --host=riscv64-linux-gnu --prefix=$PREFIX \
    && make -j$(nproc) \
    && make install