FROM ubuntu:24.04

# ===============================
# 1. 설치 경로
# ===============================
ARG INSTALL_DIR=/root/tools/autoconf
ENV PREFIX=$INSTALL_DIR
ENV PATH=$PREFIX/bin:$PATH

WORKDIR /build

# ===============================
# 2. 필수 도구 설치 (빌드용)
# ===============================
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    m4 \
    pkg-config \
    bison \
    flex \
    texinfo \
    git \
    curl \
    ca-certificates \
    libncurses5-dev \
    libssl-dev \
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    make \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# 3. RISC-V Perl cross-compile
# ===============================
RUN wget https://www.cpan.org/src/5.0/perl-5.40.0.tar.gz \
    && tar xzf perl-5.40.0.tar.gz

WORKDIR /build/perl-5.40.0

# Cross-compile 환경 변수
ENV CC=riscv64-linux-gnu-gcc
ENV CXX=riscv64-linux-gnu-g++
ENV AR=riscv64-linux-gnu-ar
ENV AS=riscv64-linux-gnu-as
ENV LD=riscv64-linux-gnu-ld
ENV RANLIB=riscv64-linux-gnu-ranlib
ENV STRIP=riscv64-linux-gnu-strip

RUN ./Configure -des -Dprefix=$PREFIX -Darchname=riscv64-linux-gnu -Duse64bitall -Doptimize='-O2' \
    && make -j$(nproc) \
    && make install

ENV PATH=$PREFIX/bin:$PATH

# ===============================
# 4. autoconf cross-compile
# ===============================
WORKDIR /build
RUN wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz \
    && tar xzf autoconf-2.71.tar.gz

WORKDIR /build/autoconf-2.71

RUN ./configure --host=riscv64-linux-gnu --prefix=$PREFIX \
    && make -j$(nproc) \
    && make install

# ===============================
# 5. autom4te shebang 수정
# ===============================
RUN sed -i '1s|^.*|#!'"$PREFIX"'/bin/perl|' $PREFIX/bin/autom4te

# ===============================
# 6. wrapper 스크립트 생성
# ===============================
RUN echo '#!/bin/sh\nexport AUTOM4TE='"$PREFIX"'/bin/autom4te\nexec '"$PREFIX"'/bin/autoconf "$@"' \
    > /usr/local/bin/autoconf-wrapper \
    && chmod +x /usr/local/bin/autoconf-wrapper