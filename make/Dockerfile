FROM ubuntu:24.04 AS builder

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -y wget build-essential git \
                       gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
                       make autoconf automake libtool

WORKDIR /src

# GNU Make 최신 버전 다운로드
RUN wget https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz && \
    tar xvf make-4.4.1.tar.gz

WORKDIR /src/make-4.4.1

# 정적 링크용 cross-compile
RUN ./configure \
      --host=aarch64-linux-gnu \
      --build=x86_64-linux-gnu \
      CC="aarch64-linux-gnu-gcc -static" \
      AR=aarch64-linux-gnu-ar \
      RANLIB=aarch64-linux-gnu-ranlib && \
    make

# 최종 단일 실행파일만 복사
FROM scratch AS final
COPY --from=builder /src/make-4.4.1/make /make-arm64
ENTRYPOINT ["/make-arm64"]