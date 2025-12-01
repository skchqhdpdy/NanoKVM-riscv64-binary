FROM ubuntu:24.04 AS builder

# 필수 패키지 설치
RUN apt-get update && \
    apt-get install -y wget build-essential git \
                       gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
                       make autoconf automake libtool

WORKDIR /src

# GNU Make 최신 버전 다운로드
RUN wget https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz && \
    tar xvf make-4.4.1.tar.gz

WORKDIR /src/make-4.4.1

# 정적 링크용 cross-compile
RUN ./configure \
      --host=riscv64-linux-gnu \
      --build=x86_64-linux-gnu \
      CC="riscv64-linux-gnu-gcc -static" \
      AR=riscv64-linux-gnu-ar \
      RANLIB=riscv64-linux-gnu-ranlib && \
    make

# 최종 단일 실행파일만 복사
FROM scratch AS final
COPY --from=builder /src/make-4.4.1/make /make-riscv64
ENTRYPOINT ["/make-riscv64"]

