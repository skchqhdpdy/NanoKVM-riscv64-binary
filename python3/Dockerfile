# 기본 amd64 데비안 이미지
FROM debian:12

ARG PY_VERSION=3.14.4
ARG PY_MAJOR_MINOR=3.14

# 필수 빌드 도구 설치 (zlib과 OpenSSL 다운로드를 위해 curl 추가)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    wget \
    curl \
    tar \
    zlib1g-dev \
    libssl-dev \
    libffi-dev

WORKDIR /toolchain

# RISC-V 64비트용 musl 크로스 컴파일러 다운로드
RUN wget https://musl.cc/riscv64-linux-musl-cross.tgz && \
    tar -xf riscv64-linux-musl-cross.tgz

# 툴체인 경로 및 빌드용 환경변수 추가
ENV PATH="/toolchain/riscv64-linux-musl-cross/bin:${PATH}"
ENV CROSS=riscv64-linux-musl
ENV PREFIX=/opt/riscv64-static

WORKDIR /build

# [의존성 1] zlib 정적 빌드 (파이썬 및 OpenSSL 내부 통신용)
RUN curl -L https://zlib.net/fossils/zlib-1.3.1.tar.gz | tar -xz \
    && cd zlib-* \
    && CC="${CROSS}-gcc" AR="${CROSS}-ar" RANLIB="${CROSS}-ranlib" ./configure --prefix=$PREFIX --static \
    && make -j$(nproc) && make install

# [의존성 2] OpenSSL 정적 빌드 (온라인 pip 설치를 위한 핵심)
RUN curl -L https://www.openssl.org/source/openssl-1.1.1w.tar.gz | tar -xz \
    && cd openssl-* \
    && ./Configure linux64-riscv64 no-shared --cross-compile-prefix=${CROSS}- --prefix=$PREFIX --openssldir=$PREFIX \
    && make -j$(nproc) && make install_sw

WORKDIR /build

# 파이썬 소스코드 다운로드
RUN wget https://www.python.org/ftp/python/${PY_VERSION}/Python-${PY_VERSION}.tgz && \
    tar -xf Python-${PY_VERSION}.tgz

WORKDIR /build/Python-${PY_VERSION}

# [STEP 1] Host(amd64)용 빌드 파이썬 생성 
RUN ./configure && make -j$(nproc) && make install && make clean

# [STEP 2] Target(riscv64 musl)용 파이썬 크로스 컴파일
RUN CC=riscv64-linux-musl-gcc \
    CXX=riscv64-linux-musl-g++ \
    AR=riscv64-linux-musl-ar \
    READELF=riscv64-linux-musl-readelf \
    RANLIB=riscv64-linux-musl-ranlib \
    CFLAGS="-I$PREFIX/include" \
    LDFLAGS="-L$PREFIX/lib" \
    ./configure \
    --host=riscv64-linux-musl \
    --build=x86_64-linux-gnu \
    --prefix=/python3-riscv64 \
    --disable-ipv6 \
    --without-ensurepip \
    --with-openssl=$PREFIX \
    --with-build-python=/usr/local/bin/python3 \
    ac_cv_buggy_getaddrinfo=no \
    ac_cv_file__dev_ptmx=yes \
    ac_cv_file__dev_ptc=no \
    ac_cv_func_pthread_getname_np=no \
    ac_cv_func_pthread_setname_np=no \
    && make -j$(nproc) \
    && make install

# [STEP 2.5] pip를 파이썬에 아예 내장하기
# 변경된 prefix 경로(/python3-riscv64)에 맞춰 타겟 경로 수정
RUN /usr/local/bin/python3 -m pip install --target=/python3-riscv64/lib/python${PY_MAJOR_MINOR}/site-packages pip

# [STEP 3] 추출하기 쉽게 결과물을 tar.gz로 압축
WORKDIR /
# find 명령어를 사용하여 버전에 상관없이 모든 __pycache__ 폴더를 찾아 삭제합니다.
RUN find /python3-riscv64 -name "__pycache__" -type d -exec rm -rf {} + \
    && rm -rf /python3-riscv64/lib/*.a \
    && rm -rf /python3-riscv64/lib/python${PY_MAJOR_MINOR}/test \
    && tar -I 'gzip -9' -cvf /python3-riscv64.tar.gz /python3-riscv64

ENTRYPOINT ["/python3-riscv64.tar.gz"]