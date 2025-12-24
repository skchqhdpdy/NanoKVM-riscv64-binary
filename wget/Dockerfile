# 빌드 환경: Ubuntu 기반
FROM ubuntu:22.04 AS builder

# 필요한 빌드 도구 및 크로스 컴파일러 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu \
    pkg-config \
    perl \
    make \
    wget \
    xz-utils

# 환경 변수 설정
ENV CC=riscv64-linux-gnu-gcc
ENV AR=riscv64-linux-gnu-ar
ENV RANLIB=riscv64-linux-gnu-ranlib
ENV HOST=riscv64-linux-gnu

WORKDIR /build

# 1. Zlib 빌드 (정적)
RUN wget https://zlib.net/zlib-1.3.1.tar.gz && tar -xf zlib-1.3.1.tar.gz
RUN cd zlib-1.3.1 && \
    CHEST="riscv64-linux-gnu-" ./configure --static --prefix=/build/out && \
    make -j$(nproc) && make install

# 2. OpenSSL 빌드 (정적, HTTPS 지원을 위해 필요)
RUN wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz && tar -xf openssl-1.1.1w.tar.gz
RUN cd openssl-1.1.1w && \
    ./Configure linux64-riscv64 --prefix=/build/out --openssldir=/build/out/ssl no-shared zlib \
    --with-zlib-include=/build/out/include --with-zlib-lib=/build/out/lib && \
    make -j$(nproc) && make install_sw

# 3. Wget 빌드 (정적)
RUN wget https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz && tar -xf wget-1.21.4.tar.gz
RUN cd wget-1.21.4 && \
    ./configure --host=$HOST --with-ssl=openssl --with-libssl-prefix=/build/out \
    CFLAGS="-I/build/out/include -static" \
    LDFLAGS="-L/build/out/lib -static" \
    LIBS="-lssl -lcrypto -lz -lpthread -ldl" && \
    make -j$(nproc)

# 최종 바이너리 위치 지정
RUN cp /build/wget-1.21.4/src/wget /wget-riscv64

# 실행 환경 (최소화)
FROM scratch
COPY --from=builder /wget-riscv64 /wget-riscv64
ENTRYPOINT ["/wget-riscv64"]